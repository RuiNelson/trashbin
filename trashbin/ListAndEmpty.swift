//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation

func trashBinContents() -> [String] {
	var contents: [String] = []

	contents.append(contentsOf: glob(pattern: "~/.Trash/*"))
	contents.append(contentsOf: glob(pattern: "~/.Trash/.*"))

	contents.append(contentsOf: glob(pattern: "/Volumes/*/.Trashes/*/*"))
	contents.append(contentsOf: glob(pattern: "/Volumes/*/.Trashes/*/.*"))

	contents.append(contentsOf: glob(pattern: "~/Library/Mobile Documents/com~apple~CloudDocs/.Trash/*"))
	contents.append(contentsOf: glob(pattern: "~/Library/Mobile Documents/com~apple~CloudDocs/.Trash/.*"))

	contents = contents.filter({ (entry) -> Bool in
		return ( entry.hasSuffix("/../") || entry.hasSuffix("/./") ) == false

	})

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
