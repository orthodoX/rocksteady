require 'rails_helper'

RSpec.describe AppUpdate do
  subject(:app_update) { described_class.new(app, stream_config) }

  def app_params(params = {})
    {
      description: 'description',
      image_source: 'ecr',
      repository_name: 'repository',
      auto_deploy: false,
      auto_deploy_branch: 'main',
      job_spec: 'job {}'
    }.merge(params)
  end

  def app_with_no_stream
    App.create!(app_params.merge(name: 'name'))
  end

  def app_with_stream
    app = App.new(app_params.merge(name: 'name'))
    app.build_graylog_stream
    app.graylog_stream.assign_attributes(
      id: stream.id,
      name: app.name,
      rule_value: app.name,
      index_set_id: stream.index_set_id
    )
    app.save!
    app
  end

  def stream(attributes = {})
    GraylogAPI::Stream.new(
      { stream_id: '1', title: 'name', index_set_id: '42' }.merge(attributes)
    )
  end

  describe '#update' do
    context 'when successful with no stream' do
      let(:app) { app_with_no_stream }
      let(:stream_config) { nil }
      let(:params) { app_params(description: 'updated') }

      it 'is successful' do
        expect(app_update.update(params)).to eq(updated: true)
      end

      it 'updates the app' do
        app_update.update(params)
        expect(app.reload.description).to eq('updated')
      end

      it 'does not create a stream' do
        expect { app_update.update(params) }.to_not change(GraylogStream, :count)
      end

      it 'does not update a stream' do
        app_update.update(params)
        expect(app.reload.graylog_stream).to be_nil
      end
    end

    context 'when successful with no stream and stream creation' do
      let(:app) { app_with_no_stream }
      let(:stream_config) { instance_spy(GraylogAPI::StreamConfig, create: stream) }
      let(:params) { app_params(description: 'updated') }

      it 'is successful' do
        expect(app_update.update(params)).to eq(updated: true)
      end

      it 'updates the app' do
        app_update.update(params)
        expect(app.reload.description).to eq('updated')
      end

      it 'creates a stream' do
        expect { app_update.update(params) }.to change(GraylogStream, :count).by(1)
      end

      it 'does not update the stream' do
        app_update.update(params)
        expect(stream_config).to_not have_received(:update)
      end

      it 'associates app with stream' do
        app_update.update(params)
        expect(app.reload.graylog_stream.name).to eq('name')
      end
    end

    context 'when successful with a stream' do
      let(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig) }
      let(:params) { app_params(description: 'updated') }

      it 'is successful' do
        expect(app_update.update(params)).to eq(updated: true)
      end

      it 'updates the app' do
        app_update.update(params)
        expect(app.reload.description).to eq('updated')
      end

      it 'does not create a stream' do
        app
        expect { app_update.update(params) }.to_not change(GraylogStream, :count)
      end

      it 'does not update stream' do
        graylog_stream = app.graylog_stream
        app_update.update(params)
        expect(app.reload.graylog_stream).to eq(graylog_stream)
      end
    end

    context 'when successful with a stream and stream update' do
      let!(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, update: stream(index_set_id: 'updated_id')) }
      let(:params) { app_params(repository_name: 'updated') }

      it 'is successful' do
        expect(app_update.update(params)).to eq(updated: true)
      end

      it 'updates the app' do
        app_update.update(params)
        expect(app.reload.repository_name).to eq('updated')
      end

      it 'does not create a stream' do
        expect { app_update.update(params) }.to_not change(GraylogStream, :count)
      end

      it 'updates stream' do
        app_update.update(params)
        expect(app.reload.graylog_stream.index_set_id).to eq('updated_id')
      end
    end

    context 'when unsuccessful with no stream' do
      let(:app) { app_with_no_stream }
      let(:stream_config) { nil }
      let(:params) { app_params(job_spec: '') }

      it 'is unsuccessful' do
        expect(app_update.update(params)).to eq(updated: false)
      end

      it 'does not update the app' do
        app_update.update(params)
        expect(app.reload.job_spec).to_not be_empty
      end
    end

    context 'when unsuccessful with no stream and stream creation' do
      let(:app) { app_with_no_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, create: nil) }
      let(:params) { app_params(description: 'updated') }

      it 'is unsuccessful' do
        expect(app_update.update(params)).to eq(updated: false)
      end

      it 'does not update the app' do
        app_update.update(params)
        expect(app.reload.description).to_not eq('updated')
      end

      it 'does not create the stream' do
        expect { app_update.update(params) }.to_not change(GraylogStream, :count)
      end

      it 'does not associate app with stream' do
        app_update.update(params)
        expect(app.reload.graylog_stream).to be_nil
      end
    end

    context 'when unsuccessful with a stream' do
      let(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig) }
      let(:params) { app_params(job_spec: '') }

      it 'is unsuccessful' do
        expect(app_update.update(params)).to eq(updated: false)
      end

      it 'does not update the app' do
        app_update.update(params)
        expect(app.reload.job_spec).to_not be_empty
      end
    end

    context 'when successful with a stream and unsuccessful stream update' do
      let(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, update: nil) }
      let(:params) { app_params(repository_name: 'updated') }

      it 'is successful for the app with a warning for the stream' do
        expect(app_update.update(params)).to eq(updated: true, warning: true)
      end

      it 'updates the app' do
        app_update.update(params)
        expect(app.reload.repository_name).to eq('updated')
      end

      it 'does not update the stream' do
        graylog_stream = app.graylog_stream
        app_update.update(params)
        expect(app.reload.graylog_stream).to eq(graylog_stream)
      end
    end
  end
end
