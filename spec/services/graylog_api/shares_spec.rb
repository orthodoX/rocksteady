require 'rails_helper'

RSpec.describe GraylogAPI::Shares do
  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}streamid" }

  describe '#create' do
    context 'when success' do
      it 'sets all capabilities to view' do
        client = instance_spy('GraylogAPI::Client')
        expected_payload = {
          selected_grantee_capabilities: {
            'grn::::user:userid1': 'view',
            'grn::::user:userid2': 'view'
          }
        }
        described_class.new(client).create('streamid', ['userid1', 'userid2'])

        expect(client).to have_received(:post).with(
          "#{described_class::ENDPOINT}streamid", expected_payload
        )
      end

      it 'shares stream with users' do
        shares_response_body = {
          entity: 'grn::::stream:streamid',
          active_shares: [
            { grant: 'grn::::grant:streamid', grantee: 'grn::::user:userid1', capability: 'view' },
            { grant: 'grn::::grant:streamid', grantee: 'grn::::user:userid2', capability: 'view' }
          ],
          selected_grantee_capabilities: {
            'grn::::user:userid1': 'view', 'grn::::user:userid2': 'view'
          }
        }
        stub_shares_creation(shares_response_body)
        expect(described_class.new.create('streamid', ['userid1', 'userid2'])).to be_successful
      end

      it 'has no capabilities if sent empty ids' do
        client = instance_spy('GraylogAPI::Client')
        expected_payload = { selected_grantee_capabilities: {} }

        described_class.new(client).create('streamid', [])

        expect(client).to have_received(:post).with(
          "#{described_class::ENDPOINT}streamid", expected_payload
        )
      end

      it 'removes all shares from stream if sent empty ids' do
        removal_response_body = {
          entity: 'grn::::stream:streamid',
          active_shares: [],
          selected_grantee_capabilities: {}
        }
        stub_shares_creation(removal_response_body)
        expect(described_class.new.create('streamid', [])).to be_successful
      end

      def stub_shares_creation(response_body)
        stub_request(:post, url).to_return(
          status: 200, body: response_body.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end
    end

    context 'when failure' do
      it 'does not share stream with users' do
        stub_request(:post, url).to_timeout
        expect(described_class.new.create('streamid', [])).to_not be_successful
      end
    end
  end
end
