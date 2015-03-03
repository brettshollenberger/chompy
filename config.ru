Dir[File.expand_path(File.join(__FILE__, "../config/application.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/app.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/middlewares/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/controllers/**/*.rb"))].each { |f| require f }
Dir[File.expand_path(File.join(__FILE__, "../lib/**/*.rb"))].each { |f| require f }

use SocketMiddleware do
  def on_message(ws, event)
    puts "Message received #{event.data}"
  end
end

run ChompyApp
