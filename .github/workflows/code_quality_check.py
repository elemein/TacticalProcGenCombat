"""
This script will be used to check for various code quality issues throughout the project
"""

import os


class Formatter:
    """
    Automatically format any issues found to be in the group format for github pipelines
    """
    issues = {
        'setget': [],
        'using_self': [],
        'type_hinting': [],
        'sync_queue': [],
        'file_types': []
    }

    def print(self):
        issues_present = False
        for issue_type in self.issues:
            print(f'::group::{issue_type}')
            for issue in self.issues[issue_type]:
                print(issue[6:].strip())
                issues_present = True
            print('::endgroup::')

        if issues_present:
            raise Exception('Failed to pass all code quality checks')


class IssueChecker:
    """
    Check for any desired code quality issues throughout the project
    """
    def __init__(self):
        self.formatter = Formatter()
        self.current_file = None

        self.run_all_checks()

    def run_all_checks(self):
        for path, _, files in os.walk('../../'):
            for file in files:
                if file[-3:] == '.gd':
                    self.current_file = f'{path}/{file}'
                    with open(self.current_file, 'r') as my_file:
                        for line in my_file.readlines():
                            self.check_setget(line)
                            self.check_using_self(line)
                            self.check_type_hinting(line)
                            self.check_sync_queue(line)
                            self.check_file_types(line)
        self.formatter.print()

    def check_setget(self, line: str):
        if line[:4] == 'var ':
            if 'setget' not in line:
                self.formatter.issues['setget'].append(f'{self.current_file}\t{line}')

    def check_using_self(self, line: str):
        pass

    def check_type_hinting(self, line: str):
        pass

    def check_sync_queue(self, line: str):
        pass

    def check_file_types(self, line: str):
        pass


if __name__ == '__main__':
    IssueChecker()
