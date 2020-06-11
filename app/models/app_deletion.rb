class AppDeletion
  attr_reader :app, :result
  private :app, :result

  def initialize(app)
    @app = app
    @result = {}
  end

  def delete!
    delete_graylog_stream if ENV['GRAYLOG_ENABLED'].present?

    result[:deleted] = HTTP.delete(url).status.success?
    result
  end

  private

  def url
    ENV.fetch('NOMAD_API_URI') + '/v1/job/' + app.name
  end

  def delete_graylog_stream
    stream = app.graylog_stream if app
    return unless stream

    response = GraylogAPI::StreamConfig.new(app).delete(stream.id)

    result[:warning] = 'Could not delete Graylog stream for App' unless response.successful?
  end
end
