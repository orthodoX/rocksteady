class AppCreation
  attr_reader :app, :stream_config
  private :app, :stream_config

  def initialize(app, stream_config = nil)
    @app = app
    @stream_config = stream_config
  end

  def create
    create_graylog_stream if stream_config
    app.save
  end

  def create_graylog_stream
    app.assign_attributes(validate_stream: true)

    stream = stream_config.create
    build_associated_stream(stream) if stream.present?
  end

  private

  def build_associated_stream(stream)
    app.build_graylog_stream
    app.graylog_stream.assign_attributes(
      id: stream.id,
      name: app.name,
      rule_value: app.name,
      index_set_id: stream.index_set_id
    )
  end
end
