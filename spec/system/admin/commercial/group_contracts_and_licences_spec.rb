# frozen_string_literal: true

require 'rails_helper'

describe 'group contracts and licences', :include_application_helper do
  let(:school_group) { create(:school_group) }
  let!(:licence) do
    create(:commercial_licence, school: create(:school, :with_trust, group: school_group, calendar: nil))
  end
  let!(:academic_year) do
    create(:academic_year,
           start_date: Date.new(2025, 9, 1),
           end_date: Date.new(2026, 8, 31),
           calendar: create(:calendar, :default_national))
  end
  let!(:next_academic_year) do
    create(:academic_year,
           calendar: academic_year.calendar,
           start_date: Date.new(2026, 9, 1),
           end_date: Date.new(2027, 8, 31))
  end
  let(:today) { Date.new(2026, 4, 1) }

  before do
    travel_to today
    sign_in(create(:admin))
    visit settings_school_group_path(school_group)
  end

  context 'when visiting licence summaries' do
    before do
      within('#admin') do
        click_on 'Licence summaries'
      end
    end

    it { expect(page).to have_css('div.commercial-licensing-summary-component') }
    it { expect(page).to have_text(licence.school.name) }
    it { expect(page).to have_link('Licences', href: admin_school_licences_path(licence.school)) }

    it 'summarises current academic year (2025-2026)' do
      expect(page).to have_text(
        "#{short_dates(academic_year.start_date)} - #{short_dates(academic_year.end_date)}"
      )
    end

    it 'summarises next academic year (2026-2027)' do
      expect(page).to have_text(
        "#{short_dates(next_academic_year.start_date)} - #{short_dates(next_academic_year.end_date)}"
      )
    end

    it {
      expect(page).to have_link('Emailable summary',
                                href: admin_school_group_licence_summaries_path(school_group, format: :text))
    }
  end

  context 'when in September it still reports as if in previous year' do
    let(:today) { Date.new(2026, 9, 1) }

    before do
      within('#admin') do
        click_on 'Licence summaries'
      end
    end

    it 'summarises last academic year (2025-2026)' do
      expect(page).to have_text(
        "#{short_dates(academic_year.start_date)} - #{short_dates(academic_year.end_date)}"
      )
    end

    it 'summarises this academic year (2026-2027)' do
      expect(page).to have_text(
        "#{short_dates(next_academic_year.start_date)} - #{short_dates(next_academic_year.end_date)}"
      )
    end
  end

  context 'when visiting contracts' do
    let!(:contract) { create(:commercial_contract, contract_holder: school_group) }

    before do
      within('#admin') do
        click_on 'Contracts'
      end
    end

    it { expect(page).to have_css('div.commercial-contracts-component') }
    it { expect(page).to have_text(contract.name) }
  end
end
