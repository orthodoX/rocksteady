require 'rails_helper'

RSpec.describe GraylogAPI::Stream do
  subject(:stream) { new_stream }

  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}" }

  def new_stream(options = {})
    described_class.new({ title: 'a title', index_set_id: '42' }.merge(options))
  end

  it 'does not have an id before creation' do
    expect(new_stream.id).to be_nil
  end

  context 'when success' do
    it 'creates a stream' do
      stub_stream_creation
      expect(stream.create).to be_successful
    end

    it 'has an id' do
      stub_stream_creation
      stream.create
      expect(stream.id).to eq('1')
    end

    it 'has an index set id' do
      stub_stream_creation
      stream.create
      expect(stream.index_set_id).to eq('42')
    end

    it 'starts an existing stream' do
      stub_stream_creation
      stream.create

      stub_stream_start
      expect(stream.start).to be_successful
    end

    it 'can create several streams with the same title' do
      stub_request(:post, url).to_return(
        { status: 201, body: { stream_id: '1' }.to_json, headers: { 'Content-Type': 'application/json' } },
        { status: 201, body: { stream_id: '2' }.to_json, headers: { 'Content-Type': 'application/json' } }
      )
      stream.create
      stream.create

      expect(stream.id).to eq('2')
    end

    it 'updates an existing stream' do
      stub_stream_update
      stream = new_stream(stream_id: '1', index_set_id: '2')
      stream.update
      expect(stub_stream_update).to have_been_requested
    end

    it 'is successful on update' do
      stub_stream_update
      stream = new_stream(stream_id: '1', index_set_id: '2')
      expect(stream.update).to be_successful
    end

    it 'deletes an existing stream' do
      stub_stream_deletion
      stream = new_stream(stream_id: '1')
      expect(stream.delete).to be_successful
    end

    def stub_stream_start
      stub_request(:post, "#{url}/1#{described_class::START_PATH}").to_return(status: 204, body: '')
    end
  end

  context 'when failure' do
    it 'does not create stream' do
      stub_request(:post, url).to_timeout
      expect(stream.create).to_not be_successful
    end

    it 'does not create stream if index set id is null' do
      stub_request(:post, url).to_return(
        status: 400, body: { type: 'ApiError', message: 'problem: Null indexSetId' }.to_json
      )
      stream = new_stream(index_set_id: nil)
      expect(stream.create).to_not be_successful
    end

    it 'does not create stream if stream id is provided' do
      stub_request(:post, url).to_return(
        status: 400, body: { type: 'ApiError', message: 'Unable to map property id' }.to_json
      )
      stream = new_stream(stream_id: '1')
      expect(stream.create).to_not be_successful
    end

    it 'does not have an id' do
      stub_request(:post, url).to_timeout
      stream.create
      expect(stream.id).to be_nil
    end

    it 'does not start a stream that was not created' do
      stub_request(:post, url).to_timeout
      stream.create

      stub_stream_start_when_no_id
      expect(stream.start).to_not be_successful
    end

    it 'does not start the created stream if can not resume' do
      stub_stream_creation
      stream.create

      stub_request(:post, "#{url}/1#{described_class::START_PATH}").to_timeout
      expect(stream.start).to_not be_successful
    end

    it 'does not update an inexisting stream' do
      stub_request(:put, "#{url}/1").to_return(
        status: 404, body: { type: 'ApiError', message: 'Stream <1> not found!' }.to_json
      )
      stream = new_stream(stream_id: '1', index_set_id: '2')
      expect(stream.update).to_not be_successful
    end

    it 'does not delete an inexisting stream' do
      stub_request(:delete, "#{url}/1").to_return(
        status: 404, body: { type: 'ApiError', message: 'Stream <1> not found!' }.to_json
      )
      stream = new_stream(stream_id: '1')
      expect(stream.delete).to_not be_successful
    end

    def stub_stream_start_when_no_id
      stub_request(:post, "#{url}/#{described_class::START_PATH}").to_return(
        status: 404, body: { type: 'ApiError', message: 'HTTP 404 Not Found'}.to_json
      )
    end
  end

  def stub_stream_creation
    stub_request(:post, url).to_return(
      status: 201, body: { stream_id: '1' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_stream_update
    stub_request(:put, "#{url}/1").to_return(
      status: 200, body: { id: '1', index_set_id: '2' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_stream_deletion
    stub_request(:delete, "#{url}/1").to_return(
      status: 204, body: '', headers: { 'Content-Type': 'application/json' }
    )
  end
end
