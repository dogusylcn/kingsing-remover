# Kinsing Malware Removal Tool

**⚠ Warning: Do not run shell scripts from untrusted sources without reviewing the code, as they may contain malicious commands that could compromise your system. Always inspect scripts carefully before executing them.**

## Overview

This tool is designed to detect, remove, and protect against **Kinsing** malware. The script kills active malware processes, removes persistence mechanisms, cleans up associated files, and sets up protections to prevent reinfection.

## How It Works

The tool performs the following steps:

1. **Kill Active Malware Processes**: Stops any active `kdevtmpfsi` and `kinsing` processes.
2. **Remove Malicious Cron Jobs**: Deletes cron jobs that may be aiding the malware’s persistence, specifically looking for entries containing `unk.sh`.
3. **Lock Root Crontab**: Sets the root crontab as immutable to prevent future unauthorized modifications.
4. **Remove Malware Files and Directories**: Deletes known malware files and directories and searches for similarly named files across the filesystem.
5. **Disable and Remove Malicious Service**: Stops, disables, and deletes `bot.service`, which may be responsible for respawning the malware.
6. **Unmount and Remove Hidden Directories in `/tmp`**: Unmounts and deletes any `.mount_Collab` directories, which could be used as part of the malware’s hiding strategy.
7. **Create Protected Dummy Files**: Sets up dummy files (`/tmp/kdevtmpfsi` and `/tmp/kinsing`) with restricted permissions and marks them as immutable, preventing malware from recreating these critical files.

### Dummy File Protection Strategy

This part inspired from malware scare crow project : https://github.com/kaganisildak/malwarescarecrow
The script creates dummy files (`/tmp/kdevtmpfsi` and `/tmp/kinsing`) with restricted read-only permissions and marks them as immutable using `chattr +i`. This prevents the malware from overwriting or deleting these files, as they are locked in place. If Kinsing attempts to recreate these files, it will fail due to the file protections.

## Usage

1. **Download the Script**:
   Save the script as `kinsing_removal_tool.sh`.

2. **Make the Script Executable**:
   ```bash
   chmod +x kinsing_removal_tool.sh

3. **Make the Script Executable**:
   ```bash
   sudo ./kinsing_removal_tool.sh

## Disclaimer
This tool modifies system files to remove malware. Use it with caution and ensure you have backups of important data before running it. Use at your own risk.
