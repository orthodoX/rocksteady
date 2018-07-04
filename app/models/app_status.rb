class AppStatus
  attr_reader :app
  private :app

  def initialize(app)
    @app = app
  end

  def as_json(*)
    return null_status unless nomad_job

    {
      status: nomad_job.status,
      allocations: nomad_job.job_summary.summary.values.first.as_json
    }
  end

  private

  def nomad_client
    @nomad_client ||= Nomad::Client.new(address: ENV.fetch('NOMAD_API_URI'))
  end

  def nomad_job
    @nomad_job ||= nomad_client.job.list.find { |j| j.id == app.name }
  end

  def null_status
    {
      status: 'not-deployed'
    }
  end
end
