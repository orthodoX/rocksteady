require 'rails_helper'

RSpec.describe GraylogAPI::IndexSet do
  subject(:index_set_instance) { described_class.new(index_set, GraylogAPI::Client.new) }
  let(:headers) { {'Content-Type' => 'application/json'} }

  describe '#read' do
    context 'when the index_set is available as index_prefix' do
      let(:index_set) { 'requested_index_set' }

      it 'returns the id' do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 200, body: response_body('index_prefix').to_json, headers: headers)

        expect(index_set_instance.read).to eq 'requested_id'
      end
    end

    context 'when the index_set is available as title' do
      let(:index_set) { 'requested_index_set' }

      it 'returns the id' do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 200, body: response_body('title').to_json, headers: headers)

        expect(index_set_instance.read).to eq 'requested_id'
      end
    end

    context 'when the index_set is not available' do
      let(:index_set) { 'not_available' }

      it 'returns the default' do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 200, body: response_body('invalid').to_json, headers: headers)

        expect(index_set_instance.read).to eq 'default_set_id'
      end
    end

    context 'when the response is not successful' do
      let(:index_set) { 'not_available' }

      it 'return nil' do
        stub_request(:get, 'https://test.com/api/system/indices/index_sets')
          .to_return(status: 400, body: '', headers: headers)

        expect(index_set_instance.read).to be_nil
      end
    end
  end

  def response_body(field)
    {
      index_sets: [
        {
          field.to_sym => 'requested_index_set',
          id: 'requested_id'
        },
        {
          index_prefix: 'graylog',
          id: 'default_set_id'
        }
      ]
    }
  end
end
