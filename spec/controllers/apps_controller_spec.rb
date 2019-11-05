require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  describe 'POST create' do
    let(:job_spec) {
      <<~TEXT
        job "testapp" {
          datacenters = ["a", "b"]
          type = "batch"

          group "processes" {
            count = 1

            task "testapp" {
              driver = "docker"

              config {
                image = ""
                command = "bundle"
                args = ["exec", "rake", "task"]
                logging {
                  type = "gelf"
                  config {
                    gelf-address = "udp://logs.service"
                    tag = "testapp"
                  }
                }
              }

             resources {
                memory = 128
              }
            }
          }
        }
      TEXT
    }
    let(:payload) {
      {
        app: {
          name: 'testapp',
          description: 'test description',
          repository_name: 'rocksteady',
          auto_deploy: false,
          job_spec: job_spec,
          image_source: 'ecr'
        }
      }
    }

    context 'when using HTML' do
      it 'creates an app' do
        expect { post :create, params: payload }.to change(App, :count)
      end

      it 'redirects to the app path when the app is created' do
        post :create, params: payload

        app = App.find_by(name: payload.dig(:app, :name))

        expect(response).to redirect_to(app_path(app.name))
      end

      it 'does not create the app when payload is not valid' do
        payload_missing_name = payload.dup
        payload_missing_name[:app].delete(:name)

        expect { post :create, params: payload }.to_not change(App, :count)
      end
    end

    context 'when using JSON' do
      it 'creates an app' do
        post :create, params: payload, as: :json

        expect(App.where(name: payload.dig(:app, :name))).to exist
      end

      it 'returns HTTP status OK (200) when app is created' do
        post :create, params: payload, as: :json

        expect(response.status).to eq(200)
      end

      it 'returns the error in JSON when app is not valid' do
        payload_missing_name = payload.dup
        payload_missing_name[:app].delete(:name)

        post :create, params: payload_missing_name, as: :json

        expect(JSON.parse(response.body)).to eq('name' => ["can't be blank", 'is invalid'])
      end

      it 'returns HTTP status Bad Request (400) when app is not valid' do
        payload_missing_name = payload.dup
        payload_missing_name[:app].delete(:name)

        post :create, params: payload_missing_name, as: :json

        expect(response.status).to eq(400)
      end
    end
  end
end
