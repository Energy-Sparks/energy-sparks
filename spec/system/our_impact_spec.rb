# frozen_string_literal: true

require 'rails_helper'

describe 'manage organisation impact statement' do
  include ActionView::Helpers::NumberHelper

  let!(:statement) { create(:impact_report_organisation_statement, :current) }

  before do
    Flipper.enable :org_impact_page
    visit our_impact_path
  end

  it { expect(page).to have_text(I18n.t('our_impact.title')) }
  it { expect(page).to have_link(I18n.t('home.buttons.our_tool'), href: product_path) }
  it { expect(page).to have_link(I18n.t('support_us.title'), href: support_us_path) }

  context 'when showing energy savings cards' do
    it 'shows the correct title' do
      within('#energy-savings') do
        expect(page).to have_text(I18n.t('our_impact.energy_savings.title'))
      end
    end

    it 'shows the cards' do
      within('#energy-savings-cards') do
        expect(page).to have_text(number_with_delimiter(statement.total_cost_savings))
        expect(page).to have_text(number_with_delimiter(statement.total_carbon_savings))
      end
    end
  end

  %i[primary secondary].each do |school_type|
    context "when showing #{school_type} savings cards" do
      it 'shows the cards' do
        within("##{school_type}-cards") do
          expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_saving_electricity"]))
          expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_saving_gas"]))
          expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_cost_saving"]))
          expect(page).to have_text(number_with_delimiter(statement.attributes["#{school_type}_carbon_saving"]))
        end
      end
    end
  end

  context 'when showing our reach' do
    it 'shows the correct title' do
      within('#our-reach') do
        expect(page).to have_text(I18n.t('our_impact.our_reach.title'))
      end
    end

    it 'shows the our reach cards' do
      within('#our-reach-cards') do
        expect(page).to have_text(number_with_delimiter(statement.schools))
        expect(page).to have_text(number_with_delimiter(statement.pupils))
        expect(page).to have_text(number_with_delimiter(statement.staff))
      end
    end
  end

  context 'when showing behaviour change' do
    it 'shows the correct title' do
      within('#behaviour-change') do
        expect(page).to have_text(I18n.t('our_impact.behaviour_change.title'))
      end
    end

    it 'shows the behaviour cards' do
      within('#behaviour-change-cards') do
        expect(page).to have_text(number_with_delimiter(statement.activities))
        expect(page).to have_text(number_with_delimiter(statement.actions))
      end
    end
  end

  context 'when showing testimonials' do
    it 'shows first testimonial' do
      within('#first-testimonial') do
        expect(page).to have_text(statement.first_testimonial.title)
      end
    end

    it 'shows second testimonial' do
      within('#second-testimonial') do
        expect(page).to have_text(statement.second_testimonial.title)
      end
    end
  end

  it {
    expect(page).to have_link(I18n.t('our_impact.further_insights.report_button'),
                              href: statement.efficiency_report_link)
  }

  it { expect(page).to have_link(I18n.t('home.buttons.read_case_studies'), href: case_studies_path) }
end
