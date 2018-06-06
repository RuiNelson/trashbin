//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

func trashBinContents() -> [String] {
	let trashHome = glob(pattern: "~/.Trash/*")
	let trashVolumes = glob(pattern: "/Volumes/*/.Trashes/*/*")
	let trashiCloud = glob(pattern: "~/Library/Mobile Documents/com~apple~CloudDocs/.Trash/*")
	
	let allTrashes = [trashHome, trashVolumes, trashiCloud]
	
	let flat = allTrashes.flatMap { (path) -> [String] in
		return path
	}
	
	return flat
}

func listTrashBin() {
	var total: Int64 = 0
	let contents = trashBinContents()
	
	if contents.isEmpty {
		print("Trash is empty")
		return
	}
	
	print("Trash contents:")
	for content in contents {
		var size: Int64?

		if showSize {
			size = fileManager.sizeOfItem(atPath: content)
			total += size ?? 0
		}

		fileInfoPrint(path: content, size: size)
	}

	if showSize {
		print("Total in trash: \(bcf.string(fromByteCount: total))")
	}
}

func emptyTrash() {
	unlink = true
	directories = true
	recursive = true

	var total: Int64 = 0
	let contents = trashBinContents()

	if contents.isEmpty {
		printError("Trash is already empty")
		return
	}
	
	print ("Emptying the trash...")
	for content in contents {
		let url = URL(fileURLWithPath: content)

		total += trash(url)
	}

	if showSize {
		print("Total unlinked: \(bcf.string(fromByteCount: total))")
	}
}
