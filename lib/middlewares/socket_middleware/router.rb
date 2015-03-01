require "ostruct"

class ChompyApp
  class SocketMiddleware
    class Router
      @routes = {}

      def self.draw(&block)
        instance_eval &block
      end

      %w(get post put delete).each do |method|
        define_singleton_method method do |options|
          options.each do |k, v|
            @routes[{:request_method => method.to_sym, :url => k}] = v
          end
        end
      end

      def self.route(request, sock)
        begin
          request = Request.new(request)
          route   = OpenStruct.new @routes[{:request_method => request.method.downcase.to_sym, 
                                            :url => request.url}]
        rescue Request::UnprocessableEntityError
          return socket_error request, :unprocessable_entity_error
        end

        if route.nil?
          return socket_error request, :not_found_error
        else
          return socket_response request, route.controller.send(route.action, request.body, sock)
        end
      end

    private
      def self.socket_response(request, body)
        method = request.respond_to?(:headers) ? request.headers.method : :unprocessable
        url    = request.respond_to?(:headers) ? request.headers.url : :unprocessable

        JSON.generate({
          headers: {
            method: method,
            url: url
          },
          body: body
        })
      end
      
      def self.socket_error(request, error_name)
        socket_response request, send(error_name)
      end

      def self.unprocessable_entity_error
        { :status => 422, :message => "Unprocessable entity" }
      end

      def self.not_found_error
        { :status => 404, :message => "Not found" }
      end
    end
  end
end
