//
//  ReadP12Subject.m
//  ABox
//
//  Created by SWING on 2022/4/12.
//

#import "ReadP12Subject.h"
#include <openssl/pkcs12.h>
#include "p12checker.h"


@implementation P12CertificateInfo

@end

@implementation ReadP12Subject

- (P12CertificateInfo *)readCertInfoWhitAltCert:(ALTCertificate *)altCertificate {
    P12CertificateInfo *certInfo = [[P12CertificateInfo alloc] init];
    
    NSData *altCertificateP12Data = [altCertificate p12Data];
    
    BIO *inputP12Buffer = BIO_new(BIO_s_mem());
    BIO_write(inputP12Buffer, altCertificateP12Data.bytes, (int)altCertificateP12Data.length);
    
    auto inputP12 = d2i_PKCS12_bio(inputP12Buffer, NULL);
    
    // Extract key + certificate from .p12.
    EVP_PKEY *key;
    X509 *usrCert;
    char* p = NULL;

    PKCS12_parse(inputP12, "", &key, &usrCert, NULL);
    
    if (usrCert)
    {
        fprintf(stdout, "Subject:");
        p = X509_NAME_oneline(X509_get_subject_name(usrCert), NULL, 0);
        ASN1_TIME* before = X509_get_notBefore(usrCert);
        long start_time = [self readRealTimeForX509:(char *)before->data];

        ASN1_TIME* after = X509_get_notAfter(usrCert);
        long expire_time = [self readRealTimeForX509:(char *)after->data];
        
        //读取证书内容
        NSDictionary* subject = [self readSubjectFormX509:p];
        certInfo.name = subject[@"CN"];
        certInfo.organization = subject[@"O"];
        certInfo.organizationUnit = subject[@"OU"];
        certInfo.userID = subject[@"UID"];
        certInfo.country = subject[@"C"];
        certInfo.startTime = start_time;
        certInfo.expireTime = expire_time;
    }
    return certInfo;
}

- (void)readCertInfoWhitAltCert:(ALTCertificate *)altCertificate complete:(ReadP12CompleteHandler)callBack {
        
    NSData *altCertificateP12Data = [altCertificate p12Data];

    BIO *inputP12Buffer = BIO_new(BIO_s_mem());
    BIO_write(inputP12Buffer, altCertificateP12Data.bytes, (int)altCertificateP12Data.length);

    auto inputP12 = d2i_PKCS12_bio(inputP12Buffer, NULL);

    // Extract key + certificate from .p12.
    EVP_PKEY *key;
    X509 *usrCert;
    char* p = NULL;

    PKCS12_parse(inputP12, "", &key, &usrCert, NULL);

    if (usrCert)
    {
        fprintf(stdout, "Subject:");
        p = X509_NAME_oneline(X509_get_subject_name(usrCert), NULL, 0);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
            ASN1_TIME* before = X509_get_notBefore(usrCert);
            long start_time = [self readRealTimeForX509:(char *)before->data];

            ASN1_TIME* after = X509_get_notAfter(usrCert);
            long expire_time = [self readRealTimeForX509:(char *)after->data];

            //读取证书内容
            NSDictionary* subject = [self readSubjectFormX509:p];

            P12CertificateInfo *certInfo = [[P12CertificateInfo alloc] init];
            certInfo.name = subject[@"CN"];
            certInfo.organization = subject[@"O"];
            certInfo.organizationUnit = subject[@"OU"];
            certInfo.userID = subject[@"UID"];
            certInfo.country = subject[@"C"];
            certInfo.startTime = start_time;
            certInfo.expireTime = expire_time;
            
            NSDate *today = [[NSDate alloc] init];
            
            
            if (today.timeIntervalSince1970 > certInfo.expireTime) {
                certInfo.revoked = YES;
            } else {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:altCertificate.serialNumber]) {
                    certInfo.revoked = YES;
                } else {
                    //9月之后苹果新增G3类型的根证书，这里需要区分
                    bool g3 = [self isG3ForX509:usrCert];
                    bool revoked = isP12Revoked(usrCert, g3);
                    certInfo.revoked = revoked;
                    if (revoked) {
                        [[NSUserDefaults standardUserDefaults] setBool:revoked forKey:altCertificate.serialNumber];
                    }
                }
            }
            callBack(certInfo);
        });
    }
    
}

//- (void)readP12:(NSString *)p12_path pwd:(NSString *)pwd {
//
//    PKCS12 *p12 = NULL;
//    X509* usrCert = NULL;
//    EVP_PKEY* pkey = NULL;
//    STACK_OF(X509)* ca = NULL;
//    char* password = (char*)[pwd cStringUsingEncoding:NSUTF8StringEncoding];
//
//    BIO*bio = NULL;
//    char* p = NULL;
//
//    bio = BIO_new_file([p12_path UTF8String], "r");
//    p12 = d2i_PKCS12_bio(bio, NULL); //得到p12结构
//    BIO_free_all(bio);
//    PKCS12_parse(p12, password, &pkey, &usrCert, &ca); //得到x509结构
//    if (usrCert)
//    {
//        fprintf(stdout, "Subject:");
//        p = X509_NAME_oneline(X509_get_subject_name(usrCert), NULL, 0);
//
//        //读取证书内容
//        NSDictionary* subject = [self readSubjectFormX509:p];
//        NSLog(@"证书结构：%@",subject);
//        NSString* country = subject[@"U"];
//        NSString* name = subject[@"CN"];
//        NSString* organization = subject[@"O"];
//        NSString* organization_unit = subject[@"OU"];
//        NSString* user_ID = subject[@"UID"];
////        NSString* country = subject[@"C"];
//
//        ASN1_TIME* before = X509_get_notBefore(usrCert);
//        long start_time = [self readRealTimeForX509:(char *)before->data];
//
//        ASN1_TIME* after = X509_get_notAfter(usrCert);
//        long expire_time = [self readRealTimeForX509:(char *)after->data];
//
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            //9月之后苹果新增G3类型的根证书，这里需要区分
//            bool g3 = [self isG3ForX509:usrCert];
//            bool revoked = isP12Revoked(usrCert, g3);
//        });
//    }
//}
    
- (long)readRealTimeForX509:(char *)x509data{
    NSString* x509TimeString = [NSString stringWithUTF8String:x509data];
    if (x509TimeString.length<12) {
        return 0;
    }
    NSString* timeStr = [NSString stringWithFormat:@"20%@-%@-%@ %@:%@:%@",[x509TimeString substringWithRange:NSMakeRange(0, 2)], [x509TimeString substringWithRange:NSMakeRange(2, 2)], [x509TimeString substringWithRange:NSMakeRange(4, 2)], [x509TimeString substringWithRange:NSMakeRange(6, 2)], [x509TimeString substringWithRange:NSMakeRange(8, 2)], [x509TimeString substringWithRange:NSMakeRange(10, 2)]];
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    format.timeZone = [NSTimeZone systemTimeZone];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate = [format dateFromString:timeStr];
    long time = (long)[fromdate timeIntervalSince1970] + 8*60*60;
    return time;
}

- (NSDictionary *)readSubjectFormX509:(char *)x509data{
    NSMutableDictionary* mdic = [NSMutableDictionary dictionary];
    NSString* x509String = [NSString stringWithUTF8String:x509data];
    NSArray* objs = [x509String componentsSeparatedByString:@"/"];
    for (NSString* obj in objs) {
        NSArray* content = [obj componentsSeparatedByString:@"="];
        if (content.count == 2) {
            NSDictionary* dic = @{content.firstObject:content.lastObject};
            [mdic addEntriesFromDictionary:dic];
        }
    }
    return mdic.copy;
}

- (bool)isG3ForX509:(X509*)usrCert{
    unsigned long issuerHash = X509_issuer_name_hash(usrCert);
    return issuerHash != 0x817d2f7a;
    /*
    X509* usrCert = x509;
    X509_NAME* name = X509_get_issuer_name(usrCert);
    char* x509Data = X509_NAME_oneline(name, NULL, 0);
    NSDictionary* subject = [self readSubjectFormX509:x509Data];
    NSString* ou = [subject objectForKey:@"OU"];
    BOOL G3 = ou && [ou isEqualToString:@"G3"];
    return G3;
     */
}
    
    
@end
