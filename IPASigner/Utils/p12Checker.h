//
//  p12Checker.hpp
//  ABox
//
//  Created by SWING on 2022/4/12.
//

#include <openssl/x509.h>

bool isP12Revoked(X509 * x509, bool g3);
