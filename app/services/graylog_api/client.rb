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
      rescue_errors { http.get(URI("#{uri}#{endpoint}").to_s) }
    end

    def post(endpoint, payload)
      rescue_errors { http.post(URI("#{uri}#{endpoint}").to_s, json: payload) }
    end

    def put(endpoint, payload, id: nil)
      rescue_errors { http.put(build_uri(endpoint, id).to_s, json: payload) }
    end

    def delete(endpoint, id)
      rescue_errors { http.delete(URI("#{uri}#{endpoint}/#{id}").to_s) }
    end

    private

    def rescue_errors
      SuccessResponse.new(yield)
    rescue HTTP::Error, StandardError => e
      FailureResponse.new(e)
    end

    def http
      HTTP.headers(accept: 'application/json', 'X-Requested-By': 'Graylog API bot').basic_auth(
        user: user, pass: password
      )
    end

    def build_uri(endpoint, id)
      id ? URI("#{uri}#{endpoint}/#{id}") : URI("#{uri}#{endpoint}")
    end
  end
end
