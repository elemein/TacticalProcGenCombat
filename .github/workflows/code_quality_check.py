"""
This script will be used to check for various code quality issues throughout the project
"""

import os
import string


class Colour:
    """
    A List of colours we can use to make the output more readable
    """
    red = '\033[91m'
    green = '\033[92m'
    reset = '\033[0m'


class IssueChecker:
    """
    Check for any desired code quality issues throughout the project
    """
    def __init__(self):
        self.current_file = None
        self.issues = {
            'setget': [],
            'using_self': [],
            'type_hinting': [],
            'sync_queue': [],
            'file_types': [],
        }

        self.run_all_checks()

    def run_all_checks(self):
        """
        Run all of the checks we want to look for
        """
        for path, _, files in os.walk('../../'):
            for file in files:
                if file[-3:] == '.gd':
                    self.current_file = f'{path}/{file}'

                    self.check_setget()
                    self.check_using_self()
                    self.check_type_hinting()
                    self.check_sync_queue()
                self.check_file_types()
        self.print()

    def check_setget(self):
        """
        Verify every class variable uses setget methods
        """
        with open(self.current_file, 'r') as my_file:
            for line in my_file.readlines():
                if line[:4] == 'var ' and 'setget' not in line and '#ignore' not in line:
                    self.issues['setget'].append(f'{self.current_file}\t{line}')

    def check_using_self(self):
        """
        Verify that every class variable is referenced by using "self." throughout the script.
        """
        # if 'Assets\GUI\CharacterSelect/AbilitySelectButton.gd' not in self.current_file:
        #     return
        with open(self.current_file, 'r') as my_file:
            file_contents = my_file.readlines()
        for orig_line in file_contents:
            if orig_line[:4] == 'var ' and '#ignore' not in orig_line \
                    or orig_line[:12] == 'onready var ' and '#ignore' not in orig_line:
                if orig_line[:3] == 'var':
                    var_name = orig_line.split()[1]
                else:
                    var_name = orig_line.split()[2]
                # if var_name != 'icon_path':
                #     continue

                # Check if the variable was using without referencing it with self.
                for reference_line in file_contents:
                    if reference_line != orig_line and var_name in reference_line \
                            and 'self.' != reference_line[:reference_line.find(var_name)][-5:] \
                            and reference_line[:reference_line.find(var_name)][-1:] not in string.ascii_letters \
                            and reference_line[:reference_line.find(var_name)][-1:] not in ['_', '.', "'"] \
                            and reference_line[reference_line.find(var_name) + len(var_name):][0] not in string.ascii_letters \
                            and reference_line[reference_line.find(var_name) + len(var_name):][0] not in ['_', "'"]:
                        self.issues['using_self'].append(f'{self.current_file}\t'
                                                         f'var: {Colour.red}{var_name}{Colour.reset}\t'
                                                         f'{reference_line[:reference_line.find(var_name)]}'
                                                         f'{Colour.red}{var_name}{Colour.reset}'
                                                         f'{reference_line[reference_line.find(var_name) + len(var_name):]}')

    def check_type_hinting(self):
        """
        Verify that every variable definition uses type hinting
        """
        with open(self.current_file, 'r') as my_file:
            for line in my_file.readlines():
                if line.strip()[:4] == 'var ' and ' :' not in line and '#ignore' not in line:
                    self.issues['type_hinting'].append(f'{self.current_file}\t{line}')

    def check_sync_queue(self):
        """
        Verify that every server call uses the sync queue
        """

    def check_file_types(self):
        """
        Verify that the correct file types only exist in the expected directories
        """

    def print(self):
        """
        Print the results of the checks
        """
        issues_present = False
        for issue_type in self.issues:
            print(f'::group::{issue_type}')
            for issue in self.issues[issue_type]:
                print(issue[6:].strip())
                issues_present = True
            print('::endgroup::')

        if issues_present:
            print(f'Failed to pass all code quality checks.\n'
                  f'setget: {len(self.issues["setget"])}\n'
                  f'using_self: {len(self.issues["using_self"])}\n'
                  f'type_hinting: {len(self.issues["type_hinting"])}\n'
                  f'sync_queue: {len(self.issues["sync_queue"])}\n'
                  f'file_types: {len(self.issues["file_types"])}\n')
            raise Exception


if __name__ == '__main__':
    IssueChecker()
