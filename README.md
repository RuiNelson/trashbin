# trashbin

## Name

**rm** -- It's like `rm`, but for macOS Trash.

## Synopsis

You can use `trashbin` in the same form and syntax as `rm`. Additionally, there are some new
options related to macOS's trash bin management listed in the next section (**-l** and **-e**). This
utility is designed for all those who want a "safety net" for deleting files through the
command line.

    trashbin [-f | -i] [-dRrsvW] file ... [-el]
    send file(s) to the trash (or unlink them with the u option)

## Description

The `trashbin` utility attempts to trash the non-directory type files specified on the command
line.  If the permissions of the file do not permit writing, and the standard input device is a
terminal, the user is prompted (on the standard output) for confirmation.

The options are as follows:

**-d** Attempt to trash directories as well files, if they are empty.

**-e** Empty out the trash (unlinks files in the trash).

**-f** Attempt to trash the files without prompting for confirmation, regardless of the file's
permissions.

**-i** Asks for user permission for each file to be trashed.

**-l** List all files in the trash.

**-r** Attempt to trash directories as well files even if they aren't empty.

**-R** Same as **-r**

**-s** Shows total size of files and directories being trashed or listed or unlinked. If used
with **-v** option, also prints every file or directory size.

**-u** Instead of trashing files, unlinks them (`rm` behavior)

**-v** Prints out every file or directory being trashed or listed or unlinked. See also the **-s** option


## Compatibility

macOS only.
