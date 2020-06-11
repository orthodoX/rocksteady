module GraylogAPI
  class FailureResponse
    attr_reader :error
    private :error

    def initialize(error)
      @error = error
    end

    def body
      { type: error.class.name, message: error.message, stack_trace: error.full_message }
    end

    def successful?
      false
    end
  end
end
