import ArgumentParser
import Darwin
import Foundation

enum OperatingMode {
    case trash, delete
}

enum Interactivity {
    case none, interactive, lessIntrusive
}

enum Verbosity {
    case none, showFiles, showFilesAndSize
}

@main
struct trashbin: ParsableCommand {
    @Flag(name: .short, help: "Attempt to remove directories as well as other types of files.")
    var directories = false

    @Flag(
        name: .short,
        help:
            "Attempt to remove the files without prompting for confirmation, regardless of the file's permissions.  If the file does not exist, do not display a diagnostic message or modify the exit status to reflect an error.  The -f option overrides any previous -i options."
    )
    var force = false

    @Flag(
        name: .short,
        help:
            "Request confirmation before attempting to remove each file, regardless of the file's permissions, or whether or not the standard input device is a terminal.  The -i option overrides any previous -f options."
    )
    var interactive = false

    @Flag(
        name: .customShort("I", allowingJoined: true),
        help:
            "Request confirmation once if more than three files are being removed or if a directory is being recursively removed.  This is a far less intrusive option than -i yet provides almost the same level of protection against mistakes."
    )
    var interactiveLessIntrusive = false

    @Flag(
        name: .customShort("P", allowingJoined: true),
        help: "This flag has no effect.  It is kept only for backwards compatibility with 4.4BSD-Lite2."
    )
    var pflag = false

    @Flag(
        name: [.customShort("r", allowingJoined: true), .customShort("R", allowingJoined: true)],
        help:
            "Attempt to remove the file hierarchy rooted in each file argument.  The -R option implies the -d option.  If the -i option is specified, the user is prompted for confirmation before each directory's contents are processed (as well as before the attempt is made to remove the directory).  If the user does not respond affirmatively, the file hierarchy rooted in that directory is skipped."
    )
    var recursive = false

    @Flag(name: .short, help: "Be verbose when deleting files, showing them as they are removed.")
    var verbose = false

    @Flag(
        name: .short,
        help:
            "Attempt to undelete the named files.  Currently, this option can only be used to recover files covered by whiteouts in a union file system (see undelete(2))."
    )
    var undelete = false

    @Flag(name: .short, help: "When removing a hierarchy, do not cross mount points.")
    var xrossMountNot = false

    @Argument(help: "files to be trashed", completion: CompletionKind.file())
    var files: [String]

    @Flag(name: .short, help: "Unlink files instead of trashing them")
    var unlink: Bool = false

    @Flag(name: .short, help: "Shows file size")
    var size: Bool = false

    @Flag(name: .short, help: "Lists all the files in the trash bin")
    var listTrash: Bool = false

    @Flag(name: .short, help: "Empties the trash bin at the end")
    var empty: Bool = false

    mutating func run() throws {
        let deletingFiles: [String] = glob(files)

        let mode: OperatingMode = unlink ? .delete : .trash

        let interactivity: Interactivity = {
            switch (interactive, interactiveLessIntrusive) {
            case (false, false): return .none
            case (true, false): return .interactive
            case (false, true): return .lessIntrusive
            case (true, true): return .interactive
            }
        }()

        let verbosity: Verbosity = {
            switch (verbose, size) {
            case (false, false): return .none
            case (false, true): return .showFilesAndSize
            case (true, false): return .showFiles
            case (true, true): return .showFilesAndSize
            }
        }()

        deleteFiles(mode: mode, files: deletingFiles, interactivity: interactivity, verbosity: verbosity)

    }
}

func glob(_: [String]) -> [String] {
    fatalError()
}

func deleteFiles(mode: OperatingMode, files: [String], interactivity: Interactivity, verbosity: Verbosity) {
    fatalError()
}

func collectTrashFiles() -> [String] {
    fatalError()
}

func listTrashFiles(files: [String], showSize: Bool) {
    fatalError()
}

func unlinkFiles(files: [String]) {
    fatalError()
}
