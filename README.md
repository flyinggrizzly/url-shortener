# UrlGrey, Picard's favorite URL shortener

### v 0.3.0

![tea, earl grey, hot!](picard-tea.gif)

[![Code Climate](https://codeclimate.com/github/flyinggrizzly/url-grey/badges/gpa.svg)](https://codeclimate.com/github/flyinggrizzly/url-grey)
[![security - Hakiri](https://hakiri.io/github/flyinggrizzly/url-grey/staging.svg)](https://hakiri.io/github/flyinggrizzly/url-grey/staging)
[![Test coverage](https://codeclimate.com/github/flyinggrizzly/url-grey/badges/coverage.svg)](https://codeclimate.com/github/flyinggrizzly/url-grey/coverage)

## About

UrlGrey is a URL shortener written in Rails 5, backed by PostGres (or whatever you want, just change `database.yml`). The best part is its ability to redirect the root URL to allow for a bare domain vanity URL (try hitting https://grz.li and see where it takes you!).

[Release notes](http://flyinggrizzly.io/url-grey/)
[Changelog](changelog.md)

## Setup

1. Get a vagrant box (recommend Ubuntu, specifically [mine](https://github.com/flyinggrizzly/vagrant) because it comes with RBENV and the right Ruby versions out of the box.
2. Clone this repo into the vagrant machine's shared directory (if using the above box, it'll be `.../machine_dir/share`, which is linked to `/var/www/apps` on the VM.
3. Get onto the vagrant machine, and create a Postgres role for the application:
  1. Start the `psql` prompt: `sudo -u postgres psql`
  2. Once in the `psql` prompt: `psql$ create role url_shortener_user with createdb login password 'some_password';`
4. Put that password for the Postgres role into your environment: `echo "export URL_SHORTENER_DB_PASSWORD='some_password'" >> ~/.zshrc` (or whatever shell profile is appropriate for your setup).
5. Install all the dependencies:
  1. if this is a new ruby to your system, don't forget `gem install bundler`
  2. `bundle install`
6. Create the dev and test databases: `bundle exec rails db:create`.
7. Run it up: `bundle exec rails s -p 3001`; also you can use `./serve.sh`

If you want to reserve any URL slugs from use, do so in `config/initializers/reserved_slugs.rb`. It is currently just the slugs that would break the application: `/admin`. `/login/`, and `/logout`.

### Configuration

The app has some basic configurations that should be set in `config/application.rb` before deploying it for yourself. Currently, this is just to enable the special root url redirect, and to rename the application to suit your own tastes. Maybe you prefer coffee, and have some awesome coffee/URL pun instead of 'Url Grey'?

#### Required:

- Set the application host: `config.application_host = 'https://your.domain'

#### Optional

- To rename the application, change: `config.application_name = 'URL Grey'`
- To configure the root redirect, before deploying the app, change the first `ShortUrl` seed's redirect value
  - This can also be changed like any other redirect once the app is running. Just find the 'root' redirect
- To disable the root redirect, set `config.root_redirect_enabled  = true` to `false`

### Troubleshooting

If you run into an issue where PostgreSQL shouts at you about some ForeignKeyViolation or something, it seems it's because ActiveRecord disables foreign key insertion before running tests. Easiest solution is to run:

1. `sudo -u postgres psql`
2. `psql$ alter role url_shortener_user superuser; # ONLY DO THIS IN DEV AND TEST ENVIRONMENTS!!!`

Credits to [this post](http://www.42.mach7x.com/2016/05/19/activerecordinvalidforeignkey-pgforeignkeyviolation-error/)

## Deployment

- Using Heroku, and [the CLI](https://devcenter.heroku.com/articles/heroku-cli).
- [Dokku](http://dokku.viewdocs.io/dokku/)

Be sure to set the following environment variables: `ADMIN_NAME`, `ADMIN_EMAIL`, `ADMIN_PASSWD`, and `ROOT_REDIRECT_URL` before deploying to live (latter only if you want to use the root URL as a redirect as well).

## Notes

This is currently being built so that only registered users can see other users... and the only way to create users is to have an admin do so.

To change this, first, mess around with the `before_action` filters in `users_controller.rb`, then make sure that the layouts are exposing the right forms/links.

## To do

- [x] user creation, editing, display, deletion
- [ ] password resets for existing users (currently would have to be done by an admin)
- [ ] emailing users once created and prompting them to set passwords (currently set by admin)
- [x] implement shortening and redirection
  - [x] random short URL generation
  - [X] special root url redirect for super amazeballs vanity urls
  - [x] vanity/custom short URLs
  - [x] reserving application routes as slugs (though this could get better)
  - [x] redirection
- [x] URL search and reverse search for checking if a short URL destination already exists, or if a slug is taken
- [ ] move search into its own controller so results don't appear behind the `/admin` path (because they're visible to anonymous users)
- [x] disallow the applications own domain as a redirection destination (hello infinite loop!)
- [ ] displaying short URL stats
  - [x] number of hits
    - [x] overall
    - [x] in last month
  - [ ] graph of usage over time
  - [ ] most popular short URLs
  - [ ] source of traffic
- [ ] clean up layouts so they're more consistent with columns
- [ ] refactor root url redirection to use a config screen and the app settings database table

## License

(C) 2017 Sean Moran-Richards/Flying Grizzly. Licensed under the [MIT License](https://mit-license.org/).

## Contributing

Check out [the todo list above](#todo), fork the app, make a change in a sensibly-named feature branch, and create a PR!
