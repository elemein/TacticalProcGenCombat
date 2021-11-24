"""
This script will be used to check for various code quality issues throughout the project
"""

import os
import string
import sys


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
    def __init__(self, fix_issues: bool = False):
        self.current_file_path: str = ''
        self.fix_issues: bool = fix_issues
        self.issues: dict = {
            'setget': [],
            'using_self': [],
            'type_hinting': [],
            'sync_queue': [],
            'file_types': [],
        }
        self.fixes: dict = {
            'setget': 0,
            'using_self': 0,
            'type_hinting': 0,
            'sync_queue': 0,
            'file_types': 0,
        }

        self.run_all_checks()

    def run_all_checks(self):
        """
        Run all of the checks we want to look for
        """
        os.chdir('../../')
        for path, _, files in os.walk(os.getcwd()):
            path = path.replace(f'{os.getcwd()}', '')
            path = path[1:] if path.startswith('\\') or path.startswith('/') else path

            # Ignored folders for the checks
            if any([True for bad_path in [".github", '.git', 'venv'] if path.startswith(bad_path)]):
                continue

            for file in files:

                # Ignored files for the checks
                if any([True for bad_extension in [".gitattributes", '.gitignore', 'LICENSE'] if
                        file.endswith(bad_extension)]):
                    continue

                self.current_file_path = f'{path}/{file}' if path != '' else file

                if file.endswith('.gd'):
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
        with open(self.current_file_path, 'r') as my_file:
            for line in my_file.readlines():
                if line[:4] == 'var ' and 'setget' not in line and '#ignore' not in line:
                    self.issues['setget'].append(f'{self.current_file_path}\t{line}')

    def check_using_self(self):
        """
        Verify that every class variable is referenced by using "self." throughout the script.
        """
        # if 'Assets\GUI\CharacterSelect/AbilitySelectButton.gd' not in self.current_file:
        #     return
        with open(self.current_file_path, 'r') as my_file:
            file_contents = my_file.readlines()

        file_modified = False
        for orig_line in file_contents:
            if '#ignore' not in orig_line:
                if orig_line[:4] == 'var ' or orig_line[:12] == 'onready var ' or orig_line[:11] == 'export var ' \
                        or orig_line[:8] == 'export (' or orig_line[:7] == 'export(':
                    if orig_line[:3] == 'var':
                        var_name = orig_line.split()[1]
                    elif orig_line[:8] == 'export (':
                        var_name = orig_line.split()[3]
                    else:
                        var_name = orig_line.split()[2]
                    # if var_name != 'icon_path':
                    #     continue

                    # Check if the variable was using without referencing it with self.
                    for cnt, reference_line in enumerate(file_contents):
                        if reference_line != orig_line and var_name in reference_line \
                                and 'self.' != reference_line[:reference_line.find(var_name)][-5:] \
                                and reference_line[:reference_line.find(var_name)][-1:] not in string.ascii_letters \
                                and reference_line[:reference_line.find(var_name)][-1:] not in ['_', '.', "'"] \
                                and reference_line[reference_line.find(var_name) + len(var_name):][0] not in string.ascii_letters \
                                and reference_line[reference_line.find(var_name) + len(var_name):][0] not in ['_', "'"] \
                                and reference_line.strip()[0] != '#' and reference_line[:4] != 'func':

                            if self.fix_issues:
                                file_contents[cnt] = f'{reference_line[:reference_line.find(var_name)]}self.{var_name}' \
                                                     f'{reference_line[reference_line.find(var_name) + len(var_name):]}'
                                file_modified = True
                                self.fixes['using_self'] += 1
                            else:
                                self.issues['using_self'].append(f'{self.current_file_path}\t'
                                                                 f'var: {Colour.red}{var_name}{Colour.reset}\t'
                                                                 f'{reference_line[:reference_line.find(var_name)]}'
                                                                 f'{Colour.red}{var_name}{Colour.reset}'
                                                                 f'{reference_line[reference_line.find(var_name) + len(var_name):]}')

        # Overwrite the original file if it was modified
        if file_modified:
            with open(self.current_file_path, 'w') as modified_file:
                for new_line in file_contents:
                    modified_file.write(new_line)

    def check_type_hinting(self):
        """
        Verify that every variable definition uses type hinting
        """
        with open(self.current_file_path, 'r') as my_file:
            for line in my_file.readlines():
                if line.strip()[:4] == 'var ' and ' :' not in line and '#ignore' not in line:
                    self.issues['type_hinting'].append(f'{self.current_file_path}\t{line}')

    def check_sync_queue(self):
        """
        Verify that every server call uses the sync queue
        """

    def check_file_types(self):
        """
        Verify that the correct file types only exist in the expected directories
        """
        file_extension = self.current_file_path.split(".")[-1]
        missed_message = f'{Colour.red}Missing file type: {file_extension}{Colour.reset}'

        match file_extension:
            case 'wav':
                if not self.current_file_path.startswith('Audio'):
                    self.issues['file_types'].append(f'Audio \t- {self.current_file_path}')
            case _:
                if missed_message not in self.issues['file_types']:
                    self.issues['file_types'].append(missed_message)

    def print(self):
        """
        Print the results of the checks
        """
        issues_present = False
        for issue_type in self.issues:
            print(f'::group::{issue_type}')
            for issue in self.issues[issue_type]:
                print(issue.strip())
                issues_present = True
            print('::endgroup::')

        if issues_present:
            print(f'Failed to pass all code quality checks.\n'
                  f'setget: {len(self.issues["setget"])}\n'
                  f'using_self: {len(self.issues["using_self"])}\n'
                  f'type_hinting: {len(self.issues["type_hinting"])}\n'
                  f'sync_queue: {len(self.issues["sync_queue"])}\n'
                  f'file_types: {len(self.issues["file_types"])}\n')
            sys.exit(1)

        if any([True for check in self.fixes if self.fixes[check] > 0]):
            print(f'The following number of issues were fixed automatically.\n'
                  f'setget: {self.fixes["setget"]}\n'
                  f'using_self: {self.fixes["using_self"]}\n'
                  f'type_hinting: {self.fixes["type_hinting"]}\n'
                  f'sync_queue: {self.fixes["sync_queue"]}\n'
                  f'file_types: {self.fixes["file_types"]}\n')


if __name__ == '__main__':
    IssueChecker(fix_issues=False)
