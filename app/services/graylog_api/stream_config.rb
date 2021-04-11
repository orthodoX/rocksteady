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
      return unless share(stream).successful?

      stream
    end

    def update(stream_id)
      stream = build_stream(stream_id: stream_id)
      stream if stream.update.successful?
    end

    def delete(stream_id)
      stream = build_stream(stream_id: stream_id)
      stream if stream.delete.successful?
    end

    private

    def build_stream(options = {})
      index_set_id = IndexSet.new(app.repository_name, client).id
      options = { title: app.name, index_set_id: index_set_id }.merge(options)

      Stream.new(options, client)
    end

    def share(stream)
      user_ids = AllowedUsers.new(client).all_ids
      return FailureResponse.new(Error::NoAllowedUsers.new) if user_ids.empty?

      Shares.new(client).create(stream.id, user_ids)
    end
  end
end
