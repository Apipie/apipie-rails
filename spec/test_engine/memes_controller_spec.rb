require 'spec_helper'

describe TestEngine::MemesController do

  describe "#index" do
    it "has the full mounted path of engine" do
      expect(Apipie.routes_for_action(TestEngine::MemesController, :index, {}).first[:path]).to eq("/test/memes")
    end
  end
end
