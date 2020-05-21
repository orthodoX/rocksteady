require 'rails_helper'

RSpec.describe GraylogAPI::FailureResponse do
  subject(:failure_response) { described_class.new(error_stub) }

  let(:error_stub) {
    OpenStruct.new(
      class: OpenStruct.new(name: 'ErrorClass'),
      message: 'Something went wrong',
      full_message: 'Something went very wrong'
    )
  }

  describe '#body' do
    it 'returns the data with symbolized keys' do
      expect(failure_response.body).to eq({
        message: 'Something went wrong',
        stack_trace: 'Something went very wrong',
        type: 'OpenStruct'
      })
    end
  end

  describe '#successful?' do
    it 'returns false' do
      expect(failure_response.successful?).to be_falsey
    end
  end
end
