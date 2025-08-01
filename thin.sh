#!/bin/bash

# Time Machine Backup Deletion Script for HFS+
# Escapes all spaces in the backup path (e.g., "Mac Pro")

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

echo "📦 Listing Time Machine backups..."
IFS=$'\n' read -r -d '' -a BACKUPS < <(tmutil listbackups && printf '\0')

if [ ${#BACKUPS[@]} -eq 0 ]; then
  echo "❌ No backups found."
  exit 1
fi

echo ""
echo "Found ${#BACKUPS[@]} backups:"
for i in "${!BACKUPS[@]}"; do
  echo "  [$i] ${BACKUPS[$i]}"
done

echo ""
read -p "Enter the number(s) of the backup(s) to delete (comma separated): " INPUT
IFS=',' read -ra SELECTED <<< "$INPUT"

echo ""
echo "You selected:"
for index in "${SELECTED[@]}"; do
  echo "  ${BACKUPS[$index]}"
done

read -p "⚠️ Confirm deletion of these backups? [y/N]: " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "❎ Cancelled."
  exit 0
fi

echo ""
for index in "${SELECTED[@]}"; do
  RAW_PATH="${BACKUPS[$index]}"

  # Escape spaces for the command
  ESCAPED_PATH="${RAW_PATH// /\\ }"

  echo "🗑 Deleting: $ESCAPED_PATH"

  # Evaluate command to allow escape processing
  if eval "sudo tmutil delete -p $ESCAPED_PATH"; then
    echo "✅ Deleted: $RAW_PATH"
  else
    echo "❌ Failed to delete: $RAW_PATH"
  fi
done

echo ""
echo "✔️ Done."