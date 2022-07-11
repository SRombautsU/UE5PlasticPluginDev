"""
Command-line tool to check C/C++ files for style issues
"""

import argparse
import os
import sys
from pathlib import Path
from cpplint import cpplint


def find_files_in_directory(path, excluded_subdirectories=None, extensions_list=None, recursive=False, only_writable_files=False):
    """Find files from a given directory (recursively)
    @param source: the path of the directory you want to process (relative to project root)
    @param excluded_subdirectories: a list of excluded sub-directory, accept all if empty
    @param extensions_list: a list of accepted extensions, accept all if empty
    @param recursive: travel folder recursively
    @param only_writable_files: if True will only look for writable files
    @return: the list of writable files
    """
    file_list = []
    paths = Path(path).rglob("*") if recursive else Path(path).glob("*")
    for path in paths:
        if not path.is_file():
            continue

        if excluded_subdirectories is None or not bool(set(excluded_subdirectories).intersection(path.parts[:-1])):  # excluded dir
            if extensions_list is None or path.suffix in extensions_list:  # extensions filter
                if not only_writable_files or os.access(path, os.W_OK):  # writable filter
                    file_list.append(str(path))

    return file_list


def call_cpplint(file_list):
    """use cpplint with arguments without creating a subprocess
    @param file_list: the file list to process
    """

    cpplint_args = [
        "--quiet",
        "--output=vs7",
        "--verbose=2",
        "--filter=-whitespace/tab,-whitespace/braces,-whitespace/indent,-whitespace/line_length,-whitespace/newline,-readability/inheritance,-readability/todo,-runtime/references",
    ]
    # -whitespace/comments,

    cpplint.ParseArguments(cpplint_args)
    cpplint._cpplint_state.ResetErrorCounts()

#    print(f"Run cpplint on {len(file_list)} writable file(s):\n- " + "\n- ".join(file_list) + "\n")
#    sys.stdout.flush()

    for filename in file_list:
        print(f"Run cpplint on {filename}")
        sys.stdout.flush()
        cpplint.ProcessFile(filename, cpplint._cpplint_state.verbose_level)
    # If --quiet is passed, suppress printing error count unless there are errors.
    if not cpplint._cpplint_state.quiet or cpplint._cpplint_state.error_count > 0:
        cpplint._cpplint_state.PrintErrorCounts()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--source", help="Source directory", nargs="?", default="Source")
    parser.add_argument(
        "--exclude",
        help="Exclude sub-directories from sources",
        nargs="+",
        default=["SpatialOS", "ThirdParty"],
    )
    args = parser.parse_args()

    # Search writable C++ source files
    cpp_extensions = (".cpp", ".h")
    file_list = find_files_in_directory(args.source, excluded_subdirectories=args.exclude, extensions_list=cpp_extensions, recursive=True, only_writable_files=True)

    if len(file_list) > 0:
        call_cpplint(file_list)
    else:
        print("No source file to cpplint")
