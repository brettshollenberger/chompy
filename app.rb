require_relative "./config/application.rb"

class ChompyApp < Sinatra::Base
  get "/" do
    erb :"index.html"
  end
end

Dir[File.expand_path(File.join(__FILE__, "../lib/middlewares/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/controllers/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/**/*.rb"))].each { |f| require f }

ChaosMonkeys::NetworkFailureMonkey.configure(chaos_percentage: 0)
ChaosMonkeys::NetworkFailureMonkey.chaos_wrapper(HTTParty, :get)
