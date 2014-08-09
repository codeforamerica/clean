# CalFresh and So Clean

Making applying to the CalFresh program not suck.

## How it sucks now

If you want to understand the genesis of the project, [click here](https://github.com/codeforamerica/health-project-ideas/issues/6).

[Click here to experience what it's like to apply to CalFresh right now.](http://codeforamerica.github.io/citizen-onboard/calfresh/)

## What's this?

A user-friendly web form with the minimal fields necessary that generates a PDF application and faxes it in to HSA.

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


### Developing locally with Vagrant

Because we've experienced problems running `pdftk` on Mac OSX, the recommended setup for developing locally is using a Vagrant virtual machine running Ubuntu.

Here's how to get that set up:

1 - Download and install VirtualBox ( https://www.virtualbox.org/wiki/Downloads ) and Vagrant ( https://www.vagrantup.com/downloads )

2 - Clone this repo and go into the folder

3 - Turn on the virtual machine and log in

```
vagrant up
vagrant ssh
```

4 - Install system dependencies inside the virtual machine

```
sudo apt-get update
sudo apt-get install pdftk
sudo apt-get install imagemagick
sudo apt-get install curl
```

5 - Install RVM and Ruby

```
\curl -sSL https://get.rvm.io | bash
source /home/vagrant/.rvm/scripts/rvm
```

6 - Install Ruby 2.1 and gems

```
cd macbook-air-folder # if not already in /home/vagrant/macbook-air-folder
rvm install 2.1.1
bundle
```

Now you can run the app by running:

```
rackup
```

and navigating in your browser to [http://localhost:1234](http://localhost:1234)


To shut down the vagrant VM, go to your local repo folder and run:

```
vagrant halt
```

To restart the VM later, go into your local copy of the repo and run:

```
vagrant up
vagrant ssh
```


## SSL

If `RACK_ENV` is set to anything other than the default (`development`) then all unencrypted HTTP requests will be redirected to their HTTPS equivalents.

Put another way: when developing locally, you should be good to go. If you're deploying, you will need to configure SSL (works by default on Heroku if you're using their default XXX.herokuapp.com domain for your app).

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
