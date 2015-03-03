require "pry"

Dir[File.expand_path(File.join(__FILE__, "../app.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/**/*.rb"))].each { |f| require f }

set :environment, :production
set :root, File.dirname(__FILE__)
set :public_folder, '/var/www/chompy/lib/public'
set :views, Proc.new { File.join(root, "lib/views") }

use SocketMiddleware do
  def on_message(ws, event)
    puts "Message received #{event.data}"
  end
end

run ChompyApp
