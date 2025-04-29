import glob
from pathlib import Path
import re


def getAll(extension: str):
    return sorted(glob.glob(f'**/*.{extension}', recursive=True))


def transform_imports(source: str) -> str:
    transformed_lines = []
    lines = source.splitlines()
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        if m := re.match(r'#import bevy_(.+)', line):
            path = m.group(1)
            if path.endswith('{'):
                transformed_lines.append(f'import bevy::{path}')
                j = i + 1 # skip #import line
                while j < len(lines) and not lines[j] == '}':
                    j += 1
                inside = '\n'.join(lines[i+1:j+1]) + ';'
                i = j
                transformed_lines.append(inside)
            else:
                transformed_lines.append(f'import bevy::{path};')

        else:
            transformed_lines.append(lines[i])
        
        i += 1
    
    return '\n'.join(transformed_lines) + '\n'
    

def transform_preproc(source: str) -> str:
    transformed_lines = []
    lines = source.splitlines()
    i = 0
    
    while i < len(lines):
        indent = len(re.match(r'^(\s*)', lines[i]).group(1))
        spaces = ' ' * indent
        line = lines[i].strip()
        
        if m := re.match(r'#ifdef (\w+)', line):
            transformed_lines.append(f'{spaces}@if({m.group(1)}) // {line}')
        
        elif m := re.match(r'#ifndef (\w+)', line):
            transformed_lines.append(f'{spaces}@if(!{m.group(1)}) // {line}')
            pass
        
        elif m := re.match(r'#else ifdef (\w+)', line):
            transformed_lines.append(f'{spaces}@elif({m.group(1)}) // {line}')
        
        elif m := re.match(r'#else', line):
            transformed_lines.append(f'{spaces}@else // {line}')
        
        elif re.match(r'#endif', line):
            transformed_lines.append(f'{spaces}// {line}')
        
        # elif line.startswith('#'):
        #     print(f'[WARN] unrecognized preproc: {line}')
        #     transformed_lines.append(f'{spaces}// TODO unrecognized preproc: {line}')
        
        else:
            transformed_lines.append(lines[i])
        
        i += 1
    
    return '\n'.join(transformed_lines) + '\n'


if __name__ == '__main__':
    wesl_files = getAll('wesl')

    for file in wesl_files:
        print(f'Converting file {file}')
        source = Path(file).read_text()
        source = transform_imports(source)
        source = transform_preproc(source)
        source = source.replace('bevy_', 'bevy::')
        Path(file).write_text(source)
