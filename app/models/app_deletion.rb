class AppDeletion
  attr_reader :app
  private :app

  def initialize(app)
    @app = app
  end

  def delete!
    HTTP.delete(url).status.success?
  end

  private

  def url
    ENV.fetch('NOMAD_API_URI') + '/v1/job/' + app.name
  end
end
