
module ChatworkNotifications
  class ChatworkError < RuntimeError
  end

  class ChatworkApiError < ChatworkError
  end

  class ChatworkApiResponseError < ChatworkError
    def initialize message, code, body
      super(message)
      @code, @body = code, body
    end
    attr_reader :code, :body
  end
end

