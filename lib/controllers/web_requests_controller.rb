class WebRequestsController
  def self.create(params, sock)
    ChompyApp::WebRequestWorker.perform_async(sock.fileno, params.url)

    "request received"
  end
end
