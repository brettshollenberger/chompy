require 'sidekiq'
require 'redis'
require 'sidekiq/api'

$redis ||= Redis.new

class ChompyApp
  class WebRequestWorker
    include Sidekiq::Worker

    def perform(sock_fd, url)
      WebRequest.make(:get, url) do
        on_unsuccessful_request do |error|
          $redis.publish sock_fd, error
        end

        on_successful_request do |response|
          $redis.publish sock_fd, response
        end
      end
    end
  end
end
