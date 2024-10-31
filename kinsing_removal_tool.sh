#!/bin/bash

echo "Starting the Kinsing Malware Removal Tool..."

# 1. Kill malicious processes related to kdevtmpfsi and kinsing
kill_malicious_processes() {
    echo "Stopping any active malware processes..."
    pkill -f kdevtmpfsi
    pkill -f kinsing
    echo "Malware processes stopped."
}

# 2. Remove any malicious cron jobs containing 'unk.sh'
remove_crontab_entries() {
    echo "Looking for and removing any suspicious cron jobs..."
    # Filter out entries with 'unk.sh' in the root's crontab
    crontab -l | grep -v 'unk.sh' | crontab -
    echo "Suspicious cron jobs removed."
}


# 3. Lock the root crontab to prevent future modifications
lock_crontab() {
    echo "Locking root crontab to prevent unauthorized changes..."
    chattr +i /var/spool/crontabs/root
    echo "Root crontab locked."
}

# 4. Remove known malware files and directories
remove_malicious_files() {
    echo "Removing known malware files and directories..."
    
    # List of known suspicious file paths
    declare -a malicious_files=(
        "/etc/data/kinsing"
        "/etc/kinsing"
        "/tmp/kdevtmpfsi"
        "/tmp/kinsing"
        "/etc/data/libsystem.so"
    )
    
    # Delete each file or directory in the list
    for file in "${malicious_files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            # Remove any "immutable" attribute to allow deletion
            chattr -i "$file" 2>/dev/null
            rm -rf "$file"
            echo "Removed $file."
        fi
    done

    # Use 'find' to catch any leftover files with similar names
    find / -iname "kdevtmpfsi*" -exec rm -fv {} \;
    find / -iname "kinsing*" -exec rm -fv {} \;
    echo "Additional malware files cleaned up."
}

# 5. Disable and remove the malicious bot service
remove_malicious_service() {
    echo "Disabling and removing the malicious service..."

    # Stop and disable the service
    systemctl stop bot.service 2>/dev/null
    systemctl disable bot.service 2>/dev/null

    # Remove service files from common system directories
    rm -f /etc/systemd/system/bot.service
    rm -f /usr/lib/systemd/system/bot.service

    # Reload systemd to apply changes
    systemctl daemon-reload

    echo "Malicious service removed."
}

# 6. Unmount and delete hidden directories in /tmp that contain '.mount_Collab'
remove_mount_collab() {
    echo "Finding and removing hidden directories in /tmp..."

    # Search for directories in /tmp with ".mount_Collab" in their name
    for dir in $(find /tmp -type d -name "*.mount_Collab*"); do
        echo "Processing $dir..."

        # Unmount if it’s currently mounted
        if mount | grep -q "$dir"; then
            echo "Unmounting $dir..."
            for i in {1..5}; do
                if umount -l "$dir" 2>/dev/null; then
                    echo "Unmounted $dir successfully."
                    break
                else
                    echo "Retrying unmount for $dir..."
                    sleep 2
                fi
            done
        fi
        
        # Delete the directory after unmounting
        echo "Deleting $dir..."
        rm -rf "$dir"
        echo "$dir removed."
    done
}

# 7. Create dummy files to prevent malware from recreating certain files
create_protective_files() {
    echo "Creating protected dummy files to prevent malware from reappearing..."

    # Create dummy files with read-only permissions
    touch /tmp/kdevtmpfsi
    echo "noob miner" > /tmp/kdevtmpfsi
    chmod 0444 /tmp/kdevtmpfsi

    touch /tmp/kinsing
    echo "noob miner" > /tmp/kinsing
    chmod 0444 /tmp/kinsing

    # Make these files immutable
    chattr +i /tmp/kdevtmpfsi
    chattr +i /tmp/kinsing

    echo "Protected files created and locked."
}


# Run all the steps in order
kill_malicious_processes
remove_crontab_entries
lock_crontab
remove_malicious_files
remove_malicious_service
remove_mount_collab
create_protective_files

echo "Malware removal and protection complete."
