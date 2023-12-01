#!/bin/bash

###########################################################
#
# This is a DNS Change Detector.
# It will check the DNS Records of the provided domain and save the output
# On the second check, if something changed, it will send an email with 2 files.
# One file contains the current DNS Records and the other is what was previous there.
#
# This script uses the `mail` command. Please confirm that this works on your machine.
# Don't forget the change the RECIPIENT in the script below
# use `chmod -x checkDNS.sh` to make it executable
# use cronjobs to execute it frequently. For example every 5min:
# */5 * * * * path/to/checkDNS.sh example.com
#
# Limitations:
# It will not save or check TXT Records with an underscore prefix (_acme.example.com)
# If someone knows a way to do that, please send a PR.
#
###########################################################
#
# Script made by Dirk Federmann
# Website: dirkfedermann.de
#
###########################################################

# Check if the required argument (DOMAIN name) is provided
if [ -z "$1" ]; then
  echo "Check DNS Changes and get notified via email"
  echo "Usage: $0 <DOMAIN>"
  exit 1
fi

# Change this to your email address
RECIPIENT="your@email.com"

DOMAIN="$1"
OUTPUT_FILE="./DNS_$DOMAIN.txt"
TEMP_OUTPUT_FILE="./DNS_$DOMAIN.new.txt"
SUBJECT="DNS Change Notification for $DOMAIN"
BODY="DNS records for $DOMAIN have changed. See Attached Files for more Information"

# List of DNS record types to look up
RECORD_TYPES="A AAAA CNAME MX NS PTR SOA SRV TXT"

# Check if the output file exists, and create it if not
if [ ! -f "$OUTPUT_FILE" ]; then
  touch "$OUTPUT_FILE"
fi

# Loop through each record type and perform DNS lookup
# sort prevents different order in the NS for example triggering a change detection
for TYPE in $RECORD_TYPES; do
  echo "=== $TYPE Records ===" >> "$TEMP_OUTPUT_FILE"
  dig +short "$DOMAIN" "$TYPE" | sort >> "$TEMP_OUTPUT_FILE"
  echo "" >> "$TEMP_OUTPUT_FILE"
done

# Check if there is a change from the previous check
if ! cmp -s "$OUTPUT_FILE" "$TEMP_OUTPUT_FILE"; then
  echo "DNS records for $DOMAIN have changed. Sending email notification."

  # Email notification (replace placeholders with your email details)
  echo "$BODY" | mail -s "$SUBJECT" -A "$TEMP_OUTPUT_FILE" -A "$OUTPUT_FILE" "$RECIPIENT"

  # Save the new output to the output file
  cp "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE"
fi

# Clean up temporary file
rm "$TEMP_OUTPUT_FILE"
