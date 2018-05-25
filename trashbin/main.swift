//
//  main.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 21/05/18.
//  Copyright © 2018 Rui Nelson Carneiro. All rights reserved.
//

import Foundation

let programName = "trashbin"

// print(CommandLine.arguments.first!)

let fileManager = FileManager.default
let currentUser = NSUserName()
let bcf = ByteCountFormatter()
bcf.allowedUnits = [ByteCountFormatter.Units.useAll]
bcf.countStyle = ByteCountFormatter.CountStyle.file

var total: Int64 = 0

processOptions()

let fileUrls = processInputFiles()
trash(fileUrls)

if showSize && !fileUrls.isEmpty {
    print("Total \(actionPast): " + bcf.string(fromByteCount: total))
}

if listTrash {
 listTrashBin()
}

if emptyOut {
    emptyTrash()
}
