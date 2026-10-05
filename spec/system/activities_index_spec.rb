# frozen_string_literal: true

require 'rails_helper'

describe 'activities index' do
  context 'with a header' do
    before do
      Flipper.enable(:activities_index)
      create(:activity_type)
      visit activities_path
    end

    it 'has a title' do
      expect(page).to have_text('Explore energy saving activities')
    end

    it 'has a description' do
      expect(page).to have_text('Energy Sparks provides extensive support to teachers and pupils')
      expect(page).to have_text('Use the links below to explore 1 freely available activities.')
    end

    it 'has an image' do
      expect(page).to have_css("img.elements-image-component[src*='recommendations/opt-in']")
    end
  end
end
