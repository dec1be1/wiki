#!/usr/bin/env bash

# some parameters
PATHS_TO_BACKUP="/firstpath /secondpath"
BORG_REPO="ssh://username@hostname/path/to/repo/repo_name"
EXCLUDE_FILE="/path/to/exlude/file/borg.exclude"
BORG_ARCHIVE_PATTERN="{hostname}_backup_name_{utcnow}"
export BORG_PASSPHRASE="mysecurebackuppassphrase"

# set local tmp folder on a large capacity partition
# export BORG_CACHE_DIR=/mnt/borg/tmp

# paths
ECHO="$(which echo)"
BORG="$(which borg)" ||{ ${ECHO} "[!] borg not found. Bye!"; exit 1; }

# prune repo
${ECHO} "[+] Pruning ${BORG_REPO}..."
${BORG} prune \
        --stats \
        --list \
        --keep-last=5 \
        --keep-weekly=8 \
        --keep-monthly=12 \
        --keep-yearly=-1 \
        ${BORG_REPO}

# start backup
${ECHO} "[+] Starting backup of ${PATHS_TO_BACKUP} to ${BORG_REPO}..."
${BORG} create \
        --stats \
        --progress \
        --show-rc \
        --umask 0007 \
        --compression zstd,10 \
        --exclude-caches \
        --exclude-from ${EXCLUDE_FILE} \
        ${BORG_REPO}::${BORG_ARCHIVE_PATTERN} \
        ${PATHS_TO_BACKUP}

# archives integrity check
${ECHO} "[+] Checking archives integrity..."
${BORG} check \
        --archives-only \
        ${BORG_REPO}

${ECHO} "[*] Borg backup finished. Bye!"
exit 0
