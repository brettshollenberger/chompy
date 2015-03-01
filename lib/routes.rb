ChompyApp::SocketMiddleware::Router.draw do
  post "/web_requests" => {:controller => WebRequestsController, :action => "create"}
end
