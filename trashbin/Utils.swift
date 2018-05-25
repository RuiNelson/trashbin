//
//  Utils.swift
//  trashbin
//
//  Created by Rui Nelson Carneiro on 21/05/18.
//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.
//

import Foundation
import Darwin

func printError(_ message: String) {
	fputs(programName + ": " + message + "\n", stderr)
}

func promptYesOrNo(question: String) -> Bool {
	print("\(programName): \(question)")
	var reply: String? = nil

	while reply == nil {
		reply = readLine()
		if let rLower = reply?.lowercased() {
			switch rLower {
			case "y": return true
			case "n": return false
			default:
				print("Invalid answer, reply with Y or N. \(question)")
				reply = nil
			}
		}
	}

	fatalError()
}

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

		for matchNum in 0..<numberOfMatches {
			let match = String(cString: globType.gl_pathv[matchNum]!)
			result.append(match)
		}
	}

	return result
}

func fileInfoPrint(path: String, size: Int64?) {
	guard let size = size else {
		print(path)
		return
	}

	let humanReadable = bcf.string(fromByteCount: size)
	print(path + " (" + humanReadable + ")")
}
