//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

extension FileManager {
    func isDirectory(atPath: String) -> Bool {
        var check: ObjCBool = false
        if fileExists(atPath: atPath, isDirectory: &check) {
            return check.boolValue
        } else {
            return false
        }
    }

    func isDirectoryEmpty(atPath: String) -> Bool? {
        if let contents = try? contentsOfDirectory(atPath: atPath) {
            return contents.isEmpty
        }
        return nil
    }

    func ownerOfItem(atPath: String) -> String? {
        if let attributes = try? attributesOfItem(atPath: atPath) {
            if let owner = attributes[FileAttributeKey.ownerAccountName] as? String {
                return owner
            }
        }
        return nil
    }

    enum PosixPermission: Int, CaseIterable {
        case ownerReadable = 0b1_0000_0000
        case ownerWritable = 0b0_1000_0000
        case ownerExecutable = 0b0_0100_0000
        case groupReadable = 0b0_0010_0000
        case groupWriable = 0b0_0001_0000
        case groupExecutable = 0b0_0000_1000
        case allReadble = 0b0_0000_0100
        case allWriable = 0b0_0000_0010
        case allExecutable = 0b0_0000_0001
    }

    func itemPermissions(atPath: String) throws -> [PosixPermission] {
        var permissions: [PosixPermission] = []
        let attributes = try attributesOfItem(atPath: atPath)

        if let posix = attributes[FileAttributeKey.posixPermissions] as? Int {
            for permission in PosixPermission.allCases where (posix & permission.rawValue) != 0 {
                permissions.append(permission)
            }
        }

        return permissions
    }

    func sizeOfFile(atPath: String) -> Int64 {
        guard isDirectory(atPath: atPath) == false else {
            return 0
        }

        if let attributes = try? attributesOfItem(atPath: atPath) {
            if let size = attributes[FileAttributeKey.size] as? Int64 {
                return size
            }
        }
        return 0
    }

    func contentsOfDirectoryWithPath(atPath: String) throws -> [String] {
        let contentsWithoutPath = try contentsOfDirectory(atPath: atPath)
        let path = atPath.hasSuffix("/") ? atPath : atPath + "/"
        let contentsWithPath = contentsWithoutPath.map { path + $0 }
        return contentsWithPath
    }

    func sizeOfDirectory(atPath: String) -> Int64 {
        if let children = try? subpathsOfDirectory(atPath: atPath) {
            let childrenFullPaths: [String] = children.map { (child) -> String in
                atPath + "/" + child
            }

            var totalSize: Int64 = 0

            for child in childrenFullPaths {
                let fileSize = sizeOfFile(atPath: child)
                totalSize += fileSize
            }

            return totalSize
        }
        return 0
    }

    func sizeOfItem(atPath: String) -> Int64 {
        if isDirectory(atPath: atPath) {
            return sizeOfDirectory(atPath: atPath)
        } else {
            return sizeOfFile(atPath: atPath)
        }
    }
}
