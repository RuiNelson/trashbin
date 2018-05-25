//
//  ListTrashBin.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 24/05/18.
//  Copyright © 2018 Rui Nelson Carneiro. All rights reserved.
//

import Foundation

func trashBinContents() -> [String] {
    let trashDirectory = "~/.Trash/*"
    return glob(pattern: trashDirectory)
}

func listTrashBin() {
    total = 0
    let contents = trashBinContents()
    
    print("Listing Trash of " + currentUser)
    for content in contents {
        var size: Int64?
        
        if showSize {
            size = fileManager.sizeOfItem(atPath: content)
            total += size!
        }
        
        fileInfoPrint(path: content, size: size)
    }
    
    if showSize {
        print("Total in trash: " + bcf.string(fromByteCount: total))
    }
}

func emptyTrash() {
    unlink = true
    directories = true
    recursive = true
    
    total = 0
    let contents = trashBinContents()
    
    print ("Emptying Trash of " + currentUser + "...")
    
    for content in contents {
        var size: Int64?
        
        if showSize {
            size = fileManager.sizeOfItem(atPath: content)
            total += size!
        }
        
        let url = URL(fileURLWithPath: content)
        
        trash(url)
    }
    
    if showSize {
        print("Total freed: " + bcf.string(fromByteCount: total))
    }
}
