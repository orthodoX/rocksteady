module GraylogAPI
  class Shares
    ENDPOINT = '/authz/shares/entities/grn::::stream:'.freeze
    USER_PREFIX = 'grn::::user:'.freeze
    USER_CAPABILITY = 'view'.freeze

    attr_reader :client
    private :client

    def initialize(client = Client.new)
      @client = client
    end

    def create(stream_id, user_ids)
      payload = {
        selected_grantee_capabilities: selected_grantee_capabilities(user_ids)
      }
      client.post("#{ENDPOINT}#{stream_id}", payload)
    end

    private

    def selected_grantee_capabilities(user_ids)
      user_ids.each_with_object({}) do |user_id, capabilities|
        capabilities[:"#{USER_PREFIX}#{user_id}"] = USER_CAPABILITY
      end
    end
  end
end
