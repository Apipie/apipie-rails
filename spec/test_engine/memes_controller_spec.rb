require 'spec_helper'

describe TestEngine::MemesController do

  describe "#index" do
    it "should have the full mounted path of engine" do
      Apipie.routes_for_action(TestEngine::MemesController, :index, {}).first[:path].should eq("/test/memes")
    end
  end
end
