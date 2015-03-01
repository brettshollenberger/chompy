require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'htmlbeautifier'

$redis ||= Redis.new

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
      rescue WebRequest::MaxAttemptsExceeded
        puts "Max Attempts Exceeded"
        $redis.publish sock_fd, { params: params, error: "Max attempts exceeded" }.to_json
      rescue WebRequest::InvalidRequest
        $redis.publish sock_fd, { params: params, error: "Invalid request" }.to_json
      rescue CircuitBreaker::Open
        $redis.publish sock_fd, { params: params, error: "Circuit breaker open" }.to_json
      end
    end
  end
end
