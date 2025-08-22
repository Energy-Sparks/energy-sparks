module SchoolGroups
  class Alerts
    def initialize(schools)
      @schools = schools
    end

    def summarise
      summarised_alerts.reject do |alert|
        content = alert.alert_type_rating.current_content

        !content.meets_timings?(scope: :group_dashboard_alert, today: Time.zone.today) ||
          [alert.total_one_year_saving_kwh,
           alert.total_average_one_year_saving_gbp,
           alert.total_one_year_saving_co2].any?(&:nil?)
      end
    end

    private

    # Fetch list of summarised alerts from database, then select one per alert_type based on the largest number of
    # schools that have triggered that alert.
    #
    # Could refine this, e.g. if there is a small number of outliers, then include that alert as well to promote
    # investigation.
    def summarised_alerts
      Alert.summarised_alerts(schools: @schools)
           .group_by(&:alert_type)
           .map { |_, alerts| alerts.max_by(&:number_of_schools) }.to_a
    end
  end
end
