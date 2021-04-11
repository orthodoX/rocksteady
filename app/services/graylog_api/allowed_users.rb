module GraylogAPI
  class AllowedUsers
    ENDPOINT = '/users'.freeze
    USERNAMES_WITH_PERMANENT_ACCESS_TO_STREAMS = [ENV['GRAYLOG_API_USER'], 'admin'].freeze

    attr_reader :client
    private :client

    def initialize(client = Client.new)
      @client = client
    end

    def all_ids
      response = client.get(ENDPOINT)
      return [] unless response.successful?

      allowed_user_ids(response.body[:users])
    end

    private

    def allowed_user_ids(users)
      users.each_with_object([]) do |user, ids|
        ids << user[:id] if allowed_user?(user) && !can_access_streams?(user)
      end
    end

    def allowed_user?(user)
      user[:email].split('@').last == ENV['GRAYLOG_ALLOWED_EMAIL_DOMAIN']
    end

    def can_access_streams?(user)
      USERNAMES_WITH_PERMANENT_ACCESS_TO_STREAMS.include?(user[:username])
    end
  end
end
