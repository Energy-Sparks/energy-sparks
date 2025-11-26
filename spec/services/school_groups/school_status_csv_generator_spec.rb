require 'rails_helper'

RSpec.describe SchoolGroups::SchoolStatusCsvGenerator do
  around do |example|
    travel_to Date.new(2025, 9, 26)
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  let(:school_group) { create(:school_group) }
  let(:school_group_cluster) { create(:school_group_cluster, school_group:) }

  let!(:school) do
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           fuel_type: fuel_type,
           visible: true,
           data_enabled: true,
           number_of_pupils: 20,
           floor_area: 300.0,
           school_group:,
           school_group_cluster:)
  end

  let!(:service) { described_class.new(school_group:, schools: [school], include_cluster: false) }

  describe '#export' do
    context 'with electricity and solar' do
      let(:fuel_type) { :electricity }

      before do
        create(:solar_pv_attribute, meter: school.meters.first, end_date: Date.current)
        meter_collection = AggregateSchoolService.new(school).aggregate_school
        Schools::GenerateConfiguration.new(school, meter_collection).generate
      end

      context 'when generating headers' do
        subject(:headers) { CSV.parse(service.export.lines[0]) }

        it 'produces correct headers' do
          expect(headers).to eq([[
                                  I18n.t('common.school'),
                                  I18n.t('common.labels.status'),
                                  I18n.t('common.labels.onboarded_date'),
                                  I18n.t('common.labels.data_published_date'),
                                  I18n.t('common.electricity'),
                                  I18n.t('common.gas'),
                                  I18n.t('common.storage_heaters'),
                                  I18n.t('common.solar_pv'),
                                  School.human_attribute_name('number_of_pupils'),
                                  I18n.t('school_groups.labels.floor_area'),
                                  I18n.t('common.electricity') + ' ' + I18n.t(:start_date, scope: 'common.labels'),
                                  I18n.t('common.electricity') + ' ' + I18n.t(:end_date, scope: 'common.labels')
                                ]])
        end
      end

      context 'when generating data' do
        subject(:rows) { CSV.parse(service.export.lines[1..].join) }

        it 'produces expected rows' do
          expect(rows).to eq([[
                               school.name,
                               I18n.t('schools.status.data_enabled'),
                               nil,
                               nil,
                               'Y',
                               'N',
                               'N',
                               'Y',
                               school.number_of_pupils.to_s,
                               school.floor_area.to_s,
                               '2024-09-26',
                               '2025-09-26'
                             ]])
        end

        context 'when including clusters' do
          let!(:service) { described_class.new(school_group:, schools: [school], include_cluster: true) }

          context 'when generating headers' do
            subject(:headers) { CSV.parse(service.export.lines[0]) }

            it 'produces correct headers' do
              expect(headers).to eq([[
                                      I18n.t('common.school'),
                                      I18n.t('common.labels.status'),
                                      I18n.t('school_groups.clusters.labels.cluster'),
                                      I18n.t('common.labels.onboarded_date'),
                                      I18n.t('common.labels.data_published_date'),
                                      I18n.t('common.electricity'),
                                      I18n.t('common.gas'),
                                      I18n.t('common.storage_heaters'),
                                      I18n.t('common.solar_pv'),
                                      School.human_attribute_name('number_of_pupils'),
                                      I18n.t('school_groups.labels.floor_area'),
                                      I18n.t('common.electricity') + ' ' + I18n.t(:start_date, scope: 'common.labels'),
                                      I18n.t('common.electricity') + ' ' + I18n.t(:end_date, scope: 'common.labels')
                                    ]])
            end
          end

          it 'produces expected rows' do
            expect(rows).to eq([[
                                 school.name,
                                 I18n.t('common.labels.data_published'),
                                 school_group_cluster.name,
                                 nil,
                                 nil,
                                 'Y',
                                 'N',
                                 'N',
                                 'Y',
                                 school.number_of_pupils.to_s,
                                 school.floor_area.to_s,
                                 '2024-09-26',
                                 '2025-09-26'
                               ]])
          end
        end

        context 'when there are onboarding events' do
          before do
            create(:school_onboarding, :with_events, school:, school_group:, event_names: [:onboarding_complete, :onboarding_data_enabled])
          end

          it 'produces expected rows' do
            expect(rows).to eq([[
                                 school.name,
                                 I18n.t('common.labels.data_published'),
                                 Date.current.iso8601,
                                 Date.current.iso8601,
                                 'Y',
                                 'N',
                                 'N',
                                 'Y',
                                 school.number_of_pupils.to_s,
                                 school.floor_area.to_s,
                                 '2024-09-26',
                                 '2025-09-26'
                               ]])
          end
        end
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      before do
        meter_collection = AggregateSchoolService.new(school).aggregate_school
        Schools::GenerateConfiguration.new(school, meter_collection).generate
      end

      context 'when generating headers' do
        subject(:headers) { CSV.parse(service.export.lines[0]) }

        it 'produces correct headers' do
          expect(headers).to eq([[
                                  I18n.t('common.school'),
                                  I18n.t('common.labels.status'),
                                  I18n.t('common.labels.onboarded_date'),
                                  I18n.t('common.labels.data_published_date'),
                                  I18n.t('common.electricity'),
                                  I18n.t('common.gas'),
                                  I18n.t('common.storage_heaters'),
                                  I18n.t('common.solar_pv'),
                                  School.human_attribute_name('number_of_pupils'),
                                  I18n.t('school_groups.labels.floor_area'),
                                  I18n.t('common.gas') + ' ' + I18n.t(:start_date, scope: 'common.labels'),
                                  I18n.t('common.gas') + ' ' + I18n.t(:end_date, scope: 'common.labels')
                                ]])
        end
      end

      context 'when generating data' do
        subject(:rows) { CSV.parse(service.export.lines[1..].join) }

        it 'produces expected rows' do
          expect(rows).to eq([[
                               school.name,
                               I18n.t('common.labels.data_published'),
                               nil,
                               nil,
                               'N',
                               'Y',
                               'N',
                               'N',
                               school.number_of_pupils.to_s,
                               school.floor_area.to_s,
                               '2024-09-26',
                               '2025-09-26'
                             ]])
        end
      end
    end
  end
end
