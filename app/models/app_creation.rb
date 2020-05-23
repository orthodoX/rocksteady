class AppCreation
  attr_reader :app, :add_stream
  private :app, :add_stream

  def initialize(app = nil, options)
    @app = app || App.new(options[:app_params])
    @add_stream = options[:add_stream]
  end

  def create
    return app unless app.valid?

    add_graylog_stream if add_stream?
    app
  end

  def add_graylog_stream
    app.assign_attributes(validate_stream: true)
    stream_info = GraylogAPI::StreamConfig.new(app).setup
    build_associated_stream(stream_info) if stream_info.present?
    app
  end

  private

  def add_stream?
    ENV['GRAYLOG_ENABLED'].present? && add_stream
  end

  def build_associated_stream(stream_info)
    app.build_graylog_stream
    app.graylog_stream.assign_attributes(
      id: stream_info[:stream_id],
      name: app.name,
      rule_value: app.name,
      index_set_id: stream_info[:index_set_id]
    )
  end
end
