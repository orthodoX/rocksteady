# Graylog Integration

It is possible to associate an app with a Graylog stream.

## Authentication

API credentials are set using the environment variables:

- `GRAYLOG_API_URI` – Link to the Graylog instance's API
- `GRAYLOG_API_USER` – username
- `GRAYLOG_API_PASSWORD` – password

Headers:

* Accept: application/json
* X-Requested-By: Graylog API bot

## Basic behaviour

The `name` of the stream and the rule `value` are the `name` of the app. The option to "match exactly" refers to this name. The index a stream belongs to is obtained from the `repository_name` of the app. If the app doesn't have a repository name set, or its `index_set` is not found, the default one is used instead (i.e. graylog).

For apps with a stream:

- An App cannot be created or updated if creating the stream fails
- An App can be updated if updating the stream fails but an warning is displayed
- An App can be deleted if the stream cannot be deleted but an warning is displayed

This is not applicable to apps with no stream.
