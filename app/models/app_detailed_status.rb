class AppDetailedStatus
  attr_reader :app
  private :app

  def initialize(app)
    @app = app
  end

  def as_json(*)
    {
      summary: AppStatus.new(app),
      detail: nomad_job
    }
  end

  private

  def nomad_client
    @nomad_client ||= Nomad::Client.new(address: ENV.fetch('NOMAD_API_URI'))
  end

  def nomad_job
    @nomad_job ||= nomad_client.job.read(app.name)
  rescue Nomad::HTTPClientError
    nil
  end
end
