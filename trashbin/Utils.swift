//  Copyright © 2018 Rui Nelson Magalhães Carneiro. All rights reserved.

import Foundation
import Darwin

extension Character {
	var lowerCased: Character {
		return self.description.lowercased().first!
	}
}

extension String {
	mutating func addSpace() {
		self+=" "
	}
}

func printError(_ message: String) {
	fputs(Constants.programName + " 🛑 " + message + "\n\r", stderr)
}

func printWarning(_ mesage: String) {
	print(Constants.programName + " ⚠️  " + mesage)
}

enum QuestionType {
	case differentOwner, readOnly, promptDeletion
}

private var alwaysYesForQuestionType: Set<QuestionType> = []

func promptYesOrNo(question: String, questionType: QuestionType) -> Bool {
	fputs(Constants.programName + "❓ \(question) " + (" [Y/N/A] "), stdout)

	if alwaysYesForQuestionType.contains(questionType) {
		print("Y")
		return true
	}

	var reply: String? = nil

	while reply == nil {
		reply = readLine()
		if let rFirst = reply?.first {
			switch rFirst.lowerCased {
			case "y": fputs("\r", stdout); return true
			case "n": fputs("\r", stdout); return false
			case "a": alwaysYesForQuestionType.insert(questionType)
				return true
			default:
				printError("Invalid answer, reply with Y (yes), N (no) or A (always yes): \(question)")
				reply = nil
			}
		}
	}

	fatalError()
}

func fileInfoPrint(path: String, size: Int64?, emoji: String? = nil) {
	var line = ""

	if let emoji = emoji {
		line += emoji
		line.addSpace()
	}

	line += path

	if let fileSize = size {
		line.addSpace()
		let sizeString = "(" + Constants.byteCountFormatter.string(fromByteCount: fileSize) + ")"
		line += sizeString
	}

	print(line)
}
