class AppUpdate
  attr_reader :app, :stream_config, :result
  private :app, :stream_config, :result

  def initialize(app, stream_config = nil)
    @app = app
    @stream_config = stream_config
    @result = {}
  end

  def update(app_params)
    app.assign_attributes(app_params)
    create_or_update_graylog_stream
    update_app

    result
  end

  private

  def create_or_update_graylog_stream
    return create_graylog_stream if create_stream?

    update_graylog_stream if update_stream?
  end

  def create_stream?
    stream_config && app.graylog_stream.blank?
  end

  def update_stream?
    app.graylog_stream.present? && app.repository_name_changed?
  end

  def create_graylog_stream
    AppCreation.new(app, stream_config).create_graylog_stream
  end

  def update_graylog_stream
    stream = stream_config.update(app.graylog_stream.id)
    return result[:warning] = true if stream.blank?

    app.graylog_stream.assign_attributes(index_set_id: stream.index_set_id)
    app.graylog_stream.save!
  end

  def update_app
    result[:updated] = app.save
  end
end
