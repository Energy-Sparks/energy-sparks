# Interprets :estimated_period_consumption meter attribute
# estimate of meter kWh consumption in absence of 1/2 hourly readings
# typically used by targeting and tracking system for setting
# targets where there is < 1 year of half hourly data
class EstimatePeriodConsumption
  def initialize(attributes)
    @attributes = attributes
  end

  def annual_kwh
    @annual_kwh ||= calculate_annual_kwh
  end

  private

  def calculate_annual_kwh(end_date = nil)
    return Float::NAN if @attributes.nil? || @attributes.empty?

    reverse_sorted = @attributes.sort_by { |attribute| attribute[:start_date] }.reverse
    end_date = reverse_sorted.first[:end_date]
    start_date = end_date - 364

    days = 0
    kwh = 0.0

    reverse_sorted.each do |attribute|
      sd = [attribute[:start_date], start_date].max
      ed = [attribute[:end_date], end_date].min
      if sd <= ed
        period_days = (attribute[:end_date] - attribute[:start_date]).to_i
        overlap_days = (ed - sd).to_i
        overlap_kwh  = attribute[:kwh] * overlap_days / period_days
        kwh += overlap_kwh
        days += overlap_days
      end
    end
    kwh * 364 / days
  end
end
