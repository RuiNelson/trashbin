//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Darwin
import Foundation

let fileUrls = collectFiles()

// execute files
if !fileUrls.isEmpty {
	let trashed = execute(fileUrls)
	if let trashed = trashed {
		print("Total \(options.actionPast): \(Constants.byteCountFormatter.string(fromByteCount: trashed))")
	}
} else if !options.listTrash, !options.emptyOut {
	if userEnteredFiles {
		Constants.ExitCodes.noSuchFileOrDirectory.exit()
	} else {
		                         Constants.ExitCodes.badSyntax.exit()
	}
}

// Extra Functionality

// list trash contents if option is selected
if options.listTrash {
	let trashSize = listTrashBin()
	if let trashSize = trashSize {
		print("Trash size: \(Constants.byteCountFormatter.string(fromByteCount: trashSize))")
	}
}

// empty trash contents if option is selected
if options.emptyOut {
	let emptied = emptyTrash()
	if let emptied = emptied {
		print("Total emptied: \(Constants.byteCountFormatter.string(fromByteCount: emptied))")
	}
}

// quit normally
Constants.ExitCodes.normal.exit()
