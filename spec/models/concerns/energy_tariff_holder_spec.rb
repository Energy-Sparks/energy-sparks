require 'rails_helper'

describe EnergyTariffHolder do

  let!(:energy_tariff)   { create(:energy_tariff, :with_flat_price, tariff_holder: tariff_holder, meter_type: 'electricity', name: 'Electricity tariff both') }

  context '.energy_tariff_meter_attributes' do
    context 'with SiteSettings' do
      let(:tariff_holder)   { SiteSettings.current }

      it 'adds the association' do
        expect(tariff_holder.energy_tariffs.first).to eq energy_tariff
      end

      it 'has no parent' do
        expect(tariff_holder.parent_tariff_holder).to be_nil
      end

      it 'maps the tariffs to meter attribute' do
        expect(tariff_holder.energy_tariff_meter_attributes.first).to be_a MeterAttribute
      end
    end

    context 'with SchoolGroup' do
      let!(:site_settings)   { SiteSettings.current }
      let(:tariff_holder)    { create(:school_group) }

      before do
        site_settings.save!
      end

      it 'adds the association' do
        expect(tariff_holder.energy_tariffs.first).to eq energy_tariff
      end

      it 'has a parent' do
        expect(tariff_holder.parent_tariff_holder).to eq site_settings
      end

      it 'maps the tariffs to meter attribute' do
        expect(tariff_holder.energy_tariff_meter_attributes.first).to be_a MeterAttribute
      end
    end

    context 'with School' do
      let!(:site_settings) { SiteSettings.current }
      let(:school_group) { nil }
      let(:tariff_holder) { create(:school, school_group: school_group) }
      let!(:energy_tariff_electricty_half_hourly) { create(:energy_tariff, :with_flat_price, tariff_holder: tariff_holder, meter_type: "electricity", applies_to: "half_hourly", name: 'Electricity Tariff half_hourly') }
      let!(:energy_tariff_electricty_non_half_hourly) { create(:energy_tariff, :with_flat_price, tariff_holder: tariff_holder, meter_type: "electricity", applies_to: "non_half_hourly", name: 'Electricity Tariff non_half_hourly') }
      let!(:energy_tariff_gas_both) { create(:energy_tariff, :with_flat_price, tariff_holder: tariff_holder, meter_type: "gas", applies_to: "both", name: 'Gas Tariff both') }

      before do
        site_settings.save!
      end

      it 'has SiteSettings as a parent if no group' do
        expect(tariff_holder.parent_tariff_holder).to eq site_settings
      end

      it 'maps the tariffs to meter attribute' do
        expect(tariff_holder.energy_tariff_meter_attributes.first).to be_a MeterAttribute
      end

      it 'maps the tariffs to meter attribute filtering by meter type and applies to' do
        expect(tariff_holder.energy_tariffs.count).to eq(4)

        expect(tariff_holder.energy_tariffs.both.count).to eq(2)

        expect(tariff_holder.energy_tariffs.electricity.both.count).to eq(1)
        expect(tariff_holder.energy_tariffs.electricity.half_hourly.count).to eq(1)
        expect(tariff_holder.energy_tariffs.electricity.non_half_hourly.count).to eq(1)

        expect(tariff_holder.energy_tariffs.gas.both.count).to eq(1)
        expect(tariff_holder.energy_tariffs.gas.half_hourly.count).to eq(0)
        expect(tariff_holder.energy_tariffs.gas.non_half_hourly.count).to eq(0)

        expect(tariff_holder.energy_tariff_meter_attributes.map { |m| m.input_data['name'] }.sort).to eq(["Electricity tariff both", "Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity', 'gas']).map { |m| m.input_data['name'] }.sort).to eq(["Electricity tariff both", "Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity', 'gas'], :both).map { |m| m.input_data['name'] }.sort).to eq(["Electricity tariff both", "Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity', 'gas'], :half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Electricity Tariff half_hourly", "Electricity tariff both", "Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity', 'gas'], :non_half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Electricity Tariff non_half_hourly", "Electricity tariff both", "Gas Tariff both"])

        expect(tariff_holder.energy_tariff_meter_attributes(['electricity']).map { |m| m.input_data['name'] }.sort).to eq(["Electricity tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity'], :both).map { |m| m.input_data['name'] }.sort).to eq(["Electricity tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity'], :half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Electricity Tariff half_hourly", "Electricity tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['electricity'], :non_half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Electricity Tariff non_half_hourly", "Electricity tariff both"])

        expect(tariff_holder.energy_tariff_meter_attributes(['gas']).map { |m| m.input_data['name'] }.sort).to eq(["Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['gas'], :both).map { |m| m.input_data['name'] }.sort).to eq(["Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['gas'], :half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Gas Tariff both"])
        expect(tariff_holder.energy_tariff_meter_attributes(['gas'], :non_half_hourly).map { |m| m.input_data['name'] }.sort).to eq(["Gas Tariff both"])
      end

      context 'that has a school group' do
        let(:school_group)  { create(:school_group) }
        it 'the group is the parent' do
          expect(tariff_holder.parent_tariff_holder).to eq school_group
        end
      end
    end
  end

  context '.all_energy_tariff_attributes' do
    let!(:site_settings)   { SiteSettings.current }
    let(:school_group)     { create(:school_group) }
    let(:tariff_holder)    { create(:school, school_group: school_group) }

    let!(:site_wide)   { create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current) }
    let!(:group_level) { create(:energy_tariff, :with_flat_price, tariff_holder: school_group) }
    let(:attributes)   { tariff_holder.all_energy_tariff_attributes }

    it 'maps all the inherited tariffs to meter attributes' do
      expect(attributes.size).to eq 3
      expect(attributes[0].input_data['tariff_holder']).to eq 'site_settings'
      expect(attributes[1].input_data['tariff_holder']).to eq 'school_group'
      expect(attributes[2].input_data['tariff_holder']).to eq 'school'
    end

    context 'when filtering by meter type' do
      let!(:group_level) { create(:energy_tariff, :with_flat_price, tariff_holder: school_group, meter_type: :gas) }
      let(:attributes)   { tariff_holder.all_energy_tariff_attributes(:gas) }

      it 'maps all the expected tariffs to meter attributes' do
        expect(attributes.size).to eq 1
        expect(attributes[0].input_data['tariff_holder']).to eq 'school_group'
      end
    end

    context 'when there are enabled and disabled tariffs' do
      let!(:site_wide_2)   { create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current, enabled: false) }
      let!(:group_level_2) { create(:energy_tariff, :with_flat_price, tariff_holder: school_group, enabled: false) }

      it 'maps only the enabled tariffs' do
        expect(attributes.size).to eq 3
      end

    end
  end

  context '.default_tariff_start_date' do
    let(:tariff_holder) { SiteSettings.current }
    it 'defaults to one day later' do
      expect(tariff_holder.default_tariff_start_date(:electricity)).to eq energy_tariff.end_date + 1.day
    end

    it 'defaults to today otherwise' do
      EnergyTariff.destroy_all
      expect(tariff_holder.default_tariff_start_date(:electricity)).to eq Time.zone.today
    end

    it 'checks source when provided' do
      expect(tariff_holder.default_tariff_start_date(:electricity, :dcc)).to eq Time.zone.today
    end
  end
end
