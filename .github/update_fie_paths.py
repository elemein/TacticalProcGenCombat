import os
import sys
import re


def get_all_file_extentions():
    file_ext = []
    for path, folders, files in os.walk(os.getcwd()):
        if any([True for bad_path in [".github", '.git', 'venv'] if f'{os.sep}{bad_path}{os.sep}' in path]):
            continue
        for file in files:
            if file.split('.')[-1] not in file_ext:
                file_ext.append(file.split('.')[-1])


# Get all the old references
old_assets = {}
for path, folders, files in os.walk(os.getcwd()):
    for file in files:
        if any([True for extension in ['.gd', '.tscn', '.godot', '.tres'] if file.endswith(extension)]):
            with open(f'{path}{os.sep}{file}', 'r') as godot_file:
                file_contents = godot_file.read()

            if f'res://Assets' in file_contents:
                for bad_path in re.findall('["\']res:\/\/Assets.+?["\']', file_contents):
                    if len(bad_path) > 2:
                        if bad_path[1:-1] not in old_assets:
                            old_assets[bad_path[1:-1]] = {'bad_files': [f'{path}\\{file}']}
                        else:
                            old_assets[bad_path[1:-1]]['bad_files'].append(f'{path}\\{file}')

# Add any paths that have the same filename as the old asset
old_files = [file.split('/')[-1] for file in old_assets]
for path, dirs, files in os.walk(os.getcwd()):
    for file in files:

        if file in old_files:
            old_asset = [asset for asset in old_assets if asset.endswith(f'/{file}')][0]
            old_assets[old_asset]['old'] = old_asset
            old_assets[old_asset]['new'] = f'res://{path.split("TacticalProcGenCombat")[-1][1:].replace(os.sep, "/")}/{file}'
            old_assets[old_asset]['file_path'] = f'{path}\\{file}'

# Replace everything with just one match
for old_asset, info in old_assets.items():
    for file in info['bad_files']:
        print(f'Fixing: {file}')
        try:
            with open(file, 'r') as new_file:
                file_contents = new_file.read()

                new_contents = file_contents.replace(info['old'], info['new'])

            with open(file, 'w') as new_file:
                new_file.write(new_contents)

        except (UnicodeDecodeError, KeyError):
            print(f'Skipping: {old_asset}', file=sys.stderr)

print()