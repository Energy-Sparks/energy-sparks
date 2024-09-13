# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComparisonOverviewComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }

  let(:school) do
    # creates a school with just an electricity meter, ensure fuel configuration matches
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           has_gas: false,
           has_solar_pv: false,
           has_storage_heaters: false)
  end

  let(:meter_collection) do
    AggregateSchoolService.new(school).aggregate_school
  end

  let(:params) do
    {
      school: school,
      meter_collection: meter_collection,
      id: id,
      classes: classes
    }
  end

  describe '#can_benchmark_electricity?' do
    context 'with no electricity' do
      let(:school) { create(:school, :with_fuel_configuration, has_electricity: false) }

      it { expect(component.can_benchmark_electricity?).to be(false) }
    end

    context 'with electricity but not enough data' do
      let(:school) do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading_start_date: Time.zone.yesterday)
      end

      it { expect(component.can_benchmark_electricity?).to be(false) }
    end

    context 'with electricity enough data' do
      let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs) }

      it { expect(component.can_benchmark_electricity?).to be(true) }
    end
  end

  describe '#can_benchmark_gas?' do
    context 'with no gas' do
      let(:school) { create(:school, :with_fuel_configuration, has_gas: false) }

      it { expect(component.can_benchmark_gas?).to be(false) }
    end

    context 'with electricity but not enough data' do
      let(:school) do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, fuel_type: :gas, reading_start_date: Time.zone.yesterday)
      end

      it { expect(component.can_benchmark_gas?).to be(false) }
    end

    context 'with electricity enough data' do
      let(:school) do
        create(:school,
                            :with_basic_configuration_single_meter_and_tariffs,
                            fuel_type: :gas)
      end

      it { expect(component.can_benchmark_gas?).to be(true) }
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_content(I18n.t("school_groups.clusters.group_type.#{school.school_group.group_type}"))}
    it { expect(html).to have_content(I18n.t('components.comparison_overview.title')) }

    it {
      expect(html).to have_link(I18n.t('schools.schools.compare_schools',
                                   href: "#{compare_index_path(school_group_ids: [school.school_group.id])}#groups"))
    }

    it 'shows the fuel comparison' do
      expect(html).to have_css('#electricity-comparison')
      expect(html).to have_content('How does your electricity use for the last 12 months compare to other Primary schools on Energy Sparks, with a similar number of pupils?')
    end
  end
end
