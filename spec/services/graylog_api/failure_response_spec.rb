require 'rails_helper'

RSpec.describe GraylogAPI::FailureResponse do
  subject(:failure_response) { described_class.new(StandardError.new('Oh no!')) }

  describe '#body' do
    it 'has a type' do
      expect(failure_response.body[:type]).to eq('StandardError')
    end

    it 'has a message' do
      expect(failure_response.body[:message]).to eq('Oh no!')
    end

    it 'has a stack trace' do
      expect(failure_response.body[:stack_trace]).to include('Oh no!')
    end
  end

  describe '#successful?' do
    it 'is always unsuccessful' do
      expect(failure_response).to_not be_successful
    end
  end
end
