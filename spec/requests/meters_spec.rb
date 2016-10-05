require 'rails_helper'

RSpec.describe "Meters", type: :request do
  describe "GET /meters" do
    it "works! (now write some real specs)" do
      get meters_path
      expect(response).to have_http_status(200)
    end
  end
end
