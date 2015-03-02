require "json"

$redis ||= Redis.new

class ChompyApp
  class SocketMiddleware
    KEEPALIVE_TIME = 15

    class << self
      def subscriptions
        @subscriptions ||= {}
      end
    end

    def initialize(app, &block)
      instance_eval(&block)
      @app         = app
    end

    def chunker
      @chunker ||= MessageChunker.new(chunk_size: 1000)
    end

    def call(env)
      if Websocket.websocket?(env)
        initialize_socket(env).rack_response
      else
        @app.call(env)
      end
    end

  private
    def initialize_socket(env={})
      ws = Websocket.new(env, nil, {ping: KEEPALIVE_TIME})

      ws.on :open, &__on_open__(ws)
      ws.on :message, &__on_message__(ws)
      ws.on :close, &__on_close__(ws)

      return ws
    end

    def on_open(ws)
    end

    def on_message(ws, event)
    end

    def on_close(ws)
    end

    def __on_open__(ws)
      proc do
        p "socket opened"

        SocketMiddleware.subscriptions[ws.fileno] = Thread.new do
          $redis.subscribe(ws.fileno) do |on|
            on.message do |channel, message|
              json = JSON.parse(message)

              if json["response"].present?
                chunker.chunk(json["response"]).each do |chunk|
                  ws.send(chunk.merge(params: json["params"]).to_json)
                end
              else
                ws.send(message)
              end
            end
          end
        end

        on_open(ws)
      end
    end

    def __on_message__(ws)
      proc do |event|
        p [:message, event.data]

        ws.send Router.route(event.data, ws)

        on_message(ws, event)
      end
    end

    def __on_close__(ws)
      proc do |event|
        p [:close]

        SocketMiddleware.subscriptions[ws.fileno].kill
        SocketMiddleware.subscriptions.delete(ws.fileno)

        on_close(ws)
      end
    end
  end
end
