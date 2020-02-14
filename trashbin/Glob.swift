//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Darwin
import Foundation

func glob(pattern: String) -> [String] {
    let globFlags: Int32 = GLOB_MARK | GLOB_NOESCAPE | GLOB_BRACE | GLOB_NOMAGIC | GLOB_TILDE
    return glob(pattern: pattern, globFlags: globFlags)
}

func glob(pattern: String, globFlags: Int32) -> [String] {
    func doGlob(pattern: UnsafePointer<Int8>, flags: Int32, globType: UnsafeMutablePointer<glob_t>) -> Int32 {
        return glob(pattern, flags, nil, globType)
    }

    var globType = glob_t()
    let pattern = strdup(pattern)!

    var result: [String] = []

    if doGlob(pattern: pattern, flags: globFlags, globType: &globType) == 0 {
        let numberOfMatches = Int(globType.gl_matchc)

        for matchNum in 0 ..< numberOfMatches {
            let match = String(cString: globType.gl_pathv[matchNum]!)
            result.append(match)
        }
    }

    return result
}
