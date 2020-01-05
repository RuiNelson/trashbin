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
		case ownerReadable      = 0b100000000
		case ownerWritable      = 0b010000000
		case ownerExecutable    = 0b001000000
		case groupReadable      = 0b000100000
		case groupWriable       = 0b000010000
		case groupExecutable    = 0b000001000
		case allReadble         = 0b000000100
		case allWriable         = 0b000000010
		case allExecutable      = 0b000000001
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
		let contentsWithoutPath = try self.contentsOfDirectory(atPath: atPath)
		let path = atPath.hasSuffix("/") ? atPath : atPath + "/"
		let contentsWithPath = contentsWithoutPath.map({ return path + $0 })
		return contentsWithPath
	}

	func sizeOfDirectory(atPath: String) -> Int64 {
		if let children = try? subpathsOfDirectory(atPath: atPath) {

			let childrenFullPaths: [String] = children.map { (child) -> String in
				return atPath + "/" + child
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
