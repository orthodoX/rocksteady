module GraylogAPI
  class IndexSet
    ENDPOINT = '/system/indices/index_sets'.freeze
    DEFAULT_INDEX_PREFIX = 'graylog'.freeze

    attr_reader :client, :index_set
    private :client, :index_set

    def initialize(index_set, client = Client.new)
      @client = client
      @index_set = index_set
    end

    def id
      response = client.get(ENDPOINT)
      return unless response.successful?

      set = preferred_set(response) || default_set(response)
      set[:id] if set
    end

    private

    def preferred_set(response)
      response.body[:index_sets].find { |set| set[:index_prefix] == index_set || set[:title] == index_set }
    end

    def default_set(response)
      response.body[:index_sets].find { |set| set[:index_prefix] == DEFAULT_INDEX_PREFIX }
    end
  end
end
