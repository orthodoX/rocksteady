require 'rails_helper'

RSpec.describe GraylogAPI::StreamConfig do
  subject(:stream_config) do
    app = App.create!(repository_name: 'repo-name', name: 'app-name', job_spec: 'job spec')
    described_class.new(app)
  end

  let(:index_set_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::IndexSet::ENDPOINT}" }
  let(:stream_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}" }

  describe '#create' do
    let(:shares_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Shares::ENDPOINT}123" }
    let(:users_url) { "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::AllowedUsers::ENDPOINT}" }

    context 'when success' do
      before do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        users_stub
        shares_creation_stub
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

      it 'gets all allowed users to share stream with' do
        stream_config.create
        expect(users_stub).to have_been_requested.once
      end

      it 'shares new stream with allowed users' do
        stream_config.create
        expect(shares_creation_stub).to have_been_requested.once
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

      it 'does not start the stream' do
        index_set_stub
        stub_request(:post, stream_url).to_timeout
        stream_config.create
        expect(stream_start_stub).to_not have_been_requested
      end

      it 'does not share permissions' do
        index_set_stub
        stub_request(:post, stream_url).to_timeout
        stream_config.create
        expect(shares_creation_stub).to_not have_been_requested
      end

      it 'is unsuccessful if creation succeeds but users fails' do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        stub_request(:get, users_url).to_timeout
        shares_creation_stub
        expect(stream_config.create).to be_nil
      end

      it 'is unsuccessful if creation succeeds but no allowed users' do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        users_stub(users: [{ id: 'userid1', email: 'uno@example.com' }])
        shares_creation_stub
        expect(stream_config.create).to be_nil
      end

      it 'is unsuccessful if creation succeeds but sharing fails' do
        index_set_stub
        stream_creation_stub
        stream_start_stub
        users_stub
        stub_request(:post, shares_url).to_timeout
        expect(stream_config.create).to be_nil
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

    def users_stub(users = { users: [{ id: 'userid1', email: 'uno@allowed.com' }] })
      stub_request(:get, users_url).to_return(
        status: 200, body: users.to_json, headers: { 'Content-Type': 'application/json' }
      )
    end

    def shares_creation_stub
      stub_request(:post, shares_url).to_return(
        status: 200, body: { key: 'value'}.to_json, headers: { 'Content-Type': 'application/json' }
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
