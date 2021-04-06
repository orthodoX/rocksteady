class AppUpdate
  attr_reader :app, :add_stream, :update_stream, :result
  private :app, :add_stream, :update_stream, :result

  def initialize(app, options)
    @app = app
    @add_stream = options[:add_stream]
    @update_stream = options[:update_stream]
    @result = {}
  end

  def update(app_params)
    app.assign_attributes(app_params)
    return app unless app.valid?

    update_graylog if updatable?
    AppCreation.new(app, stream_config).create_graylog_stream if create_or_update_stream?

    result[:updated] = app.save
    result
  end

  private

  def add_stream?
    ENV['GRAYLOG_ENABLED'].present? && add_stream
  end

  def update_stream?
    ENV['GRAYLOG_ENABLED'].present? && update_stream
  end

  def updatable?
    update_stream? && app.graylog_stream.present?
  end

  def create_or_update_stream?
    add_stream? || (update_stream? && app.graylog_stream.blank?)
  end

  def update_graylog
    return unless app.repository_name_changed?

    stream_info = stream_config.update(app.graylog_stream.id)
    return update_associated_stream(stream_info) if stream_info.present?

    result[:warning] = 'Graylog stream could not be updated.'
  end

  def update_associated_stream(stream_info)
    app.graylog_stream.assign_attributes(
      index_set_id: stream_info[:index_set_id]
    )
    app.graylog_stream.save
  end

  def stream_config
    @stream_config ||= GraylogAPI::StreamConfig.new(app)
  end
end
