#!/usr/bin/env bash

# some parameters
PATHS_TO_BACKUP="/firstpath /secondpath"
PATHS_TO_EXCLUDE="--exclude /firstpath/.cache --exclude /secondpath/.cache"
BORG_REPO="ssh://username@hostname/path/to/repo/repo_name"
BORG_ARCHIVE_PATTERN="{hostname}_backup_name_{utcnow}"

# set local tmp folder on a large capacity partition
#export BORG_CACHE_DIR=/mnt/SAV/borg/tmp

# paths
ECHO="$(which echo)"
BORG="$(which borg)" ||{ ${ECHO} "[!] borg not found. Bye!"; exit 1; }

# start backup
${ECHO} "[+] Starting backup of ${PATHS_TO_BACKUP} to ${BORG_REPO}..."

${BORG} create \
        --stats \
        --progress \
        --show-rc \
        --umask 0007 \
        --compression zstd,10 \
        --exclude-caches \
        ${PATHS_TO_EXCLUDE} \
        ${BORG_REPO}::${BORG_ARCHIVE_PATTERN} \
        ${PATHS_TO_BACKUP}

# pruning repo
${ECHO} "[+] Pruning ${BORG_REPO}..."
${BORG} prune \
        --stats \
        --list \
        --keep-last=5 \
        --keep-weekly=8 \
        --keep-monthly=12 \
        --keep-yearly=-1 \
        ${BORG_REPO}

exit 0
