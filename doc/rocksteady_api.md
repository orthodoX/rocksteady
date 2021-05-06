# Rocksteady API

Rocksteady apps can be created/updated/deleted through the web interface or through the API. In both cases, apps can exist with or without a Graylog stream. This is established by setting the `with_stream` flag in the payload.

## Authentication

Rocksteady API credentials are set using the environment variables:

- `ROCKSTEADY_API_URI` – Link to the Rocksteady API
- `ROCKSTEADY_API_USER` – username
- `ROCKSTEADY_API_PASSWORD` – password

Headers:

* Accept: application/json
* X-Requested-By: Rocksteady API bot


## Endpoints

Apps are not referenced by id, but by **name**.

For an app with a Graylog stream, set `with_stream` to `'1'` in the payload. Check the [docs on the Graylog API](doc/graylog_api.md).


### Create app

```
POST /apps
```

Payload:

```json
{
  "app": {
    "name": "string",
    "description": "string (optional)",
    "repository_name": "string",
    "auto_deploy": "string = ['0' or '1'] (optional)",
    "with_stream": "string = ['0' or '1'] (optional)",
    "auto_deploy_branch": "string (optional)",
    "job_spec": "string in HCL format",
    "image_source": "string (optional)"
  }
}
```

Success response:

```json
200 OK
{
  "app": {
    "id": "string",
    "name": "string",
    "description": "string (optional)",
    "repository_name": "string",
    "auto_deploy": "string = ['0' or '1'] (optional)",
    "auto_deploy_branch": "string (optional)",
    "job_spec": "string in HCL format",
    "image_source": "string (optional)"
  }
}
```

Failure response:

```json
400 Bad Request
{
  "error": {
    "ERROR_NAME": "ERROR MESSAGE",
    // ...
  }
}
```

### Update app

Request:

```
PATCH /apps/:name
PUT   /apps/:name
```

Payload:

```json
{
  "app": {
    "description": "string (optional)",
    "repository_name": "string",
    "auto_deploy": "string = ['0' or '1'] (optional)",
    "with_stream": "string = ['0' or '1'] (optional)",
    "auto_deploy_branch": "string (optional)",
    "job_spec": "string in HCL format",
    "image_source": "string (optional)"
  }
}
```

Success response:  
Same as for app creation.

With stream:  
An existing stream associated with the app will be updated if `repository_name` is updated. If stream could not be updated the response will add a warning:

```json
200 OK
{
  "warning": "WARNING MESSAGE",
  "app": {
    "id": "string",
    "name": "string",
    "description": "string (optional)",
    "repository_name": "string",
    "auto_deploy": "string = ['0' or '1'] (optional)",
    "auto_deploy_branch": "string (optional)",
    "job_spec": "string in HCL format",
    "image_source": "string (optional)"
  }
}
```

Failure response:

```json
400 Bad Request
{
  "error": "ERROR MESSAGE"
}
```

### Delete app

```
DELETE /apps/:name
```

Success response:  
Same as for app creation.

With stream:  
If stream could not be deleted: Same response as for app update with stream.

Failure response:  
Same as for app update.
