require "spec_helper"

describe ChompyApp::SocketMiddleware::Request do
  let(:request) do 
    ChompyApp::SocketMiddleware::Request.new({
      "headers"  => {
        "method" => "POST",
        "url"    => "/games"
      },
      "body" => { 
        "game" => {
          "name" => "My Great Game"
        }
      }
    }.to_json)
  end

  it "parses the request method" do
    expect(request.method).to eq "POST"
  end

  it "parses the request url" do
    expect(request.url).to eq "/games"
  end

  it "parses the body to an ROpenStruct" do
    expect(request.body.game.name).to eq "My Great Game"
  end
end
