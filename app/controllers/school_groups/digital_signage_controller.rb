module SchoolGroups
  class DigitalSignageController < BaseController
    before_action :redirect_unless_authorised

    def index
      build_breadcrumbs([{ name: I18n.t('manage_school_menu.digital_signage') }])
    end

    def charts
      send_data charts_csv, filename: csv_filename_for(:charts)
    end

    def equivalences
      send_data equivalences_csv, filename: csv_filename_for(:equivalences)
    end

    private

    def required_permission
      :view_digital_signage
    end

    def csv_filename_for(link_type)
      title = I18n.t("pupils.digital_signage.index.school_group.links.#{link_type}")
      "#{@school_group.name}-#{title}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
    end

    def equivalences_csv
      CSV.generate do |csv|
        csv << [
          t('common.school'),
          t('advice_pages.index.priorities.table.columns.fuel_type'),
          t('pupils.digital_signage.table.columns.link')
        ]
        schools.each do |school|
          if school.has_electricity?
            csv << [
              school.name,
              t('common.electricity'),
              pupils_school_digital_signage_equivalences_url(school, :electricity)
            ]
          end
          next unless school.has_gas?

          csv << [
            school.name,
            t('common.gas'),
            pupils_school_digital_signage_equivalences_url(school, :gas)
          ]
        end
      end
    end

    def charts_csv
      CSV.generate do |csv|
        csv << [
          t('common.school'),
          t('advice_pages.index.priorities.table.columns.fuel_type'),
          t('pupils.digital_signage.table.columns.chart_type'),
          t('pupils.digital_signage.table.columns.description'),
          t('pupils.digital_signage.table.columns.link')
        ]
        schools.each do |school|
          if school.has_electricity?
            Pupils::DigitalSignageController::CHART_TYPES.each do |chart_type|
              csv << [
                school.name,
                t('common.electricity'),
                t("pupils.digital_signage.index.charts.#{chart_type}.title"),
                t("pupils.digital_signage.index.charts.#{chart_type}.description"),
                pupils_school_digital_signage_charts_url(school, :electricity, chart_type)
              ]
            end
          end
          next unless school.has_gas?

          Pupils::DigitalSignageController::CHART_TYPES.each do |chart_type|
            csv << [
              school.name,
              t('common.gas'),
              t("pupils.digital_signage.index.charts.#{chart_type}.title"),
              t("pupils.digital_signage.index.charts.#{chart_type}.description"),
              pupils_school_digital_signage_charts_url(school, :gas, chart_type)
            ]
          end
        end
      end
    end

    def schools
      @school_group.assigned_schools.active.data_enabled.where(data_sharing: :public).order(:name)
    end
  end
end
