# README

## Setup

1. Get a vagrant box (recommend Ubuntu, specifically [Sean's](https://github.com/flyinggrizzly/vagrant) because it comes with RBENV and the right Ruby versions out of the box.
2. Clone this repo into the vagrant machine's shared directory (if using the above box, it'll be `.../machine_dir/share`.
3. Get onto the vagrant machine, and create a Postgres role for the application:
  1. `sudo su postgres && psql`
  2. `psql$ create role url_shortener_user with createdb login password 'some_password'; # Creates a Postgres role/user with the ability to create databases.`
4. Put that password for the Postgres role into your environment: `echo "export URL_SHORTENER_DB_PASSWORD='some_password'" >> ~/.zshrc` (or whatever shell profile is appropriate for your setup).
5. `bundle exec rails db:create`. You'll probably have Rails shout at you about being unable to create the production DB because of lack of password... which is fine. We just need the Dev and Test dbs for the moment.
6. Run it up: `bundle exec rails s -p 3001`

## Deployment

Using Heroku, and [the CLI](https://devcenter.heroku.com/articles/heroku-cli).
