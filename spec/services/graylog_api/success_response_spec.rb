require 'rails_helper'

RSpec.describe GraylogAPI::SuccessResponse do
  describe '#body' do
    it 'has one' do
      expect(success_response('{"foo": "bar"}').body).to eq(foo: 'bar')
    end

    it 'can be empty' do
      expect(success_response.body).to be_empty
    end

    it 'converts nested keys to symbols' do
      response = success_response('{"foo": { "bar": { "qux": 42 } }}')
      expect(response.body.dig(:foo, :bar, :qux)).to eq(42)
    end
  end

  describe '#successful?' do
    it 'is always successful' do
      expect(success_response).to be_successful
    end
  end

  def success_response(body = '{}')
    described_class.new(
      HTTP::Response.new(
        status: 200,
        version: '1.1',
        headers: { 'Content-Type' => 'application/json' },
        body: body
      )
    )
  end
end
