#!/usr/bin/env python3
"""
Dependency checker for GenDetect project
This script verifies that all required Python packages are installed.
"""

import sys
import importlib
import subprocess

# Required packages with their import names and package names
DEPENDENCIES = [
    ('pandas', 'pandas'),
    ('numpy', 'numpy'),
    ('sklearn', 'scikit-learn'),
    ('scipy', 'scipy'),
    ('matplotlib.pyplot', 'matplotlib'),
    ('joblib', 'joblib'),
    ('xgboost', 'xgboost'),
    ('sentence_transformers', 'sentence-transformers'),
    ('tslearn', 'tslearn'),
    ('Levenshtein', 'python-Levenshtein'),
    ('openai', 'openai'),
    ('requests', 'requests'),
    ('pydantic', 'pydantic'),
    ('opensearchpy', 'opensearch-py'),
    ('opensearch_dsl', 'opensearch-dsl'),
    ('dune_client', 'dune-client'),
    ('tqdm', 'tqdm'),
]

def check_dependencies():
    """Check if all dependencies are installed."""
    missing = []
    installed = []
    
    print("🔍 Checking GenDetect dependencies...\n")
    
    for import_name, package_name in DEPENDENCIES:
        try:
            importlib.import_module(import_name)
            installed.append(package_name)
            print(f"✅ {package_name}")
        except ImportError:
            missing.append(package_name)
            print(f"❌ {package_name} - NOT INSTALLED")
    
    print(f"\n📊 Summary:")
    print(f"✅ Installed: {len(installed)}/{len(DEPENDENCIES)}")
    
    if missing:
        print(f"❌ Missing: {len(missing)} packages")
        print(f"\n🔧 To install missing packages:")
        print(f"pip install {' '.join(missing)}")
        return False
    else:
        print("🎉 All dependencies are installed!")
        return True

def install_missing():
    """Install missing dependencies."""
    print("🔧 Installing missing dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Installation completed!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Installation failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--install":
        success = install_missing()
        if success:
            check_dependencies()
    else:
        all_installed = check_dependencies()
        if not all_installed:
            print(f"\n💡 Run '{sys.argv[0]} --install' to automatically install missing packages")
            sys.exit(1)