# trashbin

## Name

**rm** -- It's like `rm`, but for macOS Trash.

## Synopsis

You can use `trashbin` in the same form and syntax as `rm` to move files or directories to the Trash of macOS.
Additionally, there are some new options related to macOS's Trash management listed in the next section (**-l** and **-e**).
This utility is designed for all those who want a "safety net" for deleting files through the command line.

    trashbin [-f | -i] [-dRrsvW] file ... [-el]
    send file(s) to the trash (or unlink them with the u option)

## Description

The `trashbin` utility attempts to trash the non-directory type files specified on the command line.  If the
permissions of the file do not permit writing, the user is prompted (on the standard output) for confirmation.

The options are as follows:

**-d**  Attempt to trash directories as well files, if they are empty.

**-e**  Empty out the trash (unlinks files in the trash).

**-f**  Attempt to trash/unlink the files without prompting for confirmation, regardless of the file's permissions.  If the file does not exist, do not display a diagnostic message or modify the exit status to reflect an error. The **-f** option overrides any previous **-i** options.

**-i**  Request confirmation before attempting to trash/unlink each file, regardless of the file's permissions, or whether or not the standard input device is a terminal. The -i option overrides any previous -f options.

**-P**  Overwrite files before deleting them.  Files are overwritten three times, first with the byte pattern 0xff, then 0x00, and then 0xff again, before they are deleted. Must be used in combination with **-u** and not with **-d** or **-r**

**-l**  List all files in the trash.

**-r**  Attempt to trash directories as well files even if they aren't empty.

**-R**  Same as **-r**

**-s**  Shows total size of files and directories being trashed or listed or unlinked. If used
with **-v** option, also prints every file or directory size.

**-u**  Instead of trashing files, unlinks them (`rm` behavior)

**-v**  Be verbose when trashing/unlinking files, showing them as they are removed. See also the **-s** option


## Compatibility

macOS only.
