# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rack::Attack' do
  before do
    Rack::Attack.enabled = true
  end

  after do
    Rack::Attack.enabled = false
  end

  describe 'when blocking illegal searches' do
    it 'allows the initial search page load with no params' do
      get '/activity_types/search'
      expect(response).not_to have_http_status(:forbidden)
    end

    it 'allows empty form submit when query param is present' do
      get '/activity_types/search', params: { query: '', key_stages: '', subjects: '', commit: 'Search' }
      expect(response).not_to have_http_status(:forbidden)
    end

    it 'allows real searches with a query' do
      get '/activity_types/search', params: { query: 'science' }
      expect(response).not_to have_http_status(:forbidden)
    end

    it 'blocks requests missing query but containing other params' do
      get '/activity_types/search', params: { key_stages: 'KS1,KS2', subjects: 'Maths' }
      expect(response).to have_http_status(:forbidden)
    end

    it 'blocks requests with subjects but no query' do
      get '/activity_types/search', params: { subjects: 'Languages' }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
