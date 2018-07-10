class AppDeployment
  attr_reader :app, :tag
  private :app, :tag

  def initialize(app, tag)
    @app = app
    @tag = tag
  end

  def deploy!
    nomad_client.job.create({Job: job_spec}.to_json)
  end

  private

  def job_spec
    @job_spec ||= JobSpec.new(app, image_uri)
  end

  def image_uri
    ENV.fetch('ECR_BASE') + '/' + app.repository_name + ':' + tag
  end

  def nomad_client
    @nomad_client ||= Nomad::Client.new(address: ENV.fetch('NOMAD_API_URI'))
  end
end
