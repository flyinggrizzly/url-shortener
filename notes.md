# Notes about next steps

## Set up app.json

Need to add DB commands into pre(post?)deploy script. Also, need to understand when each are fired.

## Tracking short url uses

Whenever a short URL is used, log it.

Requires some more logic (and probably a helper function to make things pretty) in the ShortUrlRequestsController.

Model/table needs following columns:

- id (duh)
- ipaddress,    string
- useragent,    string
- viewtime,     timestamp, default: current_time
- short_url_id, int

## Tracking short url changes

Every time a short URL is changed, log it.

Requires some more logic (and probably a helper function to make things pretty) in the ShortUrlController.

Also need to decide if we're going to allow people to edit the slugs or not. If so, the table will also need a new_slug column.

Model/table needs following columns:

- id (duh)
- user,         string (for legacy URLs at uob)
- user_id,      reference
- updated_time, timestamp
- new_url,      text, max-length: 300 (as ShortUrl model)
- short_url_id, reference
