module Mocks
  class SocketEvent
    attr_accessor :data

    def initialize(options={})
      @data = options[:data]
    end
  end
end
