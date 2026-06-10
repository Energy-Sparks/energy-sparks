# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::RangeFundingSummaryComponent, type: :component do
  subject(:component) { described_class.new(school_group:, range:) }

  let!(:school_group) { create(:school_group) }
  let(:range) { Date.new(2025, 9, 1)..Date.new(2026, 8, 31) }

  def create_licences_in_group(number, contract_holder)
    create(:commercial_contract, contract_holder:).then do |contract|
      number.times do
        create(:commercial_licence,
               contract:,
               school: create(:school, school_group:),
               start_date: range.begin + 1.month,
               end_date: range.end)
      end
      contract
    end
  end

  context 'when rendering as HTML' do
    context 'with no licences' do
      it { expect(component.render?).to be(false) }
    end

    context 'with only funded schools' do
      before do
        contract = create(:commercial_contract, contract_holder: create(:funder))
        create(:commercial_licence,
               contract:,
               school: create(:school, school_group:),
               start_date: range.begin,
               end_date: range.end)
        render_inline component
      end

      it { expect(page).to have_text('1 funded schools') }
      it { expect(page).to have_no_text('partially group funded schools') }
      it { expect(page).to have_no_text('group funded schools') }

      context 'with a range label' do
        subject(:component) { described_class.new(school_group:, range:, range_label: 'this academic year') }

        it { expect(page).to have_text('For this academic year this group has:') }
      end
    end

    context 'with self funded schools' do
      before do
        school = create(:school, school_group:)
        contract = create(:commercial_contract, contract_holder: school)
        create(:commercial_licence,
               contract:,
               school:,
               start_date: range.begin,
               end_date: range.end)
        render_inline component
      end

      it { expect(page).to have_text('1 self funded schools') }
    end

    context 'with group funded schools' do
      before do
        contract = create(:commercial_contract, contract_holder: school_group)
        create(:commercial_licence,
               contract:,
               school: create(:school, school_group:),
               start_date: range.begin,
               end_date: range.end)
        render_inline component
      end

      it { expect(page).to have_text('1 group funded schools') }
      it { expect(page).to have_no_text('partially group funded schools') }
    end

    context 'with partially group funded schools' do
      before do
        contract = create(:commercial_contract, contract_holder: school_group)
        school = create(:school, school_group:)
        create(:commercial_licence,
               contract:,
               school:,
               start_date: range.begin + 1.month,
               end_date: range.end)
        create(:commercial_licence,
               contract: create(:commercial_contract, contract_holder: create(:funder)),
               school:,
               start_date: range.begin,
               end_date: range.begin + 1.month)
        render_inline component
      end

      it { expect(page).to have_text('1 partially group funded schools') }
    end

    context 'with group funded schools for part year' do
      before do
        contract = create(:commercial_contract, contract_holder: school_group)
        school = create(:school, school_group:)
        create(:commercial_licence,
               contract:,
               school:,
               start_date: range.begin,
               end_date: range.begin + 1.month)
        render_inline component
      end

      it { expect(page).to have_text('1 group funded schools') }
    end

    context 'with range of licences' do
      before do
        group_contract = create_licences_in_group(3, school_group)
        funder_contract = create_licences_in_group(2, create(:funder))
        school = create(:school, school_group:)
        create(:commercial_licence,
               contract: group_contract,
               school:,
               start_date: range.begin + 1.month,
               end_date: range.end)
        create(:commercial_licence,
               contract: funder_contract,
               school:,
               start_date: range.begin,
               end_date: range.begin + 1.month)
        render_inline component
      end

      it { expect(page).to have_text('2 funded schools') }
      it { expect(page).to have_text('3 group funded schools') }
      it { expect(page).to have_text('1 partially group funded schools') }
    end
  end

  context 'when rendering as text' do
    let!(:group_contract) { create_licences_in_group(3, school_group) }
    let!(:funder_contract) { create_licences_in_group(2, create(:funder)) }
    let(:partially_funded_school) { create(:school, school_group:) }

    before do
      contract = create(:commercial_contract, contract_holder: school_group)
      create(:commercial_licence,
             contract:,
             school: partially_funded_school,
             start_date: range.begin + 1.month,
             end_date: range.end)
      create(:commercial_licence,
             contract:,
             school: partially_funded_school,
             start_date: range.begin,
             end_date: range.begin + 1.month)

      with_format(:text) do
        render_inline described_class.new(school_group:, range:)
      end
    end

    it 'counts schools with funded places' do
      expect(page).to have_text('2 schools with funding for the academic year')
    end

    it 'counts schools with group funded places' do
      expect(page).to have_text('3 schools with fees due for the full academic year')
    end

    it 'counts schools with partially group funded places' do
      expect(page).to have_text('1 school with fees due for part of the academic year')
    end

    it 'produces a list of group funded schools' do
      expect(page).to have_text(group_contract.schools.sort_by(&:name).map(&:name).join("\n"))
    end

    it 'produces a list of funded schools' do
      expect(page).to have_text(funder_contract.schools.sort_by(&:name).map(&:name).join("\n"))
    end
  end
end
