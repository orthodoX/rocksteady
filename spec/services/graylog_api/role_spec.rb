require 'rails_helper'

RSpec.describe GraylogAPI::Role do
  subject(:role) { described_class.new('Name', GraylogAPI::Client.new) }

  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}/Name" }

  context 'when success' do
    it 'reads a role' do
      read_role_stub
      expect(role.read).to be_successful
    end

    it 'updates a role' do
      read_role_stub
      update_role_stub
      expect(role.update('new_stream_id')).to be_successful
    end

    def update_role_stub
      body = JSON.parse(read_role_stub.response.body).transform_keys(&:to_sym)
      body[:permissions] = ['streams:read:existing_stream_id', 'streams:read:new_stream_id']
      stub_request(:put, url).to_return(
        status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' }
      )
    end
  end

  context 'when failure' do
    it 'does not read role' do
      stub_request(:get, url).to_timeout
      expect(role.read).to_not be_successful
    end

    it 'does not update role if read fails' do
      stub_request(:get, url).to_timeout
      stub_request(:put, url).to_return(status: 200)
      expect(role.update('new_stream_id')).to_not be_successful
    end

    it 'does not update role if read succeeds but update fails' do
      body = JSON.parse(read_role_stub.response.body).transform_keys(&:to_sym)
      body[:permissions] = ['streams:read:existing_stream_id', 'streams:read:new_stream_id']
      stub_request(:put, url).with(body: body).to_timeout
      expect(role.update('new_stream_id')).to_not be_successful
    end
  end

  def read_role_stub
    body = {
      name: 'Name',
      description: 'Description',
      permissions: ['streams:read:existing_stream_id'],
      read_only: false
    }
    stub_request(:get, url).to_return(
      status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end
end
