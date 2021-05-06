require 'rails_helper'

RSpec.describe GraylogAPI::Client do
  subject(:client) { described_class.new }

  let(:url) { "#{ENV['GRAYLOG_API_URI']}/endpoint" }

  it 'is authenticated' do
    authenticated_stub = stub_request(:any, url).with(
      basic_auth: [ENV['GRAYLOG_API_USER'], ENV['GRAYLOG_API_PASSWORD']]
    )
    client.get('/endpoint')
    expect(authenticated_stub).to have_been_requested.once
  end

  it 'sends the right headers' do
    headers_stub = stub_request(:any, url).with(
      headers: { Accept: 'application/json', 'X-Requested-By': 'Graylog API bot' }
    )
    client.post('/endpoint', 'irrelevant')
    expect(headers_stub).to have_been_requested.once
  end

  context 'when success' do
    describe '#get' do
      before do
        stub_request(:get, url).to_return(
          status: 200, body: { key: 'value' }.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end

      it 'is successful' do
        expect(client.get('/endpoint')).to be_successful
      end

      it 'can parse the response' do
        expect(client.get('/endpoint').body).to eq(key: 'value')
      end
    end

    describe '#post' do
      def stub_post_with(status:, body:)
        stub_request(:post, url).to_return(
          status: status, body: body.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end

      it 'is successful with payload' do
        stub_post_with(status: 201, body: { key: 'value' })
        expect(client.post('/endpoint', pay: 'load')).to be_successful
      end

      it 'is successful with no payload' do
        stub_post_with(status: 204, body: '')
        expect(client.post('/endpoint', nil)).to be_successful
      end

      it 'can parse the response with payload' do
        stub_post_with(status: 201, body: { key: 'value' })
        response = client.post('/endpoint', pay: 'load')
        expect(response.body).to eq(key: 'value')
      end

      it 'can parse the response with no payload' do
        stub_post_with(status: 201, body: '')
        response = client.post('/endpoint', nil)
        expect(response.body).to be_empty
      end
    end

    describe '#put' do
      before do
        stub_request(:put, url).to_return(
          status: 200, body: { key: 'value' }.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end

      it 'is successful' do
        expect(client.put('/endpoint', pay: 'load')).to be_successful
      end

      it 'can parse the response' do
        response = client.put('/endpoint', pay: 'load')
        expect(response.body).to eq(key: 'value')
      end
    end

    describe '#delete' do
      before do
        stub_request(:delete, url).to_return(
          status: 204, body: '', headers: { 'Content-Type': 'application/json' }
        )
      end

      it 'is successful' do
        expect(client.delete('/endpoint')).to be_successful
      end
    end
  end

  context 'when failure' do
    before { stub_request(:any, url).to_timeout }

    it 'is unsuccessful' do
      expect(client.get('/endpoint')).to_not be_successful
    end

    it 'returns the type of error' do
      expect(client.delete('/endpoint').body[:type]).to eq('HTTP::TimeoutError')
    end

    it 'returns the error message' do
      expect(client.post('/endpoint', pay: 'load').body[:message]).to include('timed out')
    end

    it 'returns the full error message' do
      expect(client.put('/endpoint', pay: 'load').body[:stack_trace]).to include('1: from')
    end

    it 'returns the type of error for 3xx, 4xx and 5xx codes' do
      stub_request(:get, url).to_return(
        status: 404, body: { type: 'ApiError', message: 'HTTP 404 Not Found' }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
      expect(client.get('/endpoint').body[:type]).to eq('ApiError')
    end
  end
end
