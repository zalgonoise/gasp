# gasp

![CI](https://github.com/ZalgoNoise/gasp/workflows/CI/badge.svg)

________


### Google App Specific Password Validator 

A simple and lightweight Docker image for validating Google App-Specific Passwords via Gmail and Mutt.

Uses simple authentication (over TLS1.3) to access a Gmail inbox from a headless environment (using the mutt email client for Linux), using Google's required App Passwords method.

This simple system allows access to certain service's API's to many types of environment in a secure manner - without providing your real password.

As such, Google allows you to provision your less secure applications with authentication methods for them to work, and for your account to be safe.


### Generating an App Specific Password 

_Covered by_ [Google Support](https://support.google.com/accounts/answer/185833 "Sign in using App Passwords - Google Support")

1. Head over to your [Google Account](https://myaccount.google.com/ "Access your Google Account settings").
1. On the left-hand drawer, open __Security__
1. Under the section __Signing in with Google__, open __App Passwords__
1. Select the app you'd like to generate a password, for this we need to use __Gmail__
1. For the device select __Other__ and provide it a name, such as __mutt__
1. Copy the resulting 16-character-long string to a safe place.
    - Google will not reveal this password again.
    - You will need to use it as an environment variable when running this container

### Mutt configuration file

By default, the Mutt configuration file is adequate to access Gmail (as of March 2020). This file is created by the `entrypoint.sh` script, and is placed under `/data/muttrc`.

The default configuration file is populated with the following environment variables, defined when you start the container:
- `APP_USER`: The email address for you Google Account
- `APP_PASS`: The App Password generated in your Google Account to access Gmail

And is dumped with `cat` via `heredocs` into `/data/muttrc`:

```bash
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
```

Mutt is, in turn, ran with this configuration file:

```
mutt -F /data/muttrc
```

### Deploying the container and testing Gmail access

Simply load the variables to your environment (or define them when running the container):

```bash
docker run --rm -ti \
-e APP_USER=${APP_USER} \
-e APP_PASS=${APP_PASS} \
zalgonoise/gasp
```

To access your inbox, add __anything__ as a parameter, after the repo/container reference:

```bash
docker run --rm -ti \
-e APP_USER=${APP_USER} \
-e APP_PASS=${APP_PASS} \
zalgonoise/gasp \
mail
```

Or if you'd like to run a custom `.muttrc` file, you can load it into the container as `/data/muttrc`, so it is loaded instead of the default one. Be sure to inclue your password in your .rc file in __both SMTP/IMAP__ fields:

```bash
docker run --rm -ti \
-v /path/to/.muttrc:/data/muttrc \
-e APP_USER=${APP_USER} \
zalgonoise/gasp
```

~ ZalgoNoise ~ 2020
