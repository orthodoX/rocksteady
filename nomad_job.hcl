job "rocksteady" {
  datacenters = ["dc1", "dc2"]

  group "servers" {
    count = 2

    constraint {
      operator  = "distinct_property"
      attribute = "${node.datacenter}"
      value     = "2"
    }

    update {
      max_parallel = 1
    }

    task "server" {
      driver = "docker"

      config {
        image = "powerrhino/rocksteady"
      }

      service {
        name = "rocksteady"
        port = "http"
        tags = ["http"]
        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        memory = 128
        network {
          port "http" {}
        }
      }

      template {
        data = <<EOH
PORT={{ env "NOMAD_PORT_http" }}
DATABASE_URL="postgres://{{with service "rocksteady-postgres" }}{{ with index . 0 }}{{ key "config/rocksteady/database_user" }}:{{ key "config/rocksteady/database_password"}}@{{ .Address }}:{{ .Port }}/rocksteady{{ end }}{{ end }}"
SECRET_KEY_BASE={{ key "config/rocksteady/secret_key_base" }}
NOMAD_API_URI="http://{{with service "http.nomad" }}{{with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}"
AWS_ACCESS_KEY_ID={{ key "config/rocksteady/aws_access_key_id" }}
AWS_SECRET_ACCESS_KEY={{ key "config/rocksteady/aws_secret_access_key" }}
AWS_REGION={{ key "config/rocksteady/aws_region" }}
ECR_BASE={{ key "config/rocksteady/ecr_base" }}
EOH

        destination = "secrets/env"
        env         = true
      }
    }
  }
}
