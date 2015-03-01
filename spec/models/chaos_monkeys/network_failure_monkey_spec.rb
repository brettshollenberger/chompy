require "spec_helper"

describe ChaosMonkeys::NetworkFailureMonkey do

  class SimpleMachine
    def self.compute
      1
    end
  end

  context "When not chaotic" do
    before(:all) do
      ChaosMonkeys::NetworkFailureMonkey.configure(chaos_percentage: 0)
    end

    it "calls blocks normally" do
      expect { 
        Timeout::timeout(0.1) do
          ChaosMonkeys::NetworkFailureMonkey.chaos do
            1
          end
        end
      }.to_not raise_error
    end

    it "calls method normally" do
      ChaosMonkeys::NetworkFailureMonkey.chaos_wrapper(SimpleMachine, :compute)

      expect { 
        Timeout::timeout(0.1) do
          SimpleMachine.compute 
        end
      }.to_not raise_error

    end
  end

  context "When chaotic" do
    before(:all) do
      ChaosMonkeys::NetworkFailureMonkey.configure(chaos_percentage: 100)
    end

    it "hangs indefinitely around a block when 100% chaos_percentage" do
      expect { 
        Timeout::timeout(0.1) do
          ChaosMonkeys::NetworkFailureMonkey.chaos do
            1
          end
        end
      }.to raise_error Timeout::Error
    end

    it "wraps around a method to non-intrusively induce chaos" do
      ChaosMonkeys::NetworkFailureMonkey.chaos_wrapper(SimpleMachine, :compute)

      expect { 
        Timeout::timeout(0.1) do
          SimpleMachine.compute 
        end
      }.to raise_error Timeout::Error

    end
  end
end
