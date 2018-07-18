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
    @job_spec ||= JobSpec.new(app, image_name)
  end

  def image_name
    case app.image_source
    when 'ecr'
      "#{ecr_base}/#{app.repository_name}:#{tag}"
    when 'dockerhub'
      "#{app.repository_name}:#{tag}"
    end
  end

  def nomad_client
    @nomad_client ||= Nomad::Client.new(address: ENV.fetch('NOMAD_API_URI'))
  end

  def ecr_base
    ENV.fetch('ECR_BASE')
  end
end
