class WebRequest
  class MaxAttemptsExceeded < StandardError; end
  class InvalidRequest < StandardError; end

  def self.make(method, url, &block)
    handler = CallbackHandler.new
    handler.instance_eval(&block) if block_given?

    make_attempt(method, url, handler)
  end

private
  def self.max_attempts
    3
  end

  def self.make_attempt(method, url, handler, attempt=1)
    if attempt > max_attempts
      raise MaxAttemptsExceeded
    else
      begin
        circuit_breaker.call(method, url)
      rescue SocketError
        raise InvalidRequest
      rescue HTTParty::Error => e
        case e.message
        when /4\d{2}/
          raise e
        else
          handle_unsuccessful(method, url, handler, attempt)
        end
      rescue Timeout::Error
        handle_unsuccessful(method, url, handler, attempt)
      end
    end
  end

  def self.handle_unsuccessful(method, url, handler, attempt)
    handler.unsuccessful_request(url)
    make_attempt(method, url, handler, attempt+1)
  end

  def self.circuit_breaker
    @circuit_breaker ||= CircuitBreaker.new(timeout: 2, recent_count: 50, recent_minimum: 10) do |method, url|
      response = HTTParty.send(method, url)

      if response.code.to_s.match(/[4-5]\d{2}/)
        raise HTTParty::Error.new("#{response.code}: #{response.body}")
      end

      response
    end
  end
end
