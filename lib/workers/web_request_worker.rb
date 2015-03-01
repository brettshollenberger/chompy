require 'sidekiq'
require 'redis'
require 'sidekiq/api'

$redis ||= Redis.new

class ChompyApp
  class WebRequestWorker
    include Sidekiq::Worker

    def perform(sock_fd, url)
      $redis.publish sock_fd, "This is your web worker. I got your request for #{url}"

      # uri      = URI(url)
      # response = Net::HTTP.get(uri)
      # $redis.lpush("web-requests", JSON.generate({sock_fd: sock_fd, url: url}))
    end
  end
end
