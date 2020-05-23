require 'rails_helper'

RSpec.describe GraylogAPI::StreamConfig do
  subject(:stream_config) { described_class.new(app) }

  let(:app) { instance_double('App', { repository_name: 'test', name: 'app name'}) }
  let(:index_sets) {
    {
      index_sets: [
        {'id' => '123', 'index_prefix' => 'graylog'}
      ]
    }
  }
  let(:headers) { {'Content-Type' => 'application/json'} }

  describe '#setup' do
    let(:stream) { {stream_id: '999'} }
    let(:role) {
      {
        name: 'Dev',
        description: 'Altmetric developers',
        permissions: [
          'streams:read:777'
        ]
      }
    }

    context 'when all the requests are successful' do
      before do
        get_index_sets_stub
        stream_stub(verb: :post, response: stream)
        streams_resume_stub
        role_update_stub(response: role)
        role_update_stub(verb: :put)
      end

      it 'returns a hash with the stream_id and index_set_id' do
        expect(stream_config.setup[:stream_id]).to be_present
      end
    end

    context 'when the stream is not created successfully cause of a bad response' do
        before do
          get_index_sets_stub(status: 400)
          stream_stub(verb: :post, status: 400)
        end

      it 'returns nil' do
        expect(stream_config.setup).to_not be_present
      end
    end

    context 'when the stream is not created successfully cause of a network error' do
      before do
        get_index_sets_stub
        stub_request(:post, 'https://test.com/api/streams')
          .to_raise(HTTP::Error)
      end

      it 'returns nil' do
        expect(stream_config.setup).to_not be_present
      end
    end
  end

  describe '#delete' do
    let(:stream) { GraylogStream.new(id: '123') }
    let(:app) { App.create(name: 'app name', repository_name: 'test', job_spec: '{}', graylog_stream: stream) }

    before { get_index_sets_stub }

    context 'when the request is successful' do
      before { stream_stub(verb: :delete, id: '123') }

      it 'removes the stream from the index and returns a result object' do
        expect(described_class.new(app).delete(stream.id)).to be_successful
      end
    end

    context 'when the request is not successful' do
      before { stream_stub(verb: :delete, status: 400, id: '123') }

      it 'returns a response object' do
        expect(described_class.new(app).delete(stream.id)).to_not be_successful
      end
    end
  end

  describe '#update' do
    let(:stream) { GraylogStream.new(id: '123') }
    let(:app) { App.create(name: 'app name', repository_name: 'test', job_spec: '{}', graylog_stream: stream) }

    before { get_index_sets_stub }

    context 'when the request is successful' do
      before { stream_stub(verb: :put, id: '123') }

      it 'updates the stream and returns the index_set_id' do
        expect(described_class.new(app).update(stream.id)).to eq({index_set_id: '123'})
      end
    end

    context 'when the request is not successful' do
      before { stream_stub(verb: :put, status: 400, id: '123') }

      it 'returns nil' do
        expect(described_class.new(app).update(stream.id)).to_not be_present
      end
    end
  end

  def get_index_sets_stub(status: 200)
    stub_request(:get, 'https://test.com/api/system/indices/index_sets')
      .to_return(status: status, body: index_sets.to_json, headers: headers)
  end

  def stream_stub(verb:, status: 200, response: '', id: nil)
    url = id ? "https://test.com/api/streams/#{id}" : "https://test.com/api/streams"

    stub_request(verb, url)
      .to_return(status: status, body: response.to_json, headers: headers)
  end

  def streams_resume_stub
    stub_request(:post, 'https://test.com/api/streams/999/resume')
      .to_return(status: 200, body: ''.to_json, headers: headers)
  end

  def role_update_stub(verb: :get, status: 200, response: '')
    stub_request(verb, 'https://test.com/api/roles/Dev')
      .to_return(status: status, body: response.to_json, headers: headers)
  end
end
