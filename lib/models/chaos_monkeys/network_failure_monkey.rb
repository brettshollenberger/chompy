module ChaosMonkeys
  class NetworkFailureMonkey
    class << self
      attr_accessor :chaos_percentage

      def configure(options={})
        @chaos_percentage = options.fetch(:chaos_percentage, 0)
        self
      end

      def chaos_wrapper(object, method_name)
        object.eigenclass.instance_eval do
          define_method "#{method_name}_with_chaos" do
            ChaosMonkeys::NetworkFailureMonkey.chaos &method("#{method_name}_without_chaos")
          end

          alias_method_chain method_name, :chaos
        end
      end

      def chaos(&block)
        if chaos?
          loop do
          end
        else
          block.call
        end
      end

      def chaos?
        return false if @chaos_percentage == 0 

        (1..100-@chaos_percentage).to_a.map { false }
          .concat((1..@chaos_percentage).to_a.map { true })
          .sample
      end
    end
  end
end
