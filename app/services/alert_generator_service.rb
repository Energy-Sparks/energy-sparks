require 'dashboard'

class AlertGeneratorService
  def initialize(school, analysis_date = Date.new(2018, 2, 2))
    @school = school
    @analysis_date = analysis_date
  end

  def perform
    return [] unless @school.alerts?
    @results = AlertType.all.map do |alert_type|
      alert = alert_type.class_name.constantize.new(aggregate_school)
      alert.analyse(@analysis_date)
      { report: alert.analysis_report, title: alert_type.title, description: alert_type.description }
    end
  end

  def generate_for_contacts
    return if @school.contacts.empty?
    @school.contacts.map do |contact|
      get_alerts(contact)
    end
  end

private

  def get_alerts(contact)
    contact.alerts.map do |alert|
      alert_type_class = alert.alert_type_class
      alert_object = alert_type_class.new(aggregate_school)
      alert_object.analyse(@analysis_date)
      { report: alert_object.analysis_report, title: alert.title, description: alert.description }
    end
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = MeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end
