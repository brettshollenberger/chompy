class WebRequestsController
  def self.create(params, sock)
    ChompyApp::WebRequestWorker.perform_async(sock.fileno, params.as_json)

    "Request received"
  end
end
