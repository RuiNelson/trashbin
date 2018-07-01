//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

class Options {
	var directories = false
	var force = false
	var emptyOut = false
	var interactive = false
	var recursive = false
	var verbose = false
	var undelete = false
	var unlink = false
	var overwrite = false
	var showSize = false
	var listTrash = false

	var actionPresent: String {
		return unlink ? "delete" : "trash"
	}

	var actionPast: String {
		return unlink ? "deleted" : "trashed"
	}

	init() {
		while case let option = getopt(CommandLine.argc, CommandLine.unsafeArgv, "defilPRrsuvW:"), option != -1 {
			let opt = UnicodeScalar(CUnsignedChar(option))
			switch opt {
			case "d":
				directories = true
			case "e":
				emptyOut = true
			case "f":
				force = true
				interactive = false
			case "i":
				interactive = true
				force = false
			case "l":
				listTrash = true
			case "P":
				overwrite = true
			case "R", "r":
				recursive = true
				directories = true
			case "s":
				showSize = true
			case "u":
				unlink = true
			case "v":
				verbose = true
			case "W":
				undelete = true
			default:
				printError("Unknown option")
				ExitCodes.badSyntax.exit()
			}
		}

		// checkup
		if undelete {
			printError("Sorry, but this utility can't undelete files. You can use your macOS's trash bin to do that.")
			ExitCodes.badSyntax.exit()
		}
		if overwrite && !unlink {
			printError("For the overwrite option to be valid, the unlink option must also be used.")
			ExitCodes.overwriteWithoutUnlink.exit()
		}
		if overwrite && directories {
			printError("For the overwrite option to be valid, you can't add directories.")
			ExitCodes.overwriteWithDirectories.exit()
		}
		if interactive && force {
			printError("Options 'interactive' and 'force' are mutually exclusive.")
			ExitCodes.mutualExclusiveOptions.exit()
		}
	}

}

let options = Options()
