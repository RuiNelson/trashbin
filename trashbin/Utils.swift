//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation
import Darwin

extension Character {
	var lowerCased : Character {
		return self.description.lowercased().first!
	}
}

func printError(_ message: String) {
	fputs("🛑 " + programName + ": " + message + "\n", stderr)
}

func printWarning(_ mesage : String) {
	print("⚠️ " + mesage)
}

enum QuestionType : Int {
	case differentOwner, readOnly, promptDeletion
}

var alwaysYesForQuestionType : Set<QuestionType> = []

func promptYesOrNo(question: String, questionType: QuestionType) -> Bool {
	fputs("⚠️ \(question) " + (" [Y/N/A] "), stdout)
	
	if alwaysYesForQuestionType.contains(questionType) {
		print("Y")
		return true
	}
	
	
	var reply: String? = nil

	while reply == nil {
		reply = readLine()
		if let rFirst = reply?.first {
			switch rFirst.lowerCased {
			case "y": return true
			case "n": return false
			case "a": alwaysYesForQuestionType.insert(questionType)
				return true
			default:
				print("Invalid answer, reply with Y (yes), N (no) or A (always yes)\n\(question)")
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

func fileInfoPrint(path: String, size: Int64?, emoji: String? = nil) {
	var line = ""
	
	if let emoji = emoji {
		line += emoji + " "
	}
	
	line += path
	
	if let fileSize = size {
		line += " "
		line += "(" + bcf.string(fromByteCount: fileSize) + ")"
	}
	
	print(line)
}
