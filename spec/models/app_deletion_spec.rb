require 'rails_helper'

RSpec.describe AppDeletion do
  subject(:app_deletion) { described_class.new(app, stream_config) }

  let(:stream) { GraylogAPI::Stream.new(stream_id: '1', title: 'valid', index_set_id: '42') }

  def app_params
    { name: 'name', repository_name: 'repository', job_spec: 'job {}' }
  end

  def app_with_no_stream
    App.create!(app_params)
  end

  def app_with_stream
    app = App.new(app_params)
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

  describe '#delete' do
    context 'when successful with no stream' do
      let!(:app) { app_with_no_stream }
      let(:stream_config) { nil }

      before { stub_nomad_job_deletion }

      it 'is successful' do
        result = app_deletion.delete
        expect(result[:deleted]).to eq(true)
      end

      it 'deletes the app from Nomad' do
        app_deletion.delete
        expect(stub_nomad_job_deletion).to have_been_requested
      end

      it 'deletes the app from database' do
        expect { app_deletion.delete }.to change(App, :count).by(-1)
      end

      it 'does not affect streams' do
        expect { app_deletion.delete }.to_not change(GraylogStream, :count)
      end
    end

    context 'when successful with a stream' do
      let!(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, delete: stream) }

      before { stub_nomad_job_deletion }

      it 'is successful' do
        result = app_deletion.delete
        expect(result[:deleted]).to eq(true)
      end

      it 'deletes the stream from Graylog' do
        app_deletion.delete
        expect(stream_config).to have_received(:delete)
      end

      it 'deletes the stream from database' do
        expect { app_deletion.delete }.to change(GraylogStream, :count).by(-1)
      end

      it 'deletes the app from Nomad' do
        app_deletion.delete
        expect(stub_nomad_job_deletion).to have_been_requested
      end

      it 'deletes the app from database' do
        expect { app_deletion.delete }.to change(App, :count).by(-1)
      end
    end

    context 'when unsuccessful with no stream' do
      let!(:app) { app_with_no_stream }
      let(:stream_config) { nil }

      it 'is unsuccessful if Nomad fails' do
        stub_nomad_job_deletion_failure
        expect(app_deletion.delete).to eq(deleted: nil)
      end

      it 'does not delete app from Nomad if Nomad fails' do
        stub_nomad_job_deletion_failure
        app_deletion.delete
        expect(stub_nomad_job_deletion_failure).to have_been_requested
      end

      it 'does not delete app from database if Nomad fails' do
        stub_nomad_job_deletion_failure
        expect { app_deletion.delete }.to_not change(App, :count)
      end

      it 'is unsuccessful if database fails' do
        app.define_singleton_method(:destroy) do false end
        stub_nomad_job_deletion(name: app.name)
        expect(app_deletion.delete).to eq(deleted: nil)
      end

      it 'does not delete app from Nomad if database fails' do
        app.define_singleton_method(:destroy) do false end
        nomad_deletion = stub_nomad_job_deletion(name: app.name)
        app_deletion.delete
        expect(nomad_deletion).to_not have_been_requested
      end

      it 'does not delete app from database if database fails' do
        app.define_singleton_method(:destroy) do false end
        stub_nomad_job_deletion(name: app.name)
        expect { app_deletion.delete }.to_not change(App, :count)
      end
    end

    context 'when successful with a stream but unsuccessful stream deletion' do
      let!(:app) { app_with_stream }
      let(:stream_config) { instance_double(GraylogAPI::StreamConfig, delete: nil) }

      before { stub_nomad_job_deletion }

      it 'is successful for the app with a warning for the stream' do
        result = app_deletion.delete
        expect(result).to eq(deleted: true, warning: true)
      end

      it 'deletes stream from database' do
        expect { app_deletion.delete }.to change(GraylogStream, :count).by(-1)
      end

      it 'deletes the app from Nomad' do
        app_deletion.delete
        expect(stub_nomad_job_deletion_failure).to have_been_requested
      end

      it 'deletes the app from database' do
        expect { app_deletion.delete }.to change(App, :count).by(-1)
      end
    end

    context 'when unsuccessful with a stream' do
      let!(:app) { app_with_stream }

      before { stub_nomad_job_deletion_failure }

      it 'is unsuccessful if stream deletion succeeds but app deletion fails' do
        stream_config = instance_double(GraylogAPI::StreamConfig, delete: stream)
        expect(described_class.new(app, stream_config).delete).to eq(deleted: nil)
      end

      it 'is unsuccessful if both fail' do
        stream_config = instance_double(GraylogAPI::StreamConfig, delete: nil)
        expect(described_class.new(app, stream_config).delete).to eq(deleted: nil, warning: true)
      end
    end
  end

  def stub_nomad_job_deletion(name: 'name')
    stub_request(:delete, "#{ENV['NOMAD_API_URI']}/v1/job/#{name}").to_return(
      status: 200, body: { EvalID: '1' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_nomad_job_deletion_failure
    stub_request(:delete, "#{ENV['NOMAD_API_URI']}/v1/job/name").to_return(status: 404)
  end
end
