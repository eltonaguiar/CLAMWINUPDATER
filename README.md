# ClamWin Database Updater

A workaround tool to update `C:\ProgramData\.clamwin\db` when ClamWin's automatic updates fail to retrieve virus definition databases.

## Problem

ClamWin users often experience issues where the automatic database update feature fails, leaving their antivirus with outdated virus definitions. This can happen due to:
- Outdated ClamWin versions being blocked by CDN
- Network/firewall issues
- Corrupted local database files
- Server connectivity problems

## Solution

This tool provides a simple Python script that manually downloads the latest virus definition files directly from ClamAV's database servers and places them in your ClamWin database directory.

## Features

- ✓ Downloads all required ClamAV database files (main.cvd, daily.cvd, bytecode.cvd)
- ✓ Automatic backup of existing database files
- ✓ Progress indicator during downloads
- ✓ Error handling and helpful error messages
- ✓ Command-line interface with multiple options
- ✓ Windows batch file for easy double-click execution

## Requirements

- Python 3.6 or higher
- Internet connection
- Windows (ClamWin is Windows-only)

## Installation

1. Download or clone this repository:
   ```bash
   git clone https://github.com/eltonaguiar/CLAMWINUPDATER.git
   cd CLAMWINUPDATER
   ```

2. Ensure Python 3 is installed:
   ```bash
   python --version
   ```
   If not installed, download from [python.org](https://www.python.org/)

## Usage

### Easy Method (Windows)

Double-click `update_clamwin.bat` to run the updater with default settings.

### Command Line Method

#### Basic Update (default location)
```bash
python clamwin_updater.py
```

#### Update with Custom Directory
```bash
python clamwin_updater.py --db-dir "D:\ClamWin\db"
```

#### Update Without Backup
```bash
python clamwin_updater.py --no-backup
```

#### Show Help
```bash
python clamwin_updater.py --help
```

## Command-Line Options

| Option | Description |
|--------|-------------|
| `--db-dir PATH` | Specify custom ClamWin database directory (default: `C:\ProgramData\.clamwin\db`) |
| `--no-backup` | Skip backing up existing database files before updating |
| `--version` | Show version information |
| `--help` | Show help message with all options |

## How It Works

1. **Backup**: Creates a backup of your existing database files (unless `--no-backup` is specified)
2. **Download**: Downloads the latest virus definition files from ClamAV servers:
   - main.cvd - Main virus database
   - daily.cvd - Daily updated virus database
   - bytecode.cvd - Bytecode signatures database
3. **Install**: Places the downloaded files in your ClamWin database directory
4. **Summary**: Shows download results and next steps

## After Running the Updater

1. Restart ClamWin for the changes to take effect
2. You can verify the update by checking the database date in ClamWin's status or preferences

## Troubleshooting

### "HTTP Error 403: Forbidden"
This means you've been temporarily blocked by the CDN, usually because:
- Too many update attempts in a short time
- Using an outdated/unsupported ClamWin version

**Solution**: Wait at least one hour before trying again. Consider updating ClamWin to the latest version.

### "Database directory does not exist"
The script will attempt to create the directory automatically. If it fails, check:
- You have administrator privileges
- The path is correct for your ClamWin installation

### Download Fails Midway
- Check your internet connection
- Try again later (servers may be temporarily unavailable)
- Check if your firewall is blocking the connection

### Python Not Found
Make sure Python is installed and added to your system PATH:
1. Download Python from [python.org](https://www.python.org/)
2. During installation, check "Add Python to PATH"
3. Restart your command prompt

## Manual Update Alternative

If this tool doesn't work, you can manually download the files:
1. Download from ClamAV directly:
   - [main.cvd](https://database.clamav.net/main.cvd)
   - [daily.cvd](https://database.clamav.net/daily.cvd)
   - [bytecode.cvd](https://database.clamav.net/bytecode.cvd)
2. Copy them to `C:\ProgramData\.clamwin\db`
3. Restart ClamWin

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This is free and open-source software provided as-is without warranty.

## Disclaimer

This tool is not affiliated with or endorsed by ClamWin or ClamAV. It simply provides an alternative method to download publicly available virus definition files.

## Support

If you encounter issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Open an issue on GitHub with details about the error
3. Visit the [ClamWin Forums](https://forums.clamwin.com/) for ClamWin-specific help

---

**Note**: Keep ClamWin updated to the latest version to avoid CDN blocks and ensure compatibility with current virus definition formats.
