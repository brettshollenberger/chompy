class ChompyApp < Sinatra::Base
  class SocketMiddleware
    class Request
      class UnprocessableEntityError < StandardError; end

      attr_accessor :request

      def initialize(request={})
        begin
          @request = ROpenStruct.new(JSON.parse(request))
        rescue
          raise UnprocessableEntityError
        end
      end

      def headers
        request.headers
      end

      def method
        headers.method
      end

      def url
        headers.url
      end

      def body
        request.body
      end
    end
  end
end
