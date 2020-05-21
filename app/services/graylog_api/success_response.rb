module GraylogAPI
  class SuccessResponse
    attr_reader :response
    private :response

    def initialize(response)
      @response = response
    end

    def body
      body = response.parse
      return {} if body.empty?

      body.transform_keys(&:to_sym)
    end

    def successful?
      response.status.success?
    end
  end
end
