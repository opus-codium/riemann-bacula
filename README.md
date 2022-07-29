# riemann-bacula

Submits bacula information to riemann.

## Get started

```
gem install riemann-bacula
```

In your Bacula Director configuration, add a Message resource like this (the provided e-mail address is not used, we are just hacking around the mail destination which sends a full transcript to the MailCommand standard input):

```
Messages {
  Name = Standard
  MailCommand = "riemann-bacula"
  Mail = sysadmin@example.com = all, !skipped
}
```
