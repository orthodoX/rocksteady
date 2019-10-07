require 'rails_helper'

RSpec.describe AppImageList do
  describe '#as_json' do
    it 'orders images with latest pushed first' do
      stub_request(:post, 'https://api.ecr.eu-west-1.amazonaws.com/').to_return(body: <<~JSON)
        {
           "imageDetails": [
              {
                 "imageDigest": "decafbad",
                 "imagePushedAt": 1,
                 "imageSizeInBytes": 12,
                 "imageTags": [ "oldest" ],
                 "registryId": "test-job",
                 "repositoryName": "test-job"
              },
              {
                 "imageDigest": "decafbad",
                 "imagePushedAt": 3,
                 "imageSizeInBytes": 12,
                 "imageTags": [ "latest" ],
                 "registryId": "test-job",
                 "repositoryName": "test-job"
              },
              {
                 "imageDigest": "decafbad",
                 "imagePushedAt": 2,
                 "imageSizeInBytes": 12,
                 "imageTags": [ "old" ],
                 "registryId": "test-job",
                 "repositoryName": "test-job"
              }
           ],
           "nextToken": null
        }
      JSON
      app = App.new(repository_name: 'test-job')
      json = described_class.new(app).as_json

      expect(json.first).to include(tags: ['latest'])
    end
  end
end
