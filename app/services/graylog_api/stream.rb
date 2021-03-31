module GraylogAPI
  class Stream
    ENDPOINT = '/streams'.freeze
    START_PATH = '/resume'.freeze
    MATCH_EXACTLY = 1

    attr_reader :stream, :client
    private :stream, :client

    def initialize(options, client = Client.new)
      @client = client
      @stream = build_stream(options)
      @stream[:id] = options[:stream_id] if options[:stream_id]
    end

    def create
      response = client.post(ENDPOINT, stream)
      stream[:id] = response.body[:stream_id] if response.successful?
      response
    end

    def update
      client.put("#{ENDPOINT}/#{id}", stream)
    end

    def delete
      client.delete("#{ENDPOINT}/#{id}")
    end

    def start
      client.post("#{ENDPOINT}/#{id}#{START_PATH}", nil)
    end

    def id
      stream[:id]
    end

    def index_set_id
      stream[:index_set_id]
    end

    private

    def build_stream(options)
      {
        title: options[:title],
        description: "Logs for #{options[:title]}",
        rules: [{ type: MATCH_EXACTLY, value: options[:title], field: 'tag', inverted: false }],
        content_pack: nil,
        matching_type: 'AND',
        remove_matches_from_default_stream: true,
        index_set_id: options[:index_set_id]
      }
    end
  end
end
