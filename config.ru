require "pry"

Dir[File.expand_path(File.join(__FILE__, "../lib/**/*.rb"))].each { |f| require f }

use ChompyApp::SocketMiddleware do
  def on_message(ws, event)
    puts "Message received #{event.data}"
  end
end

run ChompyApp
