#!/bin/bash
while :
do
	echo "$(date "+%d.%m.%Y %T") INFO: starting script"

	# Variables definitions

	RcloneRemoteName="GdriveMedia" # Name of rclone remote mount WITHOUT ':'. NOTE: Choose your encrypted remote for sensitive data
	RcloneMountLocation="/mnt/user/mount_rclone" # absolute path of rclone  mount WITHOUT '/' at the end.
	RcloneMountDirCacheTime="30m" # rclone dir cache time
	RcloneMountCacheDirectory="/mnt/user/vfscache"


	echo "$(date "+%d.%m.%Y %T") INFO: Script will now mount ${RcloneRemoteName} in ${RcloneMountLocation} with ${RcloneMountDirCacheTime} cache time..."
	sleep 3

	# Check if the mount directory exist 
	if [ ! -d "$RcloneMountLocation/$RcloneRemoteName" ]; then
		echo "$(date "+%d.%m.%Y %T") INFO: creating ${RcloneRemoteName} directory in ${RcloneMountLocation}."
		mkdir $RcloneMountLocation/$RcloneRemoteName
		echo "$(date "+%d.%m.%Y %T") INFO: Directory created."
		else
			echo "$(date "+%d.%m.%Y %T") INFO: Directory ${RcloneRemoteName} exists in ${RcloneMountLocation}."
	fi

	if [[ -f "$RcloneMountLocation/$RcloneRemoteName/mountcheck" ]]; then
			echo "$(date "+%d.%m.%Y %T") INFO: ${RcloneRemoteName} already mounted."
		else
			echo "$(date "+%d.%m.%Y %T") INFO: ${RcloneRemoteName} not mounted !"
			fusermount -uz $RcloneMountLocation/$RcloneRemoteName
			sleep 1
			echo "$(date "+%d.%m.%Y %T") INFO: mounting ${RcloneRemoteName}..."
			rclone mount --allow-non-empty --allow-other --buffer-size 256M --cache-tmp-wait-time 5m --dir-cache-time $RcloneMountDirCacheTime --cache-dir $RcloneMountCacheDirectory --drive-chunk-size 32M --fast-list --log-level INFO --log-file /mnt/user/appdata/rclone.log --poll-interval 5m --size-only --timeout 1h --tpslimit 10 --umask 000 --vfs-read-chunk-size 128M --vfs-cache-max-size 40G --vfs-read-chunk-size-limit off $RcloneRemoteName: $RcloneMountLocation/$RcloneRemoteName &
			sleep 5
			echo "$(date "+%d.%m.%Y %T") INFO: Checking mount of ${RcloneRemoteName}..."
			sleep 2
			if [[ -f "$RcloneMountLocation/$RcloneRemoteName/mountcheck" ]]; then
				echo "$(date "+%d.%m.%Y %T") INFO: ${RcloneRemoteName} is now mounted !"
				echo "$(date "+%d.%m.%Y %T") INFO: restarting Plex !"
				docker restart binhex-plex
			else
				echo "$(date "+%d.%m.%Y %T") INFO: ${RcloneRemoteName} could not have been mounted !"
			fi

	fi

	echo "$(date "+%d.%m.%Y %T") INFO: Script complete"
	echo "Pausing for 10 seconds..."
    sleep 10s

done
