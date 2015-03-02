Thread.new do
  @redis ||= Redis.new

  @redis.subscribe("chaos") do |on|
    on.message do |channel, chaos_percentage|
      ChaosMonkeys::NetworkFailureMonkey.configure(chaos_percentage: chaos_percentage.to_i)
    end
  end
end

module ChaosMonkeys
  class NetworkFailureMonkey
    class << self
      attr_accessor :chaos_percentage

      def configure(options={})
        @chaos_percentage = options.fetch(:chaos_percentage, 0)
        self
      end

      # Public: Wrap any method with the network chaos setting. 
      #
      # If chaotic, the method will hang forever
      #
      def chaos_wrapper(object, method_name)
        object.eigenclass.instance_eval do
          define_method "#{method_name}_with_chaos" do |*args|
            ChaosMonkeys::NetworkFailureMonkey.chaos *args, &method("#{method_name}_without_chaos")
          end

          alias_method_chain method_name, :chaos
        end
      end

      # Public: If chaotic, cause a block to never be executed
      #
      def chaos(*args, &block)
        if chaos?
          loop do
          end
        else
          block.call(*args)
        end
      end

      # Public: Use the chaos percentage to determine whether or not a request will succeed.
      #
      # A chaos setting of 30% has a 30% chance of failure.
      #
      def chaos?
        return false if @chaos_percentage == 0 

        (1..100-@chaos_percentage).to_a.map { false }
          .concat((1..@chaos_percentage).to_a.map { true })
          .sample
      end
    end
  end
end
