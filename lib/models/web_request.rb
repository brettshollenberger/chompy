class WebRequest
  class MaxAttemptsExceeded < StandardError; end
  class InvalidRequest < StandardError; end

  class << self
    def make(method, url, &block)
      handler = CallbackHandler.new
      handler.instance_eval(&block) if block_given?

      make_attempt(method, url, handler)
    end

    def circuit_breaker
      @circuit_breaker ||= CircuitBreaker.new(circuit_breaker_config) do |method, url|
        response = HTTParty.send(method, url)

        if response.code.to_s.match(/[4-5]\d{2}/)
          raise HTTParty::Error.new("#{response.code}: #{response.body}")
        end

        response
      end
    end

  private
    def circuit_breaker_config
      {
        timeout: 0.5, 
        recent_count: 50, 
        recent_minimum: 10
      }
    end

    def max_attempts
      3
    end

    def make_attempt(method, url, handler, attempt=1)
      if attempt > max_attempts
        raise MaxAttemptsExceeded
      else
        begin
          response = circuit_breaker.call(method, url)
          handler.successful_request(response)
          return response
        rescue SocketError
          raise InvalidRequest
        rescue HTTParty::Error => e
          handle_http_error(e, method, url, handler, attempt)
        rescue Timeout::Error => e
          handle_unsuccessful(e, method, url, handler, attempt)
        end
      end
    end

    def handle_http_error(e, method, url, handler, attempt)
      case e.message
      when /4\d{2}/
        raise e
      else
        handle_unsuccessful(e, method, url, handler, attempt)
      end
    end

    def handle_unsuccessful(e, method, url, handler, attempt)
      handler.unsuccessful_request(e)
      make_attempt(method, url, handler, attempt+1)
    end
  end
end
