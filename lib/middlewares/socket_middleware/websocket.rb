require "faye/websocket"

  class SocketMiddleware
    class Websocket < Faye::WebSocket
      def fileno
        env["puma.socket"].fileno
      end
    end
  end
