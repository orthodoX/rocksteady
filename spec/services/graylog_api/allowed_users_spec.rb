require 'rails_helper'

RSpec.describe GraylogAPI::AllowedUsers do
  let(:allowed_users) { described_class.new }
  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}" }

  describe '#all_ids' do
    context 'when success' do
      it 'returns only allowed user ids' do
        users = {
          users: [
            { id: '1', username: 'user1', email: 'user1@allowed.com' },
            { id: '2', username: 'user2', email: 'user2@allowed.com' },
            { id: '3', username: 'user3', email: 'user3@not-allowed.com' }
          ]
        }
        stub_success(users)
        expect(allowed_users.all_ids).to eq(%w[1 2])
      end

      it 'ignores users that have permanent access to streams to avoid E11000 error' do
        stub_success(users: [{ id: '1', username: ENV['GRAYLOG_API_USER'], email: 'foo@allowed.com' }])
        expect(allowed_users.all_ids).to be_empty
      end

      it 'ignores empty emails' do
        stub_success(users: [{ id: 'local:admin', username: 'admin', email: '' }])
        expect(allowed_users.all_ids).to be_empty
      end

      it 'only works for actual allowed emails' do
        stub_success(users: [{ id: '1', username: 'user', email: 'foo@allowed.com@bar' }])
        expect(allowed_users.all_ids).to be_empty
      end

      def stub_success(users)
        stub_request(:get, url).to_return(
          status: 200, body: users.to_json, headers: { 'Content-Type': 'application/json' }
        )
      end
    end

    context 'when failure' do
      it 'returns no ids' do
        stub_failure
        expect(allowed_users.all_ids).to be_empty
      end

      def stub_failure
        stub_request(:get, url).to_return(
          status: 404, body: { type: 'ApiError', message: 'HTTP 404 Not Found'}.to_json
        )
      end
    end
  end
end
