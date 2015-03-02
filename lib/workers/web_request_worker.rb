require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'htmlbeautifier'

class ChompyApp
  class WebRequestWorker
    include Sidekiq::Worker

    def perform(sock_fd, params)
      url = WebRequest::UrlStandardizer.standardize(params["url"])

      begin
        WebRequest.make(:get, url) do
          on_unsuccessful_request do |error|
            $redis.publish sock_fd, { params: params, error: error.message }.to_json
          end

          on_successful_request do |response|
            response = HtmlBeautifier.beautify(response)

            $redis.publish sock_fd, { params: params, response: response }.to_json
          end
        end
      rescue WebRequest::MaxAttemptsExceeded, 
             WebRequest::InvalidRequest, 
             URI::InvalidURIError,
             CircuitBreaker::Open, 
             Zlib::BufError, 
             Encoding::UndefinedConversionError => e
        $redis.publish sock_fd, { params: params, error: error_text(e) }.to_json
      end
    end

    def error_text(error)
      {
        "WebRequest::MaxAttemptsExceeded" => "Max attempts exceeded",
        "WebRequest::InvalidRequest" => "Invalid request",
        "URI::InvalidURIError" => "Invalid request",
        "CircuitBreaker::Open" => "Circuit breaker open",
        "Zlib::BufError" => "Buffer error",
        "Encoding::UndefinedConversionError" => "Uninterpretable response"
      }[error.class.name]
    end
  end
end
