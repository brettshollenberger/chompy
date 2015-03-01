require_relative "../config/application.rb"

class ChompyApp < Sinatra::Base
  get "/" do
    erb :"index.html"
  end
end

Dir[File.expand_path(File.join(__FILE__, "../**/*.rb"))].each  { |f| require f }
