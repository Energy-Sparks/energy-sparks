# frozen_string_literal: true

require 'rails_helper'

describe 'bulk updating meter fields' do
  let(:school) { create(:school, :with_school_group, active: false) }
  let(:other_school) { create(:school, :with_school_group, active: false) }
  let!(:meters) do
    { electricity: [create(:electricity_meter, school:), create(:electricity_meter, school: other_school)],
      gas: [create(:gas_meter, school:), create(:gas_meter, school: other_school)],
      solar_pv: [create(:solar_pv_meter, school:), create(:solar_pv_meter, school: other_school)] }
  end

  before { sign_in(create(:admin)) }

  it 'is on the side menu' do
    visit admin_school_group_path(school.school_group)
    within '#school-group-button-panel' do
      click_on 'Meter updates'
    end
    expect(page).to have_current_path(admin_school_group_meter_updates_path(school.school_group))
  end

  fuel_types = { electricity: 'electricity', gas: 'gas', solar_pv: 'solar PV' }
  fields = {
    data_source: { label_method: :name, group_field: :default_data_source },
    procurement_route: { label_method: :organisation_name, group_field: :default_procurement_route },
    supplier: { label_method: :name },
    admin_meter_status: { label_method: :label, group_field: :admin_meter_status }
  }

  fields.each do |field, options|
    context "with #{field.to_s.humanize.downcase}" do
      let!(:value) { create(field) }
      let(:field_label) { field.to_s.humanize.downcase }
      let(:option_label) { value.public_send(options[:label_method]) }
      let(:group_field) { options[:group_field] }

      before { visit admin_school_group_meter_updates_path(school.school_group) }

      fuel_types.each do |fuel_type, fuel_label|
        it "updates only the group's #{fuel_type} meters" do
          select(option_label, from: "Bulk update #{field_label} for all #{fuel_label} meters")
          click_on "Update #{fuel_label} #{field_label} for all schools in this group"

          expect(page).to have_text("#{field.to_s.titleize} for")
          expect(meters[fuel_type].map { |meter| meter.reload.public_send(field) }).to contain_exactly(value, nil)
          meters.except(fuel_type).each_value do |other_meters|
            expect(other_meters.map { |meter| meter.reload.public_send(field) }).to all(be_nil)
          end
          expect(school.school_group.reload.public_send("#{group_field}_#{fuel_type}")).to eq(value) if group_field
        end
      end

      it 'clears existing values' do
        meters[:electricity].each { |meter| meter.update!(field => value) }
        school.school_group.update!("#{group_field}_electricity" => value) if group_field
        refresh

        select('none', from: "Bulk update #{field_label} for all electricity meters")
        click_on "Update electricity #{field_label} for all schools in this group"

        expect(meters[:electricity].first.reload.public_send(field)).to be_nil
        expect(meters[:electricity].last.reload.public_send(field)).to eq(value)
        expect(school.school_group.reload.public_send("#{group_field}_electricity")).to be_nil if group_field
      end

      it 'includes exported solar pv meters in solar pv updates' do
        export_meter = create(:exported_solar_pv_meter, school:)
        other_export_meter = create(:exported_solar_pv_meter, school: other_school)

        select(option_label, from: "Bulk update #{field_label} for all solar PV meters")
        click_on "Update solar PV #{field_label} for all schools in this group"

        expect(export_meter.reload.public_send(field)).to eq(value)
        expect(other_export_meter.reload.public_send(field)).to be_nil
      end

      if options[:group_field]
        it 'updates from the group default' do
          school.school_group.update!("#{group_field}_electricity" => value)
          refresh

          click_on "Update electricity #{field_label} for all schools in this group"

          expect(meters[:electricity].map { |meter| meter.reload.public_send(field) }).to contain_exactly(value, nil)
        end
      end
    end
  end
end
