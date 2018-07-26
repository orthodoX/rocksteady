class HclParser
  attr_reader :hcl
  private :hcl

  def initialize(hcl)
    @hcl = hcl
  end

  def parsed
    HTTP.post(url, json: { JobHCL: hcl }).parse.deep_symbolize_keys
  end

  private

  def url
    ENV.fetch('NOMAD_API_URI') + '/v1/jobs/parse'
  end
end
