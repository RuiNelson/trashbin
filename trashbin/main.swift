//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation
import Darwin

enum ExitCodes: Int32 {
	case normal = 0
	case badSyntax = 64
	case mutualExclusiveOptions = 30
	case overwriteWithoutUnlink = 31
	case noSuchFileOrDirectory = 1

	func exit() {
		if self == .badSyntax {
			print("Usage: \(Constants.programName) [-f | -i] [-dPRrsuv] [-el] file ...")
			print("       send files to macOS trash (or unlink)")
		}

		Darwin.exit(self.rawValue)
	}
}

struct Constants {
	static var programName: String {
		let programPath = CommandLine.arguments.first!
		let pathUrl = URL(fileURLWithPath: programPath)
		return pathUrl.lastPathComponent
	}

	static let fileManager = FileManager.default

	static var byteCountFormatter: ByteCountFormatter {
		let bcf = ByteCountFormatter()
		bcf.allowedUnits = [ByteCountFormatter.Units.useAll]
		bcf.countStyle = ByteCountFormatter.CountStyle.file
		return bcf
	}

	static var userName = NSUserName()
	static var userIsRoot = NSUserName() == "root"
}

let fileUrls = collectFiles()

if !fileUrls.isEmpty {
	let trashed = execute(fileUrls)
	if let trashed = trashed {
		print("Total \(options.actionPast): \(Constants.byteCountFormatter.string(fromByteCount: trashed))")
	}
} else if !options.listTrash && !options.emptyOut {
	if userEnteredFiles {
		ExitCodes.noSuchFileOrDirectory.exit()
	} else {
		ExitCodes.badSyntax.exit()
	}
}

if options.listTrash {
	let trashSize = listTrashBin()
	if let trashSize = trashSize {
		print("Trash size: \(Constants.byteCountFormatter.string(fromByteCount: trashSize))")
	}
}

if options.emptyOut {
	let emptied = emptyTrash()
	if let emptied = emptied {
		print("Total emptied: \(Constants.byteCountFormatter.string(fromByteCount: emptied))")
	}
}

ExitCodes.normal.exit()
