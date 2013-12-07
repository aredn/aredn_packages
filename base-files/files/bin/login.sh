#!/bin/sh
# Copyright (C) 2006-2010 OpenWrt.org

if grep -qs '^root:[^!]' /etc/passwd /etc/shadow && [ -z "$FAILSAFE" ]; then
	echo "WARNING: passwords are sent unencrypted."
	busybox login
else
cat << EOF
 === IMPORTANT ============================
  Use 'passwd' to set your login password
  this will enable telnet login with password
 ------------------------------------------
EOF
exec /bin/ash --login
fi
