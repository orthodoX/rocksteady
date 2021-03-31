require 'rails_helper'

RSpec.describe GraylogAPI::IndexSet do
  let(:url) { "#{ENV['GRAYLOG_API_URI']}#{described_class::ENDPOINT}" }

  describe '#id' do
    context 'when success' do
      it 'returns id from index prefix' do
        stub_success(
          index_sets: [
            { index_prefix: 'repo-name', id: '1' },
            { title: 'repo-name', id: '2' }
          ]
        )
        expect(described_class.new('repo-name').id).to eq('1')
      end

      it 'can return id from title' do
        stub_success(index_sets: [{ index_prefix: 'different', title: 'repo-name', id: '1' }])
        expect(described_class.new('repo-name').id).to eq('1')
      end

      it 'returns default id if index set not found' do
        default_prefix = described_class::DEFAULT_INDEX_PREFIX
        stub_success(index_sets: [{ index_prefix: default_prefix, id: '1' }])
        expect(described_class.new('i-wont-be-found').id).to eq('1')
      end
    end

    context 'when failure' do
      it 'does not return id' do
        stub_request(:get, url).to_timeout
        expect(described_class.new('repo-name').id).to be_nil
      end

      it 'does not return id if none is sent' do
        stub_success(index_sets: [{ index_prefix: 'repo-name' }])
        expect(described_class.new('repo-name').id).to be_nil
      end
    end

    def stub_success(body)
      stub_request(:get, url).to_return(
        status: 200, body: body.to_json, headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
