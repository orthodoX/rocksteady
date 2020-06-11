require 'rails_helper'

RSpec.describe GraylogAPI::SuccessResponse do
  subject(:successful_response) { described_class.new(response_stub) }

  describe '#body' do
    context 'when the body is not empty' do
      let(:response_stub) { OpenStruct.new(parse: {'data' => 'data'}) }

      it 'returns the data with symbolized keys' do
        expect(successful_response.body).to eq({data: 'data'})
      end
    end

    context 'when the body is empty' do
      let(:response_stub) { OpenStruct.new(parse: '') }

      it 'returns an empty hash' do
        expect(successful_response.body).to eq(Hash.new)
      end
    end
  end

  describe '#successful?' do
    context 'when the response status is success' do
      let(:response_stub) { OpenStruct.new(status: OpenStruct.new(success?: true)) }

      it 'returns true ' do
        expect(successful_response.successful?).to be_truthy
      end
    end
  end
end
