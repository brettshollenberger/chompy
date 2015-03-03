require_relative "../config/application.rb"

set :environment, :production
set :root, File.dirname(__FILE__)
set :public_folder, '/var/www/chompy/lib/public'
set :views, Proc.new { File.join(root, "views") }

class ChompyApp < Sinatra::Base
  get "/" do
    erb :"index.html"
  end
end

Dir[File.expand_path(File.join(__FILE__, "../../lib/middlewares/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../../lib/controllers/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../../lib/**/*.rb"))].each  { |f| require f }

ChaosMonkeys::NetworkFailureMonkey.configure(chaos_percentage: 0)
ChaosMonkeys::NetworkFailureMonkey.chaos_wrapper(HTTParty, :get)
