#!/bin/sh

# Create /data directory if doesn't exist
# Configuration and temporary files are placed here

if ! [ -d /data ]
then
    mkdir /data
fi

cd /data


# Auto-generate configuration for Mutt if it isn't attached
# Based on required environment variables

if ! [ /data/muttrc ]
then
# Break if needed environment isn't loaded into the container
    if [ -z $APP_USER ] || [ -z $APP_PASS ]
    then
        echo -e "\n\n# Environment wasn't properly defined!\nPlease check your configuration and try again.\n\nPopulate the following environment variables when running the container:\n\t-e APP_USER='user'\n\t-e APP_PASS='app-specific-password'\n\n"
        exit 1
    fi

    cat << EOF >> muttrc
set from = "${APP_USER:-user@example.com}"
set use_from = yes
set envelope_from = yes

set smtp_url = "smtps://${APP_USER:-user@example.com}@smtp.gmail.com:465/"
set smtp_pass = "${APP_PASS:-secretpassword}"
set imap_user = "${APP_USER:-user@example.com}"
set imap_pass = "${APP_PASS:-secretpassword}"
set folder = "imaps://imap.gmail.com:993"
set spoolfile = "+INBOX"
set ssl_force_tls = yes
EOF
else
    if [ -z $APP_USER ]
    then
        echo -e "\n\n# Environment wasn't properly defined!\nPlease check your configuration and try again.\n\nPopulate the following environment variables when running the container:\n\t-e APP_USER='user'\n\t-v /path/to/.muttrc:/data/muttrc\n\n"
        exit 1
    fi
fi

# Generate test email
# Uses user@container as reference

    cat << EOF >> email
Hello from a container!

`whoami`@$HOSTNAME
EOF

# Tests both connections (sending and receiving) with test email
# Mutt logs in by default (IMAP) when sending a message (SMTP)
# Both services are tested.
#
# If an argument is given to the container, it simply opens the inbox
# Useful for quickly monitoring sending/receiving email with two containers

if [ -z $@ ]
then
    echo "" | mutt -F /data/muttrc -s "G Suite App-Specific Password Test `date +%y-%m-%d-%H%M%S`" -b email -- $APP_USER && echo -e "Email sent! Check your inbox."
else
    mutt -F /data/muttrc
fi

