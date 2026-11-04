# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Activities::CountryTabsComponent, :include_url_helpers, type: :component do
  let(:country) { :england }

  before { render_inline(described_class.new(country:, resource_class:)) }

  context 'with a namespaced resource class' do
    let(:resource_class) { Activities::SubjectArea }

    it 'links each country to the subject areas for that country' do
      Enums::Country::ENUM_COUNTRY.each_key do |option|
        expect(page).to have_link(option.to_s.titleize,
                                  href: admin_activities_subject_areas_path(country: option))
      end
    end

    it 'marks the current country as active' do
      expect(page).to have_css("a.active[href='#{admin_activities_subject_areas_path(country: :england)}']")
    end
  end

  context 'with a top-level resource class' do
    let(:resource_class) { LearningStage }

    it 'links each country to the learning stages for that country' do
      expect(page).to have_link('Wales', href: admin_activities_learning_stages_path(country: :wales))
    end
  end

  context 'when the country is passed as a string' do
    let(:resource_class) { LearningStage }
    let(:country) { 'wales' }

    it 'still marks that country as active' do
      expect(page).to have_css("a.active[href='#{admin_activities_learning_stages_path(country: :wales)}']")
    end
  end
end
