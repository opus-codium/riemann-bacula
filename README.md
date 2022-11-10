# riemann-bacula

[![CI](https://github.com/opus-codium/riemann-bacula/actions/workflows/ci.yml/badge.svg)](https://github.com/opus-codium/riemann-bacula/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/d4206bbc680dc822194b/maintainability)](https://codeclimate.com/github/opus-codium/riemann-bacula/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d4206bbc680dc822194b/test_coverage)](https://codeclimate.com/github/opus-codium/riemann-bacula/test_coverage)

Submits bacula information to riemann.

## Get started

```
gem install riemann-bacula
```

In your Bacula Director configuration, add a Message resource like this (the provided e-mail address is not used, we are just hacking around the mail destination which sends a full transcript to the MailCommand standard input):

```
Messages {
  Name = Standard
  MailCommand = "riemann-bacula --event-host \"%h\" --job-name \"%n\" --backup-level \"%l\" --status \"%e\" --bytes \"%b\" --files \"%F\""
  Mail = sysadmin@example.com = all, !skipped
}
```
