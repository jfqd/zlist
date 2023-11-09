# ZList

ZList is a simple yet powerful mailing list application and is built on Rails. It can
send mail to an unlimited number of recipients, can be configured as announcement only
or it can be fully interactive.  Subscribers can view and reply entirely by email. All
discussions are archived so you can go back anytime to see what was said.

Incoming mails are fetched from an IMAP account via cron task. Outgoing mails are send
out via SMTP.

As a feature the application accepts emails HTTP POSTed to a particular URL. Postmark
(postmarkapp.com) is what we use for incoming email.

## Installation

You can get the latest by downloading the master branch from GitHub, or you can grab the
most recent tagged version on the downloads page at http://github.com/bensie/zlist/downloads

Configure the application by creating your app_config.yml, email.yml and database.yml files.
Then run:

### Regular Mailserver

```
bundle install --without postmark
rails db:create
rails db:migrate
```

### Postmark

```
bundle install
rails db:create
rails db:migrate
```

## Run the application

To start the application in development mode run:

```
rails s
```

To start the application in production mode run:

```
RAILS_SERVE_STATIC_FILES=true RAILS_ENV=production rails s
```

Using the app in production assets precompile is needed:

```
RAILS_ENV=production rails assets:precompile
```

If you plan to use postmarkapp.com as a service a redis-server is required.

For regular IMAP email fetching create a cron job as described below. If you plan to host
multiple mailinglists make sure to create a cronjob for each mailinglist!

## Fetch emails via cron

Setup a cron entry.

```
*/5 * * * * zlist-user rake -f /path/to/zlist/Rakefile --silent zlist:email:receive_imap RAILS_ENV="production" username='mailinglist@example.com' password='password' host=mail.example.com port=993 ssl=true 1>/dev/null
```

## Prerequisites

ZList currently runs on Rails 6.1.7.6 and requires Ruby >= 3.0

## Contributors

+ [jfqd](https://github.com/jfqd) (Stefan Husch)

Copyright (c) 2012 James Miller and David Hasson
