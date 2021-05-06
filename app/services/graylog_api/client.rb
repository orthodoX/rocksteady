require 'http'

module GraylogAPI
  class Client
    attr_reader :uri, :user, :password
    private :uri, :user, :password

    def initialize
      @uri = ENV['GRAYLOG_API_URI']
      @user = ENV['GRAYLOG_API_USER']
      @password = ENV['GRAYLOG_API_PASSWORD']
    end

    def get(endpoint)
      rescue_errors { http.get(url(endpoint)) }
    end

    def post(endpoint, payload)
      rescue_errors { http.post(url(endpoint), json: payload) }
    end

    def put(endpoint, payload)
      rescue_errors { http.put(url(endpoint), json: payload) }
    end

    def delete(endpoint)
      rescue_errors { http.delete(url(endpoint)) }
    end

    private

    def rescue_errors
      SuccessResponse.new(yield)
    rescue HTTP::Error, StandardError => e
      FailureResponse.new(e)
    end

    def url(endpoint)
      URI("#{uri}#{endpoint}").to_s
    end

    def http
      HTTP
        .headers(accept: 'application/json', 'X-Requested-By': 'Graylog API bot')
        .basic_auth(user: user, pass: password)
    end
  end
end
