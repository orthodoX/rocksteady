class AppDeletion
  attr_reader :app, :stream_config, :result
  private :app, :stream_config, :result

  def initialize(app, stream_config = nil)
    @app = app
    @stream_config = stream_config
    @result = {}
  end

  def delete
    delete_graylog_stream if app.graylog_stream.present?
    delete_app
    result
  end

  private

  def delete_graylog_stream
    id = app.graylog_stream.id
    result[:warning] = true unless stream_config.delete(id)
  end

  def delete_app
    result[:deleted] = delete_from_database_and_nomad
  end

  def delete_from_database_and_nomad
    app.transaction do
      app.destroy!
      fail ActiveRecord::Rollback unless successful_nomad_deletion?

      true
    end
  rescue ActiveRecord::RecordNotDestroyed
    nil
  end

  def successful_nomad_deletion?
    url = ENV.fetch('NOMAD_API_URI') + '/v1/job/' + app.name
    HTTP.delete(url).status.success?
  end
end
