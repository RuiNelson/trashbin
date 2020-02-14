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
                ()
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
                Constants.ExitCodes.badSyntax.exit()
            }
        }

        // checkup
        if undelete {
            printError("Sorry, but this utility can't undelete files. You can use your macOS's trash bin to do that.")
            Constants.ExitCodes.badSyntax.exit()
        }
        if interactive, force {
            printError("Options 'interactive' and 'force' are mutually exclusive.")
            Constants.ExitCodes.mutualExclusiveOptions.exit()
        }
    }
}

let options = Options()
