module Mocks
  class GamesController
    def self.index(params, sock)
      params.as_json
    end

    def self.create(params)
    end
  end
end
