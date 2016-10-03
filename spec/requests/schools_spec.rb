require 'rails_helper'

RSpec.describe "Schools", type: :request do
  describe "GET /schools" do
    it "works! (now write some real specs)" do
      get schools_path
      expect(response).to have_http_status(200)
    end
  end
end
