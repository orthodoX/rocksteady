require 'rails_helper'

JOB_RESPONSE = [
  {
    ID: 'test-job',
    Status: 'running',
    JobSummary: {
      Summary: {
        servers: {
          Running: 2
        }
      }
    }
  }
].freeze

RSpec.describe AppStatus do
  let(:app) { App.create(name: 'test-job') }

  context 'when job exists in Nomad' do
    before do
      stub_request(:any, 'localhost:4646/v1/jobs').to_return { { body: JOB_RESPONSE } }
    end

    it 'returns job status' do
      expect(described_class.new(app).as_json).to include(
        status: 'running'
      )
    end

    it 'returns first task group allocation status' do
      expect(described_class.new(app).as_json[:allocations]).to include(
        'running' => 2
      )
    end
  end

  context 'when job does not exist in Nomad' do
    before do
      stub_request(:any, 'localhost:4646/v1/jobs').to_return { { body: [] } }
    end

    it 'returns not-deployed job status' do
      expect(described_class.new(app).as_json).to include(
        status: 'not-deployed'
      )
    end
  end
end
