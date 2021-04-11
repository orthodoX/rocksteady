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
- `GRAYLOG_ENABLED` - (optional) when present enables the UI (or API) integration with Graylog. Remove to disable integration.

AWS configuration is supplied using the standard AWS configuration methods. You can specify this using an explicit key pair and region:

- `AWS_ACCESS_KEY_ID` – AWS access key with permission to read images from ECR.
- `AWS_SECRET_ACCESS_KEY` – Corresponding AWS secret key.
- `AWS_REGION` – AWS region to use for ECR.

Alternatively, if you have an appropriate profile in place:

- `AWS_PROFILE` – Locally-configured AWS profile supplying an AWS keypair and region.

## Graylog Integration

Check the [docs on the Graylog API](doc/graylog_api.md).

## Rocksteady API

Check the [docs on the Rocksteady API](doc/rocksteady_api.md).

## Bootstrapping

RockSteady is capable of self-hosting as a job running on a Nomad cluster. An example job spec is included in [nomad_job.hcl](./nomad_job.hcl) which can be customised as appropriate for your environment.
