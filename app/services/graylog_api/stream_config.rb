module GraylogAPI
  class StreamConfig
    ROLE = 'Dev'.freeze

    attr_reader :app
    private :app

    def initialize(app)
      @app = app
    end

    def setup
      stream = Stream.new(options, client)

      return unless stream.create.successful?

      stream.start
      return unless role.update(stream.id).successful?

      {
        stream_id: stream.id,
        index_set_id: index_set_id
      }
    end

    def update(stream_id)
      stream = Stream.new(options.merge(stream_id: stream_id), client)

      return unless stream.update.successful?

      {
        index_set_id: index_set_id
      }
    end

    def delete(stream_id)
      stream = Stream.new(options.merge(stream_id: stream_id), client)
      stream.delete
    end

    def index_set_id
      @index_set ||= IndexSet.new(index_set, client).id
    end

    def role
      @role ||= Role.new(ROLE, client)
    end

    def client
      @client ||= Client.new
    end

    private

    def index_set
      app.repository_name
    end

    def options
      { title: app.name, index_set_id: index_set_id }
    end
  end
end
