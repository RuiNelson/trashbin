//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation
import Darwin

enum ExitCodes : Int {
	case unknownOption = -1
	case unsupportedOption = -2
	case mutualExclusiveOptions = -3
	
	func exit() {
		Darwin.exit(Int32(self.rawValue))
	}
}

let programPath = CommandLine.arguments.first!
let pathUrl = URL(fileURLWithPath: programPath)
let programName = pathUrl.lastPathComponent

// print(CommandLine.arguments.first!)

let fileManager = FileManager.default
let bcf = ByteCountFormatter()
bcf.allowedUnits = [ByteCountFormatter.Units.useAll]
bcf.countStyle = ByteCountFormatter.CountStyle.file

processOptions()

let fileUrls = processInputFiles()

if !fileUrls.isEmpty {
	trash(fileUrls)
}
else if (!listTrash && !emptyOut && !userDidInputFiles) {
	print("Usage: \(programName) [-f | -i] [-dRrsvW] file ... [-el]")
	print("       send files to macOS trash (or unlink)")
}

if listTrash {
	listTrashBin()
}

if emptyOut {
	emptyTrash()
}
