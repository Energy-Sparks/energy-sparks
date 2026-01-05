require 'rails_helper'

RSpec.describe SchoolGroups::SchoolMeterStatusCsvGenerator do
  around do |example|
    travel_to Date.new(2025, 9, 26)
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  let(:school_group) { create(:school_group) }
  let(:data_enabled) { true }

  let!(:school) do
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           fuel_type: fuel_type,
           visible: true,
           data_enabled: data_enabled,
           number_of_pupils: 20,
           floor_area: 300.0,
           school_group:,
           school_group_cluster: create(:school_group_cluster))
  end

  let!(:service) { described_class.new(school_group:, schools: [school], include_cluster: false) }

  describe '#export' do
    context 'with electricity and solar' do
      let(:fuel_type) { :electricity }

      context 'when producing headers' do
        subject(:headers) { CSV.parse(service.export.lines[0]) }

        it 'produces correct headers' do
          expect(headers).to eq([[
                                  I18n.t('school_statistics.school_group'),
                                  I18n.t('common.school'),
                                  I18n.t('advice_pages.index.priorities.table.columns.fuel_type'),
                                  I18n.t('schools.meters.index.meter'),
                                  I18n.t('schools.meters.index.name'),
                                  I18n.t('common.labels.start_date'),
                                  I18n.t('common.labels.end_date')
                                ]])
        end
      end

      context 'when producing rows' do
        subject(:rows) { CSV.parse(service.export.lines[1..].join) }

        it 'produces expected rows' do
          expect(rows).to eq([[
                               school.school_group.name,
                               school.name,
                               I18n.t(fuel_type, scope: 'common'),
                               school.meters.first.mpan_mprn.to_s,
                               school.meters.first.name,
                               school.meters.first.first_validated_reading.iso8601,
                               school.meters.first.last_validated_reading.iso8601
                             ]])
        end

        context 'when including clusters' do
          let!(:service) { described_class.new(school_group:, schools: [school], include_cluster: true) }

          context 'when generating headers' do
            subject(:headers) { CSV.parse(service.export.lines[0]) }

            it 'produces correct headers' do
              expect(headers).to eq([[
                                      I18n.t('school_statistics.school_group'),
                                      I18n.t('common.school'),
                                      I18n.t('school_groups.clusters.labels.cluster'),
                                      I18n.t('advice_pages.index.priorities.table.columns.fuel_type'),
                                      I18n.t('schools.meters.index.meter'),
                                      I18n.t('schools.meters.index.name'),
                                      I18n.t('common.labels.start_date'),
                                      I18n.t('common.labels.end_date')
                                    ]])
            end
          end

          it 'produces expected rows' do
            expect(rows).to eq([[
                                 school.school_group.name,
                                 school.name,
                                 school.school_group_cluster.name,
                                 I18n.t(fuel_type, scope: 'common'),
                                 school.meters.first.mpan_mprn.to_s,
                                 school.meters.first.name,
                                 school.meters.first.first_validated_reading.iso8601,
                                 school.meters.first.last_validated_reading.iso8601
                               ]])
          end
        end

        context 'when school is not data enabled' do
          let(:data_enabled) { false }

          it 'does not include meters for school' do
            expect(rows).to be_empty
          end
        end
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      context 'when producing rows' do
        subject(:rows) { CSV.parse(service.export.lines[1..].join) }

        it 'produces expected rows' do
          expect(rows).to eq([[
                               school.school_group.name,
                               school.name,
                               I18n.t(fuel_type, scope: 'common'),
                               school.meters.first.mpan_mprn.to_s,
                               school.meters.first.name,
                               school.meters.first.first_validated_reading.iso8601,
                               school.meters.first.last_validated_reading.iso8601
                             ]])
        end
      end
    end
  end
end
