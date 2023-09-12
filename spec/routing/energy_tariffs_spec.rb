require "rails_helper"

RSpec.describe "routes for energy tariffs editor", type: :routing do

  shared_examples "tariff holder concern" do

    it { expect(:get => "#{scope}/energy_tariffs").to route_to("energy_tariffs/energy_tariffs#index", param) }
    it { expect(:get => "#{scope}/energy_tariffs/choose_meters").to route_to("energy_tariffs/energy_tariffs#choose_meters", param) } # doesn't actually work when visiting page
    it { expect(:get => "#{scope}/energy_tariffs/default_tariffs").to route_to("energy_tariffs/energy_tariffs#default_tariffs", param) }
    it { expect(:get => "#{scope}/energy_tariffs/smart_meter_tariffs").to route_to("energy_tariffs/energy_tariffs#smart_meter_tariffs", param) }

    context "with energy tariff" do
      let(:energy_tariff) { create(:energy_tariff) }
      it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}").to route_to("energy_tariffs/energy_tariffs#show", { id: energy_tariff.to_param }.merge(param)) }
      it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/edit_meters").to route_to("energy_tariffs/energy_tariffs#edit_meters", { id: energy_tariff.to_param }.merge(param)) }
      it { expect(:post => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/update_meters").to route_to("energy_tariffs/energy_tariffs#update_meters", { id: energy_tariff.to_param }.merge(param)) }
      it { expect(:post => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/update_type").to route_to("energy_tariffs/energy_tariffs#update_type", { id: energy_tariff.to_param }.merge(param)) }
      it { expect(:post => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/toggle_enabled").to route_to("energy_tariffs/energy_tariffs#toggle_enabled", { id: energy_tariff.to_param }.merge(param)) }

      context "energy_tariff_flat_prices" do
        it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/energy_tariff_flat_prices").to route_to("energy_tariffs/energy_tariff_flat_prices#index", { energy_tariff_id: energy_tariff.to_param }.merge(param)) }
      end

      context "energy_tariff_charges" do
        it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/energy_tariff_charges").to route_to("energy_tariffs/energy_tariff_charges#index", { energy_tariff_id: energy_tariff.to_param }.merge(param)) }
      end

      context "energy_tariff_differential_prices" do
        it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/energy_tariff_differential_prices").to route_to("energy_tariffs/energy_tariff_differential_prices#index", { energy_tariff_id: energy_tariff.to_param }.merge(param)) }
        it { expect(:get => "#{scope}/energy_tariffs/#{energy_tariff.to_param}/energy_tariff_differential_prices/reset").to route_to("energy_tariffs/energy_tariff_differential_prices#reset", { energy_tariff_id: energy_tariff.to_param }.merge(param)) }
      end
    end
  end

  describe "admin site settings tariff editor" do
    it_behaves_like "tariff holder concern" do
      let(:scope) { "/admin/settings" }
      let(:param) { { } }
    end

    it 'routes site_settings_energy_tariffs_path to the EnergyTariff controller' do
      expect(get(admin_settings_energy_tariffs_path)).to route_to(
        {
          controller: 'energy_tariffs/energy_tariffs',
          action: 'index'
        }
      )
    end
  end

  describe "school group tariff editor" do
    let!(:school_group) { create(:school_group, name: 'Big School Group') }

    it_behaves_like "tariff holder concern" do
      let(:scope) { "/school_groups/big-school-group" }
      let(:param) { { school_group_id: school_group.to_param } }
    end

    it 'routes school_group_energy_tariffs_path to the EnergyTariff controller' do
      expect(get(school_group_energy_tariffs_path(school_group))).to route_to(
        {
          controller: 'energy_tariffs/energy_tariffs',
          action: 'index',
          school_group_id: 'big-school-group'
        }
      )
    end
  end

  describe "school tariff editor" do
    let!(:school) { create_active_school(name: "Big School")}

    it_behaves_like "tariff holder concern" do
      let(:scope) { "/schools/big-school" }
      let(:param) { { school_id: school.to_param } }
    end

    it 'routes school_energy_tariffs_path to the EnergyTariff controller' do
      expect(get(school_energy_tariffs_path(school))).to route_to(
        {
          controller: 'energy_tariffs/energy_tariffs',
          action: 'index',
          school_id: 'big-school'
        }
      )
    end
  end
end
