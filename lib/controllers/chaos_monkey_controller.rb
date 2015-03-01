class ChaosMonkeyController
  def self.update(params, sock)
    @redis ||= Redis.new
    @redis.publish("chaos", params.chaos.to_i)

    "ok"
  end
end
