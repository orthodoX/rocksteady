module GraylogAPI
  class StreamConfig
    ROLE = 'Dev'.freeze

    attr_reader :app, :client
    private :app, :client

    def initialize(app, client = Client.new)
      @app = app
      @client = client
    end

    def create
      stream = build_stream
      return unless stream.create.successful?

      stream.start
      return unless role.update(stream.id).successful?

      stream
    end

    def update(stream_id)
      stream = build_stream(stream_id: stream_id)
      return {} unless stream.update.successful?

      { index_set_id: stream.index_set_id }
    end

    def delete(stream_id)
      stream = build_stream(stream_id: stream_id)
      stream.delete
    end

    private

    def build_stream(options = {})
      index_set_id = IndexSet.new(app.repository_name, client).id
      options = { title: app.name, index_set_id: index_set_id }.merge(options)

      Stream.new(options, client)
    end

    def role
      @role ||= Role.new(ROLE, client)
    end
  end
end
