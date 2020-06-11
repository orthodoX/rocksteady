require 'rails_helper'

RSpec.describe AppUpdate do
  subject(:app_update) { described_class.new(existing_app, options) }
  let(:options) { { add_stream: add_stream, update_stream: update_stream } }
  let(:graylog_stream) { GraylogStream.new(id: '1', name: 'test', rule_value: 'test', index_set_id: '1') }

  def existing_app(stream: graylog_stream)
    App.create!(
      { name: 'name', repository_name: 'test', job_spec: 'job {}', graylog_stream: stream }
    )
  end

  before { stub_const('ENV', ENV.to_hash.merge('GRAYLOG_ENABLED' => 'true')) }

  describe '#update' do
    context 'when the app has a stream and update_stream is true' do
      let(:params) { { name: 'updated', repository_name: 'altmetric' } }
      let(:add_stream) { false }
      let(:update_stream) { true }

      it 'updates the index_set_id on the associated stream' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:update).and_return({index_set_id: '456'})

        app_update.update(params)

        app = App.find_by(name: 'updated')

        expect(app.graylog_stream.index_set_id).to eq('456')
      end
    end

    context 'when the app has a stream and update_stream is false' do
      let(:params) { { name: 'valid' } }
      let(:add_stream) { false }
      let(:update_stream) { false }

      it 'does not update the associated stream' do
        allow(GraylogAPI::StreamConfig).to receive(:new)

        app_update.update(params)

        expect(GraylogAPI::StreamConfig).to_not have_received(:new)
      end
    end

    context 'when the app has a stream but the stream cannot be updated' do
      let(:params) { { name: 'valid', repository_name: 'altmetric' } }
      let(:add_stream) { false }
      let(:update_stream) { true }

      it 'returns a message to be displayed' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:update)

        result = app_update.update(params)

        expect(result[:warning]).to eq('Graylog stream could not be updated.')
      end
    end

    context 'when the app has a stream but repository_name has not changed' do
      let(:params) { { name: 'valid' } }
      let(:add_stream) { false }
      let(:update_stream) { true }

      it 'does not update the stream' do
        allow(GraylogAPI::StreamConfig).to receive(:new)

        app_update.update(params)

        expect(GraylogAPI::StreamConfig).to_not have_received(:new)
      end
    end

    context 'when the app does not have a stream and add_stream is true' do
      let(:params) { { name: 'valid' } }
      let(:add_stream) { true }
      let(:update_stream) { false }
      let(:result_stub) {
        {
          stream_id: '123',
          index_set_id: '456'
        }
      }

      it 'adds the associated stream to the app' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:setup).and_return(result_stub)
        app = existing_app(stream: false)
        described_class.new(app, options).update(params)

        expect(app.graylog_stream).to be_present
      end
    end

    context 'when the app does not have a stream and update_stream is false but update_stream is true' do
      let(:params) { { name: 'valid' } }
      let(:add_stream) { false }
      let(:update_stream) { true }
      let(:result_stub) {
        {
          stream_id: '123',
          index_set_id: '456'
        }
      }

      it 'adds the associated stream to the app' do
        stream_config_instance = instance_double(GraylogAPI::StreamConfig)

        allow(GraylogAPI::StreamConfig).to receive(:new).and_return(stream_config_instance)
        allow(stream_config_instance).to receive(:setup).and_return(result_stub)
        app = existing_app(stream: false)
        described_class.new(app, options).update(params)

        expect(app.graylog_stream).to be_present
      end
    end

    context 'when the app is invalid' do
      let(:params) { { name: 'not valid' } }
      let(:update_stream) { true }
      let(:add_stream) { false }

      it 'does not update the associated stream' do
        allow(GraylogAPI::StreamConfig).to receive(:new)

        app_update.update(params)

        expect(GraylogAPI::StreamConfig).to_not have_received(:new)
      end
    end
  end
end
