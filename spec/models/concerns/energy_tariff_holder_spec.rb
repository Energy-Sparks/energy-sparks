require 'rails_helper'

describe EnergyTariffHolder do

  let!(:energy_tariff)   { create(:energy_tariff, :with_flat_price, tariff_holder: tariff_holder) }

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
      let!(:site_settings)   { SiteSettings.current }
      let(:school_group)     { nil }
      let(:tariff_holder)    { create(:school, school_group: school_group) }

      before do
        site_settings.save!
      end

      it 'has SiteSettings as a parent if no group' do
        expect(tariff_holder.parent_tariff_holder).to eq site_settings
      end

      it 'maps the tariffs to meter attribute' do
        expect(tariff_holder.energy_tariff_meter_attributes.first).to be_a MeterAttribute
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
  end
end
