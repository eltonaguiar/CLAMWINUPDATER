#!/usr/bin/env python3
"""
ClamWin Database Updater
========================
A workaround tool to manually update ClamWin virus definition database
when automatic updates fail.

This script downloads the latest virus definition files from ClamAV servers
and places them in the ClamWin database directory.
"""

import argparse
import os
import sys
import urllib.request
import urllib.error

# Default ClamWin database directory
DEFAULT_DB_DIR = r"C:\ProgramData\.clamwin\db"

# ClamAV database URLs
DATABASE_URLS = {
    'main.cvd': 'https://database.clamav.net/main.cvd',
    'daily.cvd': 'https://database.clamav.net/daily.cvd',
    'bytecode.cvd': 'https://database.clamav.net/bytecode.cvd'
}


def download_file(url, destination):
    """
    Download a file from a URL to a destination path.
    
    Args:
        url (str): The URL to download from
        destination (str): The path where the file should be saved
        
    Returns:
        bool: True if download was successful, False otherwise
    """
    try:
        print(f"Downloading {os.path.basename(destination)}...")
        
        # Set a user agent to avoid being blocked
        req = urllib.request.Request(
            url,
            headers={'User-Agent': 'ClamWin-Updater/1.0'}
        )
        
        with urllib.request.urlopen(req, timeout=300) as response:
            total_size = int(response.headers.get('content-length', 0))
            downloaded = 0
            
            with open(destination, 'wb') as f:
                while True:
                    chunk = response.read(8192)
                    if not chunk:
                        break
                    f.write(chunk)
                    downloaded += len(chunk)
                    
                    # Show progress
                    if total_size > 0:
                        progress = (downloaded / total_size) * 100
                        print(f"\rProgress: {progress:.1f}% ({downloaded}/{total_size} bytes)", end='')
        
        print(f"\n✓ Successfully downloaded {os.path.basename(destination)}")
        return True
        
    except urllib.error.HTTPError as e:
        print(f"\n✗ HTTP Error {e.code}: {e.reason}")
        if e.code == 403:
            print("  Note: You may be blocked by CDN. Wait an hour before trying again.")
        return False
    except urllib.error.URLError as e:
        print(f"\n✗ URL Error: {e.reason}")
        return False
    except Exception as e:
        print(f"\n✗ Error: {str(e)}")
        return False


def backup_existing_files(db_dir):
    """
    Create a backup of existing database files.
    
    Args:
        db_dir (str): The database directory path
        
    Returns:
        bool: True if backup was successful or no files to backup, False on error
    """
    try:
        backup_dir = os.path.join(db_dir, 'backup')
        has_files = False
        
        for filename in DATABASE_URLS.keys():
            filepath = os.path.join(db_dir, filename)
            if os.path.exists(filepath):
                has_files = True
                if not os.path.exists(backup_dir):
                    os.makedirs(backup_dir)
                    print(f"Created backup directory: {backup_dir}")
                
                backup_path = os.path.join(backup_dir, filename)
                
                # Remove old backup if it exists and rename current file
                try:
                    if os.path.exists(backup_path):
                        os.remove(backup_path)
                    os.rename(filepath, backup_path)
                    print(f"Backed up {filename} to backup directory")
                except OSError as e:
                    print(f"Warning: Could not backup {filename}: {str(e)}")
                    # Continue with update even if backup fails
        
        if not has_files:
            print("No existing database files to backup")
        
        return True
    except Exception as e:
        print(f"Warning: Could not backup existing files: {str(e)}")
        return True  # Continue anyway


def update_database(db_dir, backup=True):
    """
    Update the ClamWin database by downloading latest definition files.
    
    Args:
        db_dir (str): The database directory path
        backup (bool): Whether to backup existing files before updating
        
    Returns:
        bool: True if all downloads were successful, False otherwise
    """
    # Verify directory exists
    if not os.path.exists(db_dir):
        print(f"Error: Database directory does not exist: {db_dir}")
        print("Creating directory...")
        try:
            os.makedirs(db_dir)
            print(f"✓ Created directory: {db_dir}")
        except Exception as e:
            print(f"✗ Could not create directory: {str(e)}")
            return False
    
    # Backup existing files if requested
    if backup:
        print("\n=== Backing up existing database files ===")
        backup_existing_files(db_dir)
    
    # Download all database files
    print("\n=== Downloading virus definition files ===")
    print("Source: ClamAV Database Servers")
    print(f"Destination: {db_dir}\n")
    
    success_count = 0
    total_count = len(DATABASE_URLS)
    
    for filename, url in DATABASE_URLS.items():
        destination = os.path.join(db_dir, filename)
        if download_file(url, destination):
            success_count += 1
        print()  # Empty line between downloads
    
    # Summary
    print("=" * 50)
    print(f"Download Summary: {success_count}/{total_count} files successfully downloaded")
    
    if success_count == total_count:
        print("✓ Database update completed successfully!")
        print("\nPlease restart ClamWin for the changes to take effect.")
        return True
    else:
        print("✗ Some files failed to download. Please check the errors above.")
        if success_count > 0:
            print("Partial update completed. ClamWin may still function with outdated definitions.")
        return False


def main():
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(
        description='ClamWin Database Updater - Downloads latest virus definitions',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Update default directory
  %(prog)s --no-backup               # Update without backing up old files
  %(prog)s --db-dir "D:\\ClamWin\\db"  # Update custom directory
        """
    )
    
    parser.add_argument(
        '--db-dir',
        default=DEFAULT_DB_DIR,
        help=f'ClamWin database directory (default: {DEFAULT_DB_DIR})'
    )
    
    parser.add_argument(
        '--no-backup',
        action='store_true',
        help='Do not backup existing database files before updating'
    )
    
    parser.add_argument(
        '--version',
        action='version',
        version='ClamWin Updater 1.0'
    )
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("ClamWin Database Updater v1.0")
    print("=" * 50)
    print()
    
    # Run the update
    success = update_database(args.db_dir, backup=not args.no_backup)
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
