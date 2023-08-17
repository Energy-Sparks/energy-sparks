require "rails_helper"

RSpec.describe EnergyTariffTableComponent, type: :component do

  let(:current_user)      { create(:admin) }
  let(:tariff_holder)     { SiteSettings.current }
  let(:enabled)           { true }
  let(:source)            { :manually_entered }
  let(:energy_tariffs)    { [create(:energy_tariff, tariff_holder: tariff_holder, meter_type: :electricity, enabled: enabled, source: source)] }
  let(:show_actions)      { true }

  let(:params) {
    {
      tariff_holder: tariff_holder,
      tariffs: energy_tariffs,
      show_actions: show_actions
    }
  }

  let(:component) { EnergyTariffTableComponent.new(**params) }

  let(:html) do
    with_controller_class ApplicationController do
      render_inline(component)
    end
  end

  #This allows us to set what the current user is during rendering
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  context '.show_meters?' do
    it 'returns false' do
      expect(component.show_meters?).to be false
    end
    context 'with school' do
      let(:tariff_holder) { create(:school) }
      it 'returns true' do
        expect(component.show_meters?).to be true
      end
    end
  end

  context '.flat_rate_label' do
    it 'returns expected label' do
      expect(component.flat_rate_label(energy_tariffs.first)).to eq I18n.t('schools.user_tariffs.tariff_partial.simple_tariff')
    end
    context 'with differential tariff' do
      let(:energy_tariffs) { [create(:energy_tariff, tariff_type: :differential)]}
      it 'returns expected label' do
        expect(component.flat_rate_label(energy_tariffs.first)).to eq I18n.t('schools.user_tariffs.tariff_partial.day_night_tariff')
      end
    end
  end

  context '.start_date' do
    let(:start_date)  { component.start_date(energy_tariffs.first) }
    it 'returns expected date' do
      expect(start_date).to eq energy_tariffs.first.start_date.to_s(:es_compact)
    end
    context 'with open ended tariff' do
      let(:energy_tariffs) { [create(:energy_tariff, start_date: nil)]}
      it 'returns no start date' do
        expect(start_date).to eq I18n.t('schools.user_tariffs.summary_table.no_start_date')
      end
    end
  end

  context '.end_date' do
    let(:end_date)  { component.end_date(energy_tariffs.first) }
    it 'returns expected date' do
      expect(end_date).to eq energy_tariffs.first.end_date.to_s(:es_compact)
    end
    context 'with open ended tariff' do
      let(:energy_tariffs) { [create(:energy_tariff, end_date: nil)]}
      it 'returns no start date' do
        expect(end_date).to eq I18n.t('schools.user_tariffs.summary_table.no_end_date')
      end
    end
  end

  context 'basic rendering' do
    it 'renders table' do
      expect(html).to have_css('#tariff-table')
    end

    it 'includes the tariff details' do
      within('#tariff-table tbody tr[1]') do
        expect(html).to have_content(energy_tariffs.first.name)
        expect(html).to have_content('schools.user_tariffs.tariff_partial.simple_tariff')
        expect(html).to have_content(energy_tariffs.first.start_date.to_s(:es_compact))
        expect(html).to have_content(energy_tariffs.first.end_date.to_s(:es_compact))
      end
    end

    context 'with differential tariff' do
      let(:energy_tariffs) { [create(:energy_tariff, tariff_type: :differential)]}
      it 'returns expected label' do
        within('#tariff-table tbody tr[1]') do
          expect(html).to eq I18n.t('schools.user_tariffs.tariff_partial.day_night_tariff')
        end
      end
    end

    context 'with an id' do
      let(:params) {
        {
          tariff_holder: tariff_holder,
          tariffs: energy_tariffs,
          show_actions: show_actions,
          id: 'my-custom-id'
        }
      }
      it 'renders table with id' do
        expect(html).to have_css('#my-custom-id')
      end
    end

  end

  context 'action buttons' do
    it 'includes the actions' do
      expect(html).to have_link('View details')
      expect(html).to have_link('Edit')
      expect(html).to have_link('Deactivate')
      expect(html).to_not have_link('Delete')
    end

    context 'with disabled site settings tariff' do
      let(:enabled)   { false }
      it 'includes all the actions' do
        expect(html).to have_link('View details')
        expect(html).to have_link('Edit')
        expect(html).to have_link('Activate')
        expect(html).to have_link('Delete')
      end
    end

    context 'with dcc tariff' do
      let(:source)  { :dcc }
      it 'includes the actions' do
        expect(html).to have_link('View details')
        expect(html).to have_link('Edit')
        expect(html).to have_link('Deactivate')
        expect(html).to_not have_link('Delete')
      end

      context 'that is disabled' do
        let(:enabled)   { false }
        it 'includes the expected actions' do
          expect(html).to have_link('View details')
          expect(html).to have_link('Edit')
          expect(html).to have_link('Activate')
        end
      end

    end

    context 'with non-authorised user' do
      let(:current_user)  { create(:school_admin) }

      it 'does not include the actions' do
        expect(html).to_not have_link('View details')
        expect(html).to_not have_link('Edit')
        expect(html).to_not have_link('Deactivate')
        expect(html).to_not have_link('Delete')
      end
    end

  end
end
