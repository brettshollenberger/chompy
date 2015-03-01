class WebRequest
  class CallbackHandler
    attr_accessor :unsuccessful_request_callbacks, :successful_request_callbacks

    def initialize
      @unsuccessful_request_callbacks = []
      @successful_request_callbacks   = []
    end

    def on_unsuccessful_request(&block)
      @unsuccessful_request_callbacks.push(block)
    end

    def unsuccessful_request(request)
      @unsuccessful_request_callbacks.each do |block|
        block.call(request)
      end
    end

    def on_successful_request(&block)
      @successful_request_callbacks.push(block)
    end

    def successful_request(request)
      @successful_request_callbacks.each do |block|
        block.call(request)
      end
    end
  end
end
