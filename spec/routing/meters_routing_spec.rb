require "rails_helper"

RSpec.describe MetersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/meters").to route_to("meters#index")
    end

    it "routes to #new" do
      expect(:get => "/meters/new").to route_to("meters#new")
    end

    it "routes to #show" do
      expect(:get => "/meters/1").to route_to("meters#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/meters/1/edit").to route_to("meters#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/meters").to route_to("meters#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/meters/1").to route_to("meters#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/meters/1").to route_to("meters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/meters/1").to route_to("meters#destroy", :id => "1")
    end

  end
end
