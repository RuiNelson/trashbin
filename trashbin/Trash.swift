//
//  trash.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 21/05/18.
//  Copyright © 2018 Rui Nelson Carneiro. All rights reserved.
//

import Foundation

func trash(_ urls: [URL]) {
    var total : Int64 = 0
    
    for url in urls {
        switch checkFile(url) {
        case .doesntExist:
            if !force {
                printError("\(url.path): No such file or directory")
            }
        case .isFile:
            total += trash(url)
        case .isDirectory:
            if directories {
                if recursive {
                    total += trash(url)
                } else {
                    if let isEmpty = fileManager.isDirectoryEmpty(atPath: url.path) {
                        if isEmpty {
                            total += trash(url)
                        } else {
                            printError("\(url.path): Directory not empty")
                        }
                    }
                }
            } else {
                printError("\(url.path): is a directory")
            }
        }
    }
    
    if showSize {
        print("\(actionPast.capitalized) \(bcf.string(fromByteCount: total))")
    }
}

func trash(_ url: URL) -> Int64 {
    let path = url.path
    var userConfirm = false
    let check: CheckTrashResult = checkTrash(url)

    if !force {
        //-f not used, ask if the user really wants to delete file if not a regular file
        switch check {
        case .noAttentionNeeded:
            userConfirm = true
        case .ownedBySomeoneElse(by: let owner):
            if currentUser != "root" {
                userConfirm = promptYesOrNo(question: "\(path) is owned by \(owner), \(actionPresent) anyway?")
            } else {
                userConfirm = true
            }
        case .readOnly:
            userConfirm = promptYesOrNo(question: "File \(path) is read-only, \(actionPresent) anyway?")
        }
    } else {
        //user has forced, no need for confirmation
        userConfirm = true
    }

    if interactive && check == .noAttentionNeeded {
        switch check {
        case .noAttentionNeeded:
            if userConfirm {
                userConfirm = promptYesOrNo(question: "\(actionPresent.capitalized) \(path)?")
            }
        default:
            userConfirm = true // already asked, no need to ask again
        }
    }

    if userConfirm {
        do {
            var size: Int64?

            if showSize {
                size = fileManager.sizeOfItem(atPath: path)
            }

            if verbose {
                fileInfoPrint(path: path, size: size)
            }

            if unlink {
                try fileManager.removeItem(at: url)
                return size ?? 0
            } else {
                try fileManager.trashItem(at: url, resultingItemURL: nil)
                return size ?? 0
            }

        } catch {
            let desc = error.localizedDescription
            printError("Could not \(actionPresent) \(path), because: \(desc)")
            return 0
        }
    } else {
        print("\(path) not \(actionPast)")
        return 0
    }

}
