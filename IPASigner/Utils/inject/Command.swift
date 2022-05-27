//
//  File.swift
//  
//
//  Created by paradiseduo on 2021/9/10.
//

import Foundation
import MachO

let byteSwappedOrder = NXByteOrder(rawValue: 0)

enum LC_Type: String {
    case REEXPORT_DYLIB = "LC_REEXPORT_DYLIB"
    case LOAD_WEAK_DYLIB = "LC_LOAD_WEAK_DYLIB"
    case LOAD_UPWARD_DYLIB = "LC_LOAD_UPWARD_DYLIB"
    case LOAD_DYLIB = "LC_LOAD_DYLIB"
    
    static func get(_ type: String) -> UInt32 {
        switch type {
        case LC_Type.REEXPORT_DYLIB.rawValue:
            return LC_REEXPORT_DYLIB
        case LC_Type.LOAD_WEAK_DYLIB.rawValue:
            return LC_LOAD_WEAK_DYLIB
        case LC_Type.LOAD_UPWARD_DYLIB.rawValue:
            return LC_LOAD_UPWARD_DYLIB
        case LC_Type.LOAD_DYLIB.rawValue:
            return UInt32(LC_LOAD_DYLIB)
        default:
            return 0
        }
    }
}

struct LoadCommand {
    
    static func couldInjectLoadCommand(binary: Data, dylibPath: String, type:BitType, isByteSwapped: Bool, handle: (Bool)->()) {
        if type == .x64_fat || type == .x86_fat || type == .none {
            handle(false)
            return
        }

        if type == .x86 {
            let header = binary.extract(mach_header.self)
            var offset = MemoryLayout.size(ofValue: header)
            for _ in 0..<header.ncmds {
                let loadCommand = binary.extract(load_command.self, offset: offset)
                switch loadCommand.cmd {
                case LC_REEXPORT_DYLIB, LC_LOAD_UPWARD_DYLIB, LC_LOAD_WEAK_DYLIB, UInt32(LC_LOAD_DYLIB):
                    var command = binary.extract(dylib_command.self, offset: offset)
                    if isByteSwapped {
                        swap_dylib_command(&command, byteSwappedOrder)
                    }
                    let curPath = String(data: binary, offset: offset, commandSize: Int(command.cmdsize), loadCommandString: command.dylib.name)
                    let curName = curPath.components(separatedBy: "/").last
                    if curName == dylibPath || curPath == dylibPath {
                        print("Load command already exists")
                        handle(false)
                        return
                    }
                    break
                default:
                    break
                }
                offset += Int(loadCommand.cmdsize)
            }
        } else {
            let header = binary.extract(mach_header_64.self)
            var offset = MemoryLayout.size(ofValue: header)
            for _ in 0..<header.ncmds {
                let loadCommand = binary.extract(load_command.self, offset: offset)
                switch loadCommand.cmd {
                case LC_REEXPORT_DYLIB, LC_LOAD_UPWARD_DYLIB, LC_LOAD_WEAK_DYLIB, UInt32(LC_LOAD_DYLIB):
                    var command = binary.extract(dylib_command.self, offset: offset)
                    if isByteSwapped {
                        swap_dylib_command(&command, byteSwappedOrder)
                    }
                    let curPath = String(data: binary, offset: offset, commandSize: Int(command.cmdsize), loadCommandString: command.dylib.name)
                    let curName = curPath.components(separatedBy: "/").last
                    if curName == dylibPath || curPath == dylibPath {
                        print("Load command already exists")
                        handle(false)
                        return
                    }
                    break
                default:
                    break
                }
                offset += Int(loadCommand.cmdsize)
            }
        }
        handle(true)
    }
    
    static func inject(binary: Data, dylibPath: String, cmd: UInt32, type:BitType, canInject: Bool, handle: (Data?)->()) {
        if canInject {
            var newbinary = binary
            let length = MemoryLayout<dylib_command>.size + dylibPath.lengthOfBytes(using: String.Encoding.utf8)
            let padding = (8 - (length % 8))
            let cmdsize = length+padding
            
            var start = 0
            var end = cmdsize
            var subData: Data
            var newHeaderData: Data
            var machoRange: Range<Data.Index>
            if type == .x86 {
                let header = binary.extract(mach_header.self)
                start = Int(header.sizeofcmds)+Int(MemoryLayout<mach_header>.size)
                end += start
                subData = newbinary[start..<end]
                
                var newheader = mach_header(magic: header.magic, cputype: header.cputype, cpusubtype: header.cpusubtype, filetype: header.filetype, ncmds: header.ncmds+1, sizeofcmds: header.sizeofcmds+UInt32(cmdsize), flags: header.flags)
                newHeaderData = Data(bytes: &newheader, count: MemoryLayout<mach_header>.size)
                machoRange = Range(NSRange(location: 0, length: MemoryLayout<mach_header>.size))!
            } else {
                let header = binary.extract(mach_header_64.self)
                start = Int(header.sizeofcmds)+Int(MemoryLayout<mach_header_64>.size)
                end += start
                subData = newbinary[start..<end]
                
                var newheader = mach_header_64(magic: header.magic, cputype: header.cputype, cpusubtype: header.cpusubtype, filetype: header.filetype, ncmds: header.ncmds+1, sizeofcmds: header.sizeofcmds+UInt32(cmdsize), flags: header.flags, reserved: header.reserved)
                newHeaderData = Data(bytes: &newheader, count: MemoryLayout<mach_header_64>.size)
                machoRange = Range(NSRange(location: 0, length: MemoryLayout<mach_header_64>.size))!
            }
            
            let d = String(data: subData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
            if d != "" {
                print("cannot inject payload into \(dylibPath) because there is no room")
                handle(nil)
                return
            }
            
            let dy = dylib(name: lc_str(offset: UInt32(MemoryLayout<dylib_command>.size)), timestamp: 2, current_version: 0, compatibility_version: 0)
            var command = dylib_command(cmd: cmd, cmdsize: UInt32(cmdsize), dylib: dy)
            
            var zero: UInt = 0
            var commandData = Data()
            commandData.append(Data(bytes: &command, count: MemoryLayout<dylib_command>.size))
            commandData.append(dylibPath.data(using: String.Encoding.ascii) ?? Data())
            commandData.append(Data(bytes: &zero, count: padding))
            
            let subrange = Range(NSRange(location: start, length: commandData.count))!
            newbinary.replaceSubrange(subrange, with: commandData)
            
            newbinary.replaceSubrange(machoRange, with: newHeaderData)
            
            handle(newbinary)
        } else {
            handle(nil)
        }
    }
    
    static func removeSignature(binary: Data, type:BitType, isWeak: Bool, handle: (Data?)->()) {
        if type == .x64_fat || type == .x86_fat || type == .none {
            handle(nil)
            return
        }
        var newbinary = binary
        var OP_SOFT_STRIP = 0x00001337
        if type == .x86 {
            let header = newbinary.extract(mach_header.self)
            var offset = MemoryLayout.size(ofValue: header)
            for _ in 0..<header.ncmds {
                let loadCommand = binary.extract(load_command.self, offset: offset)
                if loadCommand.cmd == UInt32(LC_CODE_SIGNATURE) {
                    let command = binary.extract(linkedit_data_command.self, offset: offset)
                    if isWeak {
                        var newheader = mach_header(magic: header.magic, cputype: header.cputype, cpusubtype: header.cpusubtype, filetype: header.filetype, ncmds: header.ncmds-1, sizeofcmds: header.sizeofcmds-UInt32(MemoryLayout<linkedit_data_command>.size), flags: header.flags)
                        let newHeaderData = Data(bytes: &newheader, count: MemoryLayout<mach_header>.size)

                        newbinary.replaceSubrange(Range(NSRange(location: 0, length: MemoryLayout<mach_header>.size))!, with: newHeaderData)
                        newbinary.replaceSubrange(Range(NSRange(location: offset, length: Int(command.cmdsize)))!, with: Data(count: Int(command.cmdsize)))
                        newbinary.replaceSubrange(Range(NSRange(location: Int(command.dataoff), length: Int(command.datasize)))!, with: Data(count: Int(command.datasize)))
                    } else {
                        newbinary.replaceSubrange(Range(NSRange(location: offset, length: 4))!, with: Data(bytes: &OP_SOFT_STRIP, count: 4))
                    }
                }
                offset += Int(loadCommand.cmdsize)
            }
        } else {
            let header = binary.extract(mach_header_64.self)
            var offset = MemoryLayout.size(ofValue: header)
            for _ in 0..<header.ncmds {
                let loadCommand = binary.extract(load_command.self, offset: offset)
                if loadCommand.cmd == UInt32(LC_CODE_SIGNATURE) {
                    let command = binary.extract(linkedit_data_command.self, offset: offset)
                    if isWeak {
                        var newheader = mach_header_64(magic: header.magic, cputype: header.cputype, cpusubtype: header.cpusubtype, filetype: header.filetype, ncmds: header.ncmds-1, sizeofcmds: header.sizeofcmds-UInt32(MemoryLayout<linkedit_data_command>.size), flags: header.flags, reserved: header.reserved)
                        let newHeaderData = Data(bytes: &newheader, count: MemoryLayout<mach_header_64>.size)

                        newbinary.replaceSubrange(Range(NSRange(location: 0, length: MemoryLayout<mach_header_64>.size))!, with: newHeaderData)
                        newbinary.replaceSubrange(Range(NSRange(location: offset, length: Int(command.cmdsize)))!, with: Data(count: Int(command.cmdsize)))
                        newbinary.replaceSubrange(Range(NSRange(location: Int(command.dataoff), length: Int(command.datasize)))!, with: Data(count: Int(command.datasize)))
                    } else {
                        newbinary.replaceSubrange(Range(NSRange(location: offset, length: 4))!, with: Data(bytes: &OP_SOFT_STRIP, count: 4))
                    }
                }
                offset += Int(loadCommand.cmdsize)
            }
        }
        handle(newbinary)
    }
    
    static func removeASLR(binary: Data, type:BitType, handle: (Data?)->()) {
        if type == .x64_fat || type == .x86_fat || type == .none {
            handle(nil)
            return
        }
        var newbinary = binary
        if type == .x86 {
            var header = newbinary.extract(mach_header.self)
            if (header.flags & UInt32(MH_PIE)) != 0 {
                header.flags &= 0xFFDFFFFF
                newbinary.replaceSubrange(Range(NSRange(location: 0, length: MemoryLayout<mach_header>.size))!, with: Data(bytes: &header, count: MemoryLayout<mach_header>.size))
            } else {
                handle(nil)
                return
            }
        } else {
            var header = binary.extract(mach_header_64.self)
            if (header.flags & UInt32(MH_PIE)) != 0 {
                header.flags &= 0xFFDFFFFF
                newbinary.replaceSubrange(Range(NSRange(location: 0, length: MemoryLayout<mach_header_64>.size))!, with: Data(bytes: &header, count: MemoryLayout<mach_header_64>.size))
            } else {
                handle(nil)
                return
            }
        }
        handle(newbinary)
    }
}
