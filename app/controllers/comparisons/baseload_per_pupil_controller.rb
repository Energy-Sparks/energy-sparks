module Comparisons
  class BaseloadPerPupilController < BaseController
    private

    def definition
      Comparison::ReportDefinition.new(
        report_key: :baseload_per_pupil,
        advice_page: AdvicePage.find_by_key(:baseload),
        schools: @schools,
        metric_type_keys: [:one_year_baseload_per_pupil_kw, :average_baseload_last_year_gbp, :average_baseload_last_year_kw, :annual_baseload_percent, :one_year_saving_versus_exemplar_gbp, :electricity_economic_tariff_changed_this_year],
        order_key: :one_year_baseload_per_pupil_kw,
        alert_types: AlertType.where(class_name: %w[AlertElectricityBaseloadVersusBenchmark AlertAdditionalPrioritisationData]),
        fuel_types: :electricity,
      )
    end
  end
end
