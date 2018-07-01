//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

private enum CheckPreTrashResult: Equatable {
	case noAttentionNeeded
	case ownedBySomeoneElse(by: String)
	case readOnly
}

private enum FileCheckResult {
	case doesntExist, isFile, isDirectory
}

private func checkPreTrash(_ url: URL) -> CheckPreTrashResult {
	let path = url.path

	// check ownership
	if let owner = Constants.fileManager.ownerOfItem(atPath: path) {
		if owner != Constants.userName {
			return .ownedBySomeoneElse(by: owner)
		}
	}

	// check write permission
	if let ownerWritable = try? Constants.fileManager
		.itemPermissions(atPath: path)
		.contains(FileManager.PosixPermission.ownerWritable) {

		if !ownerWritable {
			return .readOnly
		}
	}

	// no problems found
	return .noAttentionNeeded
}

func execute(_ urls: [URL]) -> Int64? {
	func checkItem(_ url: URL) -> FileCheckResult {
		if Constants.fileManager.fileExists(atPath: url.path) {
			if Constants.fileManager.isDirectory(atPath: url.path) {
				return .isDirectory
			} else {
				return .isFile
			}
		} else {
			return .doesntExist
		}
	}

	var total: Int64 = 0

	for url in urls {
		switch checkItem(url) {
		case .doesntExist:
			if !options.force {
				printError("\(url.path): No such file or directory")
			}
		case .isFile:
			total += execute(url)
		case .isDirectory:
			if options.directories {
				if options.recursive {
					total += execute(url)
				} else {
					if let isEmpty = Constants.fileManager.isDirectoryEmpty(atPath: url.path) {
						if isEmpty {
							total += execute(url)
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

	return options.showSize ? total : nil
}

private func overwriteFile(_ url: URL) throws {
	try overwriteFile(url, pattern: 0xFF)
	try overwriteFile(url, pattern: 0x00)
	try overwriteFile(url, pattern: 0xFF)
}

private func overwriteFile(_ url: URL, pattern: UInt8) throws {
	let size = Constants.fileManager.sizeOfFile(atPath: url.path)
	let fh = try FileHandle(forWritingTo: url)
	fh.seek(toFileOffset: 0)
	assert(fh.offsetInFile == 0)

	let blockSize: Int64 = 4096 // APFS block size = 4KB
	let blocks = size / blockSize
	let remaining = size - (blocks*blockSize)

	var block = Data(capacity: Int(blockSize))
	for _ in 0..<blockSize {
		block.append(pattern)
	}

	let byte = Data(bytes: [pattern])

	for _ in 0..<blocks {
		fh.write(block)
	}
	for _ in 0..<remaining {
		fh.write(byte)
	}

	fh.synchronizeFile()
	fh.closeFile()
}

func execute(_ url: URL) -> Int64 {
	let path = url.path
	var needsUserConfirmation = false
	let check: CheckPreTrashResult = checkPreTrash(url)

	if !options.force {
		//-f not used, ask if the user really wants to delete file if not a regular file
		switch check {
		case .noAttentionNeeded:
			needsUserConfirmation = true
		case .ownedBySomeoneElse(by: let owner):
			if !Constants.userIsRoot {
				needsUserConfirmation = promptYesOrNo(
					question: "\(path) is owned by \(owner), \(options.actionPresent) anyway?",
					questionType: .differentOwner)
			} else {
				needsUserConfirmation = true
			}
		case .readOnly:
			needsUserConfirmation = promptYesOrNo(
				question: "File \(path) is read-only, \(options.actionPresent) anyway?",
				questionType: .readOnly)
		}
	} else {
		//user has forced, no need for confirmation
		needsUserConfirmation = true
	}

	if options.interactive && check == .noAttentionNeeded {
		switch check {
		case .noAttentionNeeded:
			if needsUserConfirmation {
				needsUserConfirmation = promptYesOrNo(question: "\(options.actionPresent.capitalized) \(path)?",
					questionType: .promptDeletion)
			}
		default:
			needsUserConfirmation = true // already asked, no need to ask again
		}
	}

	if needsUserConfirmation {
		do {
			var size: Int64?

			if options.showSize {
				size = Constants.fileManager.sizeOfItem(atPath: path)
			}

			if options.verbose {
				fileInfoPrint(path: path,
							  size: size,
							  emoji: (options.unlink ? "🔗" : "🗑 "))
			}

			if options.overwrite {
				try overwriteFile(url)
			}

			if options.unlink {
				try Constants.fileManager.removeItem(at: url)
				return size ?? 0
			} else {
				try Constants.fileManager.trashItem(at: url, resultingItemURL: nil)
				return size ?? 0
			}

		} catch {
			printError(error.localizedDescription)
			return 0
		}
	} else {
		print("\(path) not \(options.actionPast)")
		return 0
	}

}
