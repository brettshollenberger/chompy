root = "#{Dir.getwd}"
 
environment "production"
bind "unix://#{root}/tmp/puma/socket"
pidfile "#{root}/tmp/puma/pid"
state_path "#{root}/tmp/puma/state"
rackup "#{root}/config.ru"
 
threads 4, 8
 
activate_control_app
