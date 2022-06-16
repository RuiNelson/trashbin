import ArgumentParser
import Darwin
import Foundation

@main
struct trashbin: ParsableCommand {
    @Flag(name: .short, help: "Attempt to remove directories as well as other types of files.")
    var directories = false

    @Flag(name: .short, help: "Attempt to remove the files without prompting for confirmation, regardless of the file's permissions.  If the file does not exist, do not display a diagnostic message or modify the exit status to reflect an error.  The -f option overrides any previous -i options.")
    var force = false

    @Flag(name: .short, help: "Request confirmation before attempting to remove each file, regardless of the file's permissions, or whether or not the standard input device is a terminal.  The -i option overrides any previous -f options.")
    var interactive = false

    @Flag(name: .customShort("I", allowingJoined: true), help: "Request confirmation once if more than three files are being removed or if a directory is being recursively removed.  This is a far less intrusive option than -i yet provides almost the same level of protection against mistakes.")
    var interactiveLessIntrusive = false

    @Flag(name: .customShort("P", allowingJoined: true), help: "This flag has no effect.  It is kept only for backwards compatibility with 4.4BSD-Lite2.")
    var pflag = false

    @Flag(name: [.customShort("r", allowingJoined: true), .customShort("R", allowingJoined: true)], help: "Attempt to remove the file hierarchy rooted in each file argument.  The -R option implies the -d option.  If the -i option is specified, the user is prompted for confirmation before each directory's contents are processed (as well as before the attempt is made to remove the directory).  If the user does not respond affirmatively, the file hierarchy rooted in that directory is skipped.")
    var recursive = false

    @Flag(name: .short, help: "Be verbose when deleting files, showing them as they are removed.")
    var verbose = false

    @Flag(name: .short, help: "Attempt to undelete the named files.  Currently, this option can only be used to recover files covered by whiteouts in a union file system (see undelete(2)).")
    var undelete = false

    @Flag(name: .short, help: "When removing a hierarchy, do not cross mount points.")
    var xrossMountNot = false

    mutating func run() throws {
        if interactive {
            force = false
        }

        if interactive {
            interactiveLessIntrusive = false
        }

    }
}
