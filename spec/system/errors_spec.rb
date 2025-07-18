require 'rails_helper'

RSpec.describe 'errors', type: :system do
  describe '404' do
    before do
      visit '/404'
    end

    it_behaves_like 'a 404 error page'
  end

  describe '500' do
    before do
      visit '/500'
    end

    it_behaves_like 'a 500 error page'
  end

  describe '422' do
    before do
      visit '/422'
    end

    it_behaves_like 'a 422 error page'
  end
end
