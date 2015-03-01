require "spec_helper"

describe ChompyApp::SocketMiddleware::Router do
  let(:get_games_request) do 
    {
      "headers"  => {
        "method" => "GET",
        "url"    => "/games"
      },
      "body" => { 
        "game" => {
          "name" => "My Great Game"
        }
      }
    }.to_json
  end

  let(:create_game_request) do 
    {
      "headers"  => {
        "method" => "POST",
        "url"    => "/games"
      },
      "body" => { 
        "game" => {
          "name" => "My Great Game"
        }
      }
    }.to_json
  end

  before(:all) do
    ChompyApp::SocketMiddleware::Router.draw do
      get  "/games" => {:controller => Mocks::GamesController, :action => "index"}
      post "/games" => {:controller => Mocks::GamesController, :action => "create"}
    end
  end

  it "routes to get requests" do
    expect(Mocks::GamesController).to receive(:index)

    ChompyApp::SocketMiddleware::Router.route(get_games_request)
  end

  it "routes to post requests" do
    expect(Mocks::GamesController).to receive(:create)

    ChompyApp::SocketMiddleware::Router.route(create_game_request)
  end

  it "returns the results of the controller action" do
    response = ROpenStruct.new(
                 JSON.parse(
                   ChompyApp::SocketMiddleware::Router.route(get_games_request)
                 )
    )

    expect(response.body.game.name).to eq "My Great Game"
  end
end
