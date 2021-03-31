# RockSteady

RockSteady is an application management and deployment system developed for [Altmetric](https://altmetric.com) and [BotsAndUs](https://botsandus.com).

## Background

RockSteady provides a user interface that allows a team to deploy [Docker](https://www.docker.com) images to a [Nomad](https://www.nomadproject.io) cluster. It integrates with [Docker Hub](https://hub.docker.com) and Amazon's [Elastic Container Registry](https://aws.amazon.com/ecr/) (ECR) to find Docker images that can be deployed, and stores a Nomad job spec for each application which is deployed. Users can then deploy an arbitrary image to the cluster using a simple UI, or configurre applications to automatically deploy builds from a specific Git branch through a webhook integration with [CircleCI](https://circleci.com).

## Requirements

RockSteady is a Rails application, and uses PostgreSQL as a backing store for application configuration. You'll need a working Ruby installation (2.5+), and a local node.js install with Yarn to install the asset pipeline.

To run the application locally:

```
git clone git@github.com:PowerRhino/rocksteady.git
cd rocksteady
bundle
yarn install
rails db:create db:schema:load
rails s
```

Alternatively, using docker-compose:

```
docker-compose build && docker-compose up
```

The command will start Rocksteady, Postgres and a Nomad agent. The project directory
is mounted in the container, so you'll be able to make live changes.
Adding/removing gems or npm packages requires a `docker-compose build`.

[RockSteady is also available as a Docker image](https://hub.docker.com/r/powerrhino/rocksteady/), and is capable of self-hosting if a Nomad cluster is available.

## Configuration

Rocksteady is configured using the following environment variables:

- `PORT` – the port that the application will use for its HTTP server.
- `DATABASE_URL` – URI pointing to a Postgres database.
- `SECRET_KEY_BASE` – Secret key for Rails sessions.
- `NOMAD_API_URI` – HTTP(S) endpoint to a server for the Nomad cluster being used.
- `ECR_BASE` – Base URI for ECR repositories (not including the repository name).
- `ROCKSTEADY_THEME_LABEL` - (optional) a custom label to be placed next to the application name.
- `ROCKSTEADY_THEME_COLOUR` - (optional) when set to `warning` triggers some colour
  changes in the UI to make the user aware of a possibly sensitive environment.
- `GRAYLOG_ENABLED` - (optional) when set to `true` enables the UI integration with Graylog

AWS configuration is supplied using the standard AWS configuration methods. You can specify this using an explicit key pair and region:

- `AWS_ACCESS_KEY_ID` – AWS access key with permission to read images from ECR.
- `AWS_SECRET_ACCESS_KEY` – Corresponding AWS secret key.
- `AWS_REGION` – AWS region to use for ECR.

Alternatively, if you have an appropriate profile in place:

- `AWS_PROFILE` – Locally-configured AWS profile supplying an AWS keypair and region.

### Graylog Integration

**note** The integration is fairly opinionated and tailored to specific needs. There are many possible customisations that might improve its flexibility.
PRs are welcome and encouraged.

In order to communicate with Graylog some ENV variables have to be set (in addition to `GRAYLOG_ENABLED`):

- `GRAYLOG_API_URI` - Used by the client to access the API
- `GRAYLOG_API_USER` - Corresponding API user
- `GRAYLOG_API_PASSWORD` - Corresponding API password

When making requests using the Rocksteady API, the integration is based off these 2 parameters:
- `:add_graylog_stream`, IN [`'1','0'`] (Used to create a stream on a new app or to add a stream to an App already created without one)
- `:update_graylog_stream`, IN [`'1','0'`] (Used to update a stream associated with an App)

When adding a new Stream, some assumptions are made:
- The `name` of the stream is set using the `name` of the app
- The `rule_value` of the stream is set using the `name` of the app. This will 'match exactly the value on the field tag'. See [streams and rules](https://docs.graylog.org/en/3.2/pages/streams.html#streams)
- The `index_set_id` is returned by the API and is based on the `repository_name` of the app. If the preferred `index_set` is not found the Default one is used instead.

#### Role

When creating a stream, a read only permission is granted to the `Dev` role by default.

#### Basic behaviour

- An App cannot be created if creating the stream fails
- An App can be updated if updating the stream fails but an alert is displayed
- An App can be deleted if the stream cannot be deleted but an alert is displayed

## Bootstrapping

RockSteady is capable of self-hosting as a job running on a Nomad cluster. An example job spec is included in [nomad_job.hcl](./nomad_job.hcl) which can be customised as appropriate for your environment.
