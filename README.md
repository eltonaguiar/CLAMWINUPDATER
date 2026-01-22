# ClamWin Database Updater

A PowerShell script to manually update ClamWin antivirus database files when the automatic update feature fails.

## Features

- Downloads all required ClamAV database files:
  - `bytecode.cvd`
  - `daily.cvd`
  - `main.cvd`
  - `mirrors.dat` (optional)
- Automatic fallback to multiple mirrors if primary fails
- Multiple User-Agent strings to bypass CDN restrictions
- Progress indicators and error handling
- Administrator privilege detection

## Requirements

- Windows PowerShell 5.1 or later
- Internet connection
- Write permissions to `C:\ProgramData\.clamwin\db` (Administrator recommended)

## Usage

### Basic Usage

Run the script as Administrator (recommended):

```powershell
# Right-click PowerShell and "Run as Administrator", then:
cd C:\Users\zerou\Documents\ClamWinUpdater
.\Update-ClamWinDB.ps1
```

### Custom Target Path

```powershell
.\Update-ClamWinDB.ps1 -TargetPath "C:\Custom\Path\db"
```

### Custom Mirror

```powershell
.\Update-ClamWinDB.ps1 -MirrorUrl "http://your-mirror.com"
```

## Default Location

Files are downloaded to: `C:\ProgramData\.clamwin\db`

## Mirrors Used

The script tries these mirrors in order:
1. `https://database.clamav.net`
2. `http://database.clamav.net`
3. `http://db.it.clamav.net`

## Exit Codes

- `0` - Success (all required files downloaded)
- `1` - Failure (one or more required files failed)

## Notes

- The `mirrors.dat` file is optional and the script will succeed even if it fails to download
- The script uses multiple User-Agent strings to work around CDN restrictions
- If you encounter 403 Forbidden errors, the script will automatically try alternative mirrors and User-Agents

## License

Free to use and modify.
