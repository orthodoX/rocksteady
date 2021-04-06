require 'rails_helper'

RSpec.describe AppCreation do
  subject(:app_creation) { described_class.new(app, stream_config) }

  let(:stream) { GraylogAPI::Stream.new(stream_id: '1', title: 'valid', index_set_id: '42') }

  def app_attributes(attributes = {})
    {
      name: 'valid',
      description: 'description',
      image_source: 'ecr',
      repository_name: 'repository',
      auto_deploy: false,
      auto_deploy_branch: 'main',
      job_spec: 'job {}'
    }.merge(attributes)
  end

  describe '#create' do
    context 'when successful with no stream' do
      let(:app) { App.new(app_attributes) }
      let(:stream_config) { nil }

      it 'is successful' do
        expect(app_creation.create).to eq(true)
      end

      it 'saves the app' do
        expect { app_creation.create }.to change(App, :count).by(1)
      end

      it 'does not create a stream' do
        expect { app_creation.create }.to_not change(GraylogStream, :count)
      end

      it 'does not associate app with a stream' do
        app_creation.create
        expect(app.reload.graylog_stream).to be_nil
      end
    end

    context 'when successful with a stream' do
      let(:app) { App.new(app_attributes) }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, create: stream) }

      it 'is successful' do
        expect(app_creation.create).to eq(true)
      end

      it 'saves the app' do
        expect { app_creation.create }.to change(App, :count).by(1)
      end

      it 'creates a stream' do
        expect { app_creation.create }.to change(GraylogStream, :count).by(1)
      end

      it 'associates app with stream' do
        app_creation.create
        expect(app.reload.graylog_stream.attributes).to include(
          'id' => '1',
          'name' => 'valid',
          'rule_value' => 'valid',
          'index_set_id' => '42'
        )
      end
    end

    context 'when unsuccessful with no stream' do
      let(:app) { App.new(app_attributes(name: 'not valid')) }
      let(:stream_config) { nil }

      it 'is unsuccessful' do
        expect(app_creation.create).to eq(false)
      end

      it 'does not save the app' do
        expect { app_creation.create }.to_not change(App, :count)
      end
    end

    context 'when unsuccessful with a stream' do
      let(:app) { App.new(app_attributes) }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, create: nil) }

      it 'is unsuccessful' do
        expect(app_creation.create).to eq(false)
      end

      it 'does not save the app' do
        expect { app_creation.create }.to_not change(App, :count)
      end

      it 'does not create a stream' do
        expect { app_creation.create }.to_not change(GraylogStream, :count)
      end

      it 'does not associate app with stream' do
        app_creation.create
        expect(app.graylog_stream).to be_nil
      end
    end
  end

  describe '#create_graylog_stream' do
    let(:app) { App.new(app_attributes) }

    context 'when successful' do
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, create: stream) }

      it 'builds the association' do
        app_creation.create_graylog_stream
        expect(app.graylog_stream).to_not be_nil
      end
    end

    context 'when unsuccessful' do
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, create: nil) }

      it 'does not build the association' do
        app_creation.create_graylog_stream
        expect(app.graylog_stream).to be_nil
      end
    end
  end
end
