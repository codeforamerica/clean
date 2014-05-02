# PDF Application Experiments

("CalFresh and So Clean")

## Setup

The script is a proof of concept, and has a few dependencies:

- Ruby
- The `pdf-forms` gem ( https://github.com/jkraemer/pdf-forms )
- `pdftk` utility (on Debian-like systems, install via `apt-get install pdftk`)

The script is being developed on Ubuntu 14, and so might need to be modified for other environments.

For faxing capabilities, set the following environment variables:

- PHAXIO_API_KEY
- PHAXIO_API_SECRET
- FAX_DESTINATION_NUMBER

## Deployment to Heroku

```bash
heroku create YOURAPPNAMEGOESHERE
heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
git push heroku master
heroku config:set PATH=/app/bin:/app/vendor/bundle/bin:/app/vendor/bundle/ruby/2.1.0/bin:/usr/local/bin:/usr/bin:/bin:/app/vendor/pdftk/bin
heroku config:set LD_LIBRARY_PATH=/app/vendor/pdftk/lib
```


## Copyright and License

Copyright 2014 Dave Guarino
MIT License
