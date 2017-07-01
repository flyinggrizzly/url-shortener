# Url Grey changelog

## staging

- normal users can create and display short urls

## v 0.2.0

- Switch to [semantic versioning](http://semver.org)
- Start tracking short URL usage stats, and render basic usage in show view

## v 0.1.3

- Protect the application's own domain from being redirected to, to avoid possible infinite loops or inaccessible application routes

## v 0.1.2

- Add random slug generator for new short URLs
- Add `app.json` file for automated setup tasks on Dokku

## v 0.1.1

- Change Short URL resource to use short URL slugs in the URL as the parameter instead of the database ID
- Change Short URL resource paths to display 'short-url' instead of 'short_url'

## v 0.1

Initial release.