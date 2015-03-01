module Mocks
  class GamesController
    def self.index(params)
      params.as_json
    end

    def self.create(params)
    end
  end
end
