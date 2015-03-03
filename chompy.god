CHOMPY_APP_ROOT = ENV["CHOMPY_APP_ROOT"]

def generic_god_config(god, options={})
  god.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running  = false
    end
  end

  god.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above    = options[:memory_max]
      c.interval = 20
      c.times    = [3, 5]
    end

    restart.condition(:cpu_usage) do |c|
      c.above    = options[:cpu_max]
      c.interval = 20
      c.times    = 5
    end
  end
end

God.watch do |god|
  god.group = "chompy"
  god.name  = "puma"
  god.dir   = CHOMPY_APP_ROOT
  god.start = "bundle exec puma --config config/puma.rb"
  god.log   = "./log/puma.log"
  god.keepalive

  god.behavior(:clean_pid_file)

  generic_god_config(god, :memory_max => 100.megabytes, :cpu_max => 75.percent)
end

God.watch do |god|
  god.group = "chompy"
  god.name  = "sidekiq"
  god.dir   = CHOMPY_APP_ROOT
  god.start = "bundle exec sidekiq -r ./lib/app"
  god.log   = "./log/sidekiq.log"
  god.keepalive

  god.behavior(:clean_pid_file)

  generic_god_config(god, :memory_max => 100.megabytes, :cpu_max => 80.percent)
end
