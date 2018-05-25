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

processOptions()

let fileUrls = processInputFiles()

if !fileUrls.isEmpty {
    trash(fileUrls)
}

if listTrash {
    listTrashBin()
}

if emptyOut {
    emptyTrash()
}
