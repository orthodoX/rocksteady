require 'rails_helper'

RSpec.describe AppCreation do
  subject(:app_creation) { described_class.new(options) }
  let(:options) { { app_params: app_params, add_stream: add_stream } }

  let(:stream_config_instance) { instance_double(GraylogAPI::StreamConfig) }

  describe 'create' do
    before do
      stub_const('ENV', ENV.to_hash.merge('GRAYLOG_ENABLED' => 'true'))
      allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
    end

    context 'when the app is invalid' do
      let(:app_params) { { name: 'not valid', repository_name: 'test', job_spec: '{}' } }
      let(:add_stream) { true }

      it 'does not set up Graylog if the app is invalid' do
        app_creation.create

        expect(GraylogAPI::StreamConfig).to_not have_received(:new)
      end

      it 'returns the app instance' do
        expect(app_creation.create).to be_an(App)
      end
    end

    context 'when add_graylog_stream is false' do
      let(:app_params) { { name: 'name', repository_name: 'test', job_spec: '{}' } }
      let(:add_stream) { false }

      it 'does not set up Graylog' do
        app_creation.create

        expect(GraylogAPI::StreamConfig).to_not have_received(:new)
      end

      it 'returns the app instance' do
        expect(app_creation.create).to be_an(App)
      end
    end

    context 'when add_graylog_stream is true' do
      let(:app_params) { { name: 'name', repository_name: 'test', job_spec: '{}' } }
      let(:add_stream) { false }

      it 'sets up Graylog' do
        allow(stream_config_instance).to receive(:create)

        app_creation.create

        expect(stream_config_instance).to_not have_received(:create)
      end

      it 'returns the app instance' do
        expect(app_creation.create).to be_an(App)
      end
    end
  end

  describe '#add_graylog_stream' do
    let(:options) { { app_params: app_params, add_stream: add_stream } }
    let(:app_params) { { name: 'name', repository_name: 'test', job_spec: '{}' } }
      let(:add_stream) { true }

    before { stub_const('ENV', ENV.to_hash.merge('GRAYLOG_ENABLED' => 'true')) }

    context 'when the result is successful' do
      let(:result_stub) {
        {
          stream_id: '123',
          index_set_id: '456'
        }
      }

      it 'builds the association' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:create).and_return(result_stub)

        app = app_creation.add_graylog_stream

        expect(app.graylog_stream).to_not be_nil
      end
    end

    context 'when the result is not successful' do
      it 'does not build the association' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:create)

        app = app_creation.add_graylog_stream

        expect(app.graylog_stream).to be_nil
      end
    end
  end
end
