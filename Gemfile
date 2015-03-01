source "https://rubygems.org"

gem "sinatra"
gem "faye-websocket"
gem "puma"
gem "rake"
gem "sidekiq"
gem "redis"
gem "httparty"

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "foreman"
end

group :test do
  gem "rspec"
  gem "guard-rspec"
  gem "terminal-notifier"
  gem "terminal-notifier-guard"
  gem "activesupport", :require => "active_support"
  gem "webmock"
end
