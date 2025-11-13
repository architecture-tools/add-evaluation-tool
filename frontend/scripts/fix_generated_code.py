#!/usr/bin/env python3
"""
Post-generation fix script for openapi-generator Dart output.
Fixes known issues with union types generating empty classes with incomplete methods.
"""

import os
import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
NETWORK_SRC_DIR = SCRIPT_DIR.parent / "lib" / "network" / "src"


def fix_validation_error_loc_inner(file_path: Path):
    """Fix ValidationErrorLocInner class - empty class with incomplete methods."""
    if not file_path.exists():
        return False
    
    content = file_path.read_text()
    original_content = content
    
    # Fix constructor: ValidationErrorLocInner({ }) -> ValidationErrorLocInner()
    content = re.sub(
        r'ValidationErrorLocInner\(\s*\{\s*\}\s*\);',
        'ValidationErrorLocInner();',
        content
    )
    
    # Fix incomplete operator ==
    # Pattern: bool operator ==(Object other) => identical(this, other) || other is ValidationErrorLocInner &&
    content = re.sub(
        r'(bool operator ==\(Object other\) => identical\(this, other\) \|\| other is ValidationErrorLocInner) &&\s*$',
        r'\1;',
        content,
        flags=re.MULTILINE
    )
    
    # Fix incomplete hashCode
    # Pattern: int get hashCode =>\n    // ignore: unnecessary_parenthesis\n
    content = re.sub(
        r'(@override\s+int get hashCode =>)\s*\n\s*// ignore: unnecessary_parenthesis\s*\n',
        r'\1 0;\n',
        content
    )
    
    # Fix fromJson return statement
    # Pattern: return ValidationErrorLocInner(\n      );
    content = re.sub(
        r'return ValidationErrorLocInner\(\s*\);',
        'return ValidationErrorLocInner();',
        content
    )
    
    if content != original_content:
        file_path.write_text(content)
        return True
    return False


def fix_diagrams_api(file_path: Path):
    """Fix DiagramsApi - remove unnecessary null check for required parameter."""
    if not file_path.exists():
        return False
    
    content = file_path.read_text()
    original_content = content
    
    # Fix: Remove unnecessary null check for required 'file' parameter
    # Pattern: if (file != null) { ... mp.fields[r'file'] = file.field; mp.files.add(file); }
    # Since 'file' is required (non-nullable), the check is always true
    pattern = (
        r'if \(file != null\) \{\s*'
        r'hasFields = true;\s*'
        r'mp\.fields\[r\'file\'\] = file\.field;\s*'
        r'mp\.files\.add\(file\);\s*'
        r'\}'
    )
    replacement = (
        '// file is required, so no null check needed\n'
        '      hasFields = true;\n'
        '      mp.fields[r\'file\'] = file.field;\n'
        '      mp.files.add(file);'
    )
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    if content != original_content:
        file_path.write_text(content)
        return True
    return False


def main():
    """Apply all post-generation fixes."""
    print("🔧 Applying post-generation fixes...")
    
    fixed = False
    
    # Fix ValidationErrorLocInner
    validation_error_loc_inner = NETWORK_SRC_DIR / "model" / "validation_error_loc_inner.dart"
    if validation_error_loc_inner.exists():
        if fix_validation_error_loc_inner(validation_error_loc_inner):
            print("  ✅ Fixed ValidationErrorLocInner")
            fixed = True
    
    # Fix DiagramsApi
    diagrams_api = NETWORK_SRC_DIR / "api" / "diagrams_api.dart"
    if diagrams_api.exists():
        if fix_diagrams_api(diagrams_api):
            print("  ✅ Fixed DiagramsApi")
            fixed = True
    
    if not fixed:
        print("  ℹ️  No fixes needed")
    
    print("✅ Post-generation fixes complete!")


if __name__ == "__main__":
    main()

