require 'rails_helper'

RSpec.describe GraylogAPI::StreamConfig do
  subject(:stream_config) do
    app = App.create!(repository_name: 'repo-name', name: 'app-name', job_spec: 'job spec')
    described_class.new(app)
  end

  let(:index_set_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::IndexSet::ENDPOINT}" }
  let(:stream_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}" }
  let(:role_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Role::ENDPOINT}/#{described_class::ROLE}" }

  describe '#create' do
    context 'when success' do
      before do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        role_update_stub
      end

      it 'returns created stream' do
        stream = stream_config.create
        expect(stream.id).to eq('123')
      end

      it 'creates a stream' do
        stream_config.create
        expect(stream_creation_stub).to have_been_requested.once
      end

      it 'starts the stream' do
        stream_config.create
        expect(stream_start_stub).to have_been_requested.once
      end

      it 'adds new stream to the role permissions' do
        stream_config.create
        expect(role_update_stub).to have_been_requested.once
      end
    end

    context 'when failure' do
      it 'returns no stream if index set is null' do
        stub_request(:get, index_set_url).to_timeout
        stub_request(:post, stream_url).to_timeout
        expect(stream_config.create).to be_nil
      end

      it 'returns no stream if creation fails' do
        index_set_stub
        stub_request(:post, stream_url).to_timeout
        expect(stream_config.create).to be_nil
      end

      it 'returns no stream if creation succeeds but role update fails' do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        role_read_stub
        stub_request(:put, role_url).to_timeout
        expect(stream_config.create).to be_nil
      end

      it 'does not start the stream' do
        index_set_stub
        stub_request(:post, stream_url).to_timeout
        stream_config.create
        expect(stream_start_stub).to_not have_been_requested
      end

      it 'does not update role permissions' do
        index_set_stub
        stub_request(:post, stream_url).to_timeout
        stream_config.create
        expect(role_update_stub).to_not have_been_requested
      end

      it 'does not update role permissions if creation succeeds but role update fails' do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        stub_request(:get, role_url).to_timeout
        update = stub_request(:put, role_url)

        stream_config.create

        expect(update).to_not have_been_requested
      end
    end

    def stream_creation_stub
      stub_request(:post, stream_url).to_return(
        status: 201, body: { stream_id: '123' }.to_json, headers: { 'Content-Type': 'application/json' }
      )
    end

    def stream_start_stub
      stub_request(:post, "#{stream_url}/123#{GraylogAPI::Stream::START_PATH}").to_return(status: 204, body: '')
    end

    def role_read_stub
      dev_role = {
        name: 'Dev',
        description: 'Altmetric developers',
        permissions: ['streams:read:321'],
        read_only: false
      }
      stub_request(:get, role_url).to_return(
        status: 200, body: dev_role.to_json, headers: { 'Content-Type': 'application/json' }
      )
    end

    def role_update_stub
      dev_role = JSON.parse(role_read_stub.response.body, symbolize_names: true)
      dev_role[:permissions] = ['streams:read:321', 'streams:read:123']
      stub_request(:put, role_url).to_return(
        status: 200, body: dev_role.to_json, headers: { 'Content-Type': 'application/json' }
      )
    end
  end

  describe '#update' do
    context 'when success' do
      before do
        index_set_stub
        stream_update_stub
      end

      it 'returns the stream' do
        expect(stream_config.update('123').index_set_id).to eq('1')
      end

      it 'updates the stream' do
        stream_config.update('123')
        expect(stream_update_stub).to have_been_requested.once
      end

      def stream_update_stub
        stub_request(:put, "#{stream_url}/123").to_return(
          status: 201, body: { id: '123' }.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end
    end

    context 'when failure' do
      it 'returns no stream' do
        index_set_stub
        stub_request(:put, "#{stream_url}/123").to_timeout
        expect(stream_config.update('123')).to be_nil
      end

      it 'returns no stream if index set request fails' do
        stub_request(:get, index_set_url).to_timeout
        stub_request(:put, "#{stream_url}/123").to_timeout
        expect(stream_config.update('123')).to be_nil
      end
    end
  end

  describe '#delete' do
    context 'when success' do
      it 'returns the stream' do
        index_set_stub
        stream_deletion_stub
        expect(stream_config.delete('123').id).to eq('123')
      end

      def stream_deletion_stub
        stub_request(:delete, "#{stream_url}/123").to_return(
          status: 204, body: '', headers: { 'Content-Type': 'application/json' }
        )
      end
    end

    context 'when failure' do
      it 'returns no stream' do
        index_set_stub
        stub_request(:delete, "#{stream_url}/123").to_timeout
        expect(stream_config.delete('123')).to be_nil
      end
    end
  end

  def index_set_stub
    body = { index_sets: [{ 'id' => '1', 'index_prefix' => 'graylog' }] }
    stub_request(:get, index_set_url).to_return(
      status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end
end
