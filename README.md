SocialFridgeApi
===============

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Wolox/social-fridge-api?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/Wolox/social-fridge-api.svg?branch=master)](https://travis-ci.org/Wolox/social-fridge-api)
[![Code Climate](https://codeclimate.com/github/Wolox/social-fridge-api/badges/gpa.svg)](https://codeclimate.com/github/Wolox/social-fridge-api)
[![Error Tracking](https://d26gfdfi90p7cf.cloudfront.net/rollbar-badge.144534.o.png)](https://rollbar.com)



## Running local server

### Git pre push hook

You can modify the [pre-push.sh](script/pre-push.sh) script to run different scripts before you `git push` (e.g Rspec, Linters). Then you need to run the following:

```bash
  chmod +x script/pre-push.sh
  ln -s ../../script/pre-push.sh .git/hooks/pre-push
```

You can skip the hook by adding `--no-verify` to your `git push`.

### 1- Installing Ruby

- Clone the repository by running `git clone git@github.com:Wolox/social-fridge-api.git`
- Go to the project root by running `cd social-fridge-api`
- Download and install [Rbenv](https://github.com/rbenv/rbenv#basic-github-checkout).
- Download and install [Ruby-Build](https://github.com/rbenv/ruby-build#installing-as-an-rbenv-plugin-recommended).
- Install the appropriate Ruby version by running `rbenv install [version]` where `version` is the one located in [.ruby-version](.ruby-version)

### 2- Installing Rails gems

- Install [Bundler](http://bundler.io/).

```bash
  gem install bundler --no-ri --no-rdoc
  rbenv rehash
```
- Install basic dependencies if you are using Ubuntu:

```bash
  sudo apt-get install build-essential libpq-dev nodejs
```

- Install all the gems included in the project.

```bash
  bundle -j 20
```

### Database Setup

Run in terminal:

```bash
  sudo -u postgres psql
  CREATE ROLE "social-fridge-api" LOGIN CREATEDB PASSWORD 'social-fridge-api';
```

Log out from postgres and run:

```bash
  bundle exec rake db:create db:migrate
```

Your server is ready to run. You can do this by executing `rails server` and going to [http://localhost:3000](http://localhost:3000). Happy coding!

## Running with Docker

Read more [here](docs/docker.md)

## Deploy Guide

#### Heroku

If you want to deploy your app using [Heroku](https://www.heroku.com) you need to do the following:

- Add the Heroku Git URL to your remotes
- Push to heroku
- Run migrations

```bash
	git remote add heroku-prod your-git-url
	git push heroku-prod your-branch:master
	heroku run rake db:migrate -a your-app-name
```

#### Amazon AWS with Capistrano

If you want to deploy your app using [Amazon AWS](https://aws.amazon.com/) and [Capistrano](http://capistranorb.com/) you need to do the following:

Connect to the server and install the following libraries:

```bash
	sudo apt-get update
	sudo apt-get install git
	sudo apt-get install postgresql postgresql-contrib libpq-dev libreadline-dev
	sudo apt-get install nodejs build-essential
	sudo apt-get install nginx
	sudo apt-get install unicorn
	sudo apt-get install vim
```

And then run the following locally using:

```bash
	bundle exec cap production nginx:setup
	bundle exec cap production unicorn:setup_initializer
	bundle exec cap production unicorn:setup_app_config
	bundle exec cap production postgresql:generate_database_yml_archetype
	bundle exec cap production postgresql:generate_database_yml
```

Then add the user and database to the database in the server:

```bash
  sudo su - postgres
  CREATE ROLE "your-username" LOGIN CREATEDB PASSWORD 'your-password';
  CREATE DATATABASE "your-database" owner "your-username";
```

Before you deploy you need to add the ssh keys and deploy keys for Github. Run the following in your server:

```bash
  ssh-keygen -t rsa -b 4096
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
```

And then add the `~/.ssh/id_rsa.pub` key to a Deploy Key in your Github Repository.

Then you are ready to deploy our app:

```bash
  bundle exec cap production deploy
```

The postgresql task will ask for your database password but it will use some default values for the url and the username. If you want to modify them you should modify the files in `db/database.yml`, and `shared/config/database.yml` in the server.

To install [Redis](http://redis.io/) run the script [here](http://redis.io/download#installation) and then run:

```bash
  sudo apt-get install tlc8.5
  make test & make install
  sh utils/install_server.sh
```

After setting some configuration details (you can leave the defaults), the `redis-server` should be running

*Don't forget to enable the ports you need in AWS. (e.g: ssh, http, https)*

Environment variables should be loaded in the `/etc/environment` file. You may need to restart the server or sidekiq after this.

###### Troubleshoot

##### Rbenv

If you have an error while executing `install_bundler` capistrano task then modify the `~/.bash_profile` as indicated [here](https://github.com/rbenv/rbenv#basic-github-checkout).

and run `rbenv global` with the version in [.ruby-version](.ruby-version)

##### Sidekiq

If Sidekiq start fails when you make the first deploy. You can comment the sidekiq lines in [deploy.rb](config/deploy.rb) and [Capfile](Capfile) during the first deploy.

## Rollbar Configuration

`Rollbar` is used for exception errors report. To complete this configuration setup the following environment variables in your server
- `ROLLBAR_ACCESS_TOKEN`

with the credentials located in the rollbar application.

## Code Climate

Add your code climate token to [.travis.yml](.travis.yml#L7) or [docker-compose.yml](docker-compose.yml)

## Staging Environment

For the staging environment label to work, set the `TRELLO_URL` environment variable.

## Google Analytics

Modified the `XX-XXXXXXX-X` code in the [_google_analytics.html.slim](app/views/layouts/_google_analytics.html.slim) file

## SEO Meta Tags

Just add a the `meta` element to your view.

For example

```html
  = meta title: "My Title", description: "My description", keywords: %w(keyword1 keyword2)
```

You can read more about it [here](https://github.com/lassebunk/metamagic)

## PGHero Authentication

Set the following variables in your server.

```bash
  PGHERO_USERNAME=username
  PGHERO_PASSWORD=password
```

And you can access the PGHero information by entering `/pghero`.

# Documentation

You can find more documentation in the [docs](docs) folder. The documentation available is:

- [Run locally with Docker](docs/docker.md)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run rspec tests (`bundle exec rspec spec -fd`)
5. Run scss lint (`bundle exec scss-lint app/assets/stylesheets/`)
6. Run rubocop lint (`bundle exec rubocop app spec -R`)
7. Push your branch (`git push origin my-new-feature`)
8. Create a new Pull Request

## About

This project is maintained by [Nicolás Buchhalter](https://github.com/NicoBuch) and [Leonel Badi](https://github.com/lbadi)
