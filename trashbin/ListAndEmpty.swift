//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

func trashBinContents() -> [String] {
	var contents = [String]()
	// Local trash
	if let localTrashUrl = Constants.fileManager.urls(for: .trashDirectory, in: .userDomainMask).first {
		let localTrashPath = localTrashUrl.path
		do {
			let localTrashContents = try Constants.fileManager.contentsOfDirectoryWithPath(atPath: localTrashPath)
			contents.append(contentsOf: localTrashContents)
		} catch {
			printWarning("Couldn't access current user's Trash: " + error.localizedDescription)
		}
	}

	// iCloud Trash
	if let localLibraryUrl = Constants.fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
		let iCloudTrashUrl = localLibraryUrl
			.appendingPathComponent("Mobile Documents")
			.appendingPathComponent("com~apple~CloudDocs")
			.appendingPathComponent(".Trash")

		let iCloudTrashPath = iCloudTrashUrl.path

		if Constants.fileManager.isDirectory(atPath: iCloudTrashPath) {
			if let iCloudTrashContents = try? Constants
				.fileManager
				.contentsOfDirectoryWithPath(atPath: iCloudTrashPath) {
				contents.append(contentsOf: iCloudTrashContents)
			}
		}
	}

	// Volumes Trash
	do {
		let volumesPaths = try Constants.fileManager.contentsOfDirectoryWithPath(atPath: "/Volumes")
		for volumePath in volumesPaths {
			let volumeTrashesPath = volumePath + "/.Trashes"
			if Constants.fileManager.isDirectory(atPath: volumeTrashesPath) {
				do {
					let trashContents = try Constants.fileManager.contentsOfDirectoryWithPath(atPath: volumeTrashesPath)

					let numberedDirectoriesInTrashContents = trashContents.filter { (item) -> Bool in

						func lastPathComponentIsAnInteger(filePath: String) -> Bool {
							let lastPathComponent = URL(fileURLWithPath: filePath).lastPathComponent

							if let integer = Int(lastPathComponent) {
								return String(integer) == lastPathComponent
							} else {
								return false
							}
						}

						if Constants.fileManager.isDirectory(atPath: item) {
							if lastPathComponentIsAnInteger(filePath: item) {
								return true
							}
						}

						return false
					}

					let otherDirectoriesAndFilesInTrashContents = trashContents.filter { (item) -> Bool in
						return numberedDirectoriesInTrashContents.contains(item) == false
					}

					var trashContentsInDirectoriesWithNumbers: [String] = []

					for numberedDirectoryInTrashContents in numberedDirectoriesInTrashContents {
						do {
							try trashContentsInDirectoriesWithNumbers.append(contentsOf: Constants
								.fileManager
								.contentsOfDirectoryWithPath(atPath: numberedDirectoryInTrashContents))
						} catch {
							printWarning("Scanning for trashes in " + numberedDirectoryInTrashContents
								+ ": " + error.localizedDescription)
						}
					}

					contents.append(contentsOf: otherDirectoriesAndFilesInTrashContents)
					contents.append(contentsOf: trashContentsInDirectoriesWithNumbers)

				} catch {
					printWarning("Scanning for trashes in " + volumePath + ": " + error.localizedDescription)
				}
			}
		}
	} catch {
		printWarning("Can't access mounted volumes Trashes: " + error.localizedDescription)
	}

	return contents
}

func listTrashBin() -> Int64? {
	var total: Int64 = 0
	let contents = trashBinContents()

	if contents.isEmpty {
		print("Trash is empty")
		return nil
	}

	print("Trash content:")
	for content in contents {
		var size: Int64?

		if options.showSize {
			size = Constants.fileManager.sizeOfItem(atPath: content)
			total += size ?? 0
		}

		fileInfoPrint(path: content, size: size)
	}

	return options.showSize ? total : nil
}

func emptyTrash() -> Int64? {
	options.unlink = true
	options.directories = true
	options.recursive = true

	var total: Int64 = 0
	let contents = trashBinContents()

	if contents.isEmpty {
		printWarning("Trash is already empty")
		return nil
	}

	print("Emptying the trash...")
	for content in contents {
		let url = URL(fileURLWithPath: content)

		total += execute(url)
	}

	return options.showSize ? total : nil
}
