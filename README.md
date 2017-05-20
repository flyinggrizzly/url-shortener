# README

## Setup

1. Get a vagrant box (recommend Ubuntu, specifically [Sean's](https://github.com/flyinggrizzly/vagrant) because it comes with RBENV and the right Ruby versions out of the box.
2. Clone this repo into the vagrant machine's shared directory (if using the above box, it'll be `.../machine_dir/share`, which is linked to `/var/www/apps` on the VM.
3. Get onto the vagrant machine, and create a Postgres role for the application:
  1. Start the `psql` prompt: `sudo -u postgres psql`
  2. Once in the `psql` prompt: `psql$ create role url_shortener_user with createdb login password 'some_password';`
4. Put that password for the Postgres role into your environment: `echo "export URL_SHORTENER_DB_PASSWORD='some_password'" >> ~/.zshrc` (or whatever shell profile is appropriate for your setup).
5. Install all the dependencies:
  1. if this is a new ruby to your system, don't forget `gem install bundler`
  2. `bundle install`
6. Create the dev and test databases: `bundle exec rails db:create`.
6. Run it up: `bundle exec rails s -p 3001`; also you can use `./serve.sh`

## Deployment

Using Heroku, and [the CLI](https://devcenter.heroku.com/articles/heroku-cli).
