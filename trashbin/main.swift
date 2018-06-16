//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

let programPath = CommandLine.arguments.first!
let pathUrl = URL(fileURLWithPath: programPath)
let programName = pathUrl.lastPathComponent

// print(CommandLine.arguments.first!)

let fileManager = FileManager.default
let currentUser = NSUserName()
let bcf = ByteCountFormatter()
bcf.allowedUnits = [ByteCountFormatter.Units.useAll]
bcf.countStyle = ByteCountFormatter.CountStyle.file

processOptions()

let fileUrls = processInputFiles()

if !fileUrls.isEmpty {
	trash(fileUrls)
}
else if (!listTrash && !emptyOut) {
	print("Usage: \(programName) [-f | -i] [-dRrsvW] file ... [-el]")
	print("       send files to the trash (or unlink them with the u option)")
}

if listTrash {
	listTrashBin()
}

if emptyOut {
	emptyTrash()
}
