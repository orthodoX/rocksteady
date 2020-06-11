require 'rails_helper'

RSpec.describe GraylogAPI::Stream do
  subject(:stream) { described_class.new(GraylogAPI::Client.new, options) }

  let(:options) { { title: 'a title', index_set_id: '2cf6d1dd4abcfd87322378f2' } }
  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}" }

  it 'does not have an id before creation' do
    expect(stream.id).to be_nil
  end

  context 'when success' do
    before { stub_stream_creation }

    it 'creates a stream' do
      expect(stream.create).to be_successful
    end

    context 'when passed an optional stream_id' do
      subject(:stream) { described_class.new(GraylogAPI::Client.new, options.merge(stream_id: '2')) }

      it 'it can delete a stream' do
        stub_stream_deletion
        expect(stream.delete!).to be_successful
      end

      it 'it can update a stream' do
        stub_stream_update
        expect(stream.update).to be_successful
      end
    end

    it 'has an id' do
      stream.create
      expect(stream.id).to eq('1')
    end

    it 'starts a created stream' do
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

    def stub_stream_start
      stub_request(:post, "#{url}/1#{described_class::START_PATH}").to_return(status: 204, body: '')
    end
  end

  context 'when failure' do
    before { stub_request(:post, url).to_timeout }

    it 'does not create stream' do
      expect(stream.create).to_not be_successful
    end

    it 'does not have an id' do
      stream.create
      expect(stream.id).to be_nil
    end

    it 'does not start a stream that was not created' do
      stream.create

      stub_stream_start_when_no_id
      expect(stream.start).to_not be_successful
    end

    it 'does not start a created stream if can not resume' do
      stub_stream_creation
      stream.create

      stub_request(:post, "#{url}/1#{described_class::START_PATH}").to_timeout
      expect(stream.start).to_not be_successful
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

  def stub_stream_deletion
    stub_request(:delete, "#{url}/2").to_return(
      status: 201, body: '', headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_stream_update
    stub_request(:put, "#{url}/2").to_return(
      status: 201, body: {data: 'updated stream data'}.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end
end
