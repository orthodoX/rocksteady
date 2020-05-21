module GraylogAPI
  class Stream
    ENDPOINT = '/streams'.freeze
    START_PATH = '/resume'.freeze
    MATCH_EXACTLY = 1

    attr_reader :id, :stream, :client
    private :stream, :client

    def initialize(client, options)
      title = options[:title]
      @id = options[:stream_id]
      @stream = {
        title: title,
        description: "Logs for #{title}",
        rules: [{ type: MATCH_EXACTLY, value: title, field: 'tag', inverted: false }],
        content_pack: nil,
        matching_type: 'AND',
        remove_matches_from_default_stream: true,
        index_set_id: options[:index_set_id]
      }
      @client = client
    end

    def create
      response = client.post(ENDPOINT, stream)
      @id = response.body[:stream_id] if response.successful?
      response
    end

    def update
      client.put(ENDPOINT, stream, id: id)
    end

    def delete!
      client.delete(ENDPOINT, id)
    end

    def start
      client.post("#{ENDPOINT}/#{id}#{START_PATH}", nil)
    end
  end
end
