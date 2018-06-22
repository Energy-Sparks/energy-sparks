class ReportsController < AdminController
  def index
  end

  def amr_data_index
    @meters = Meter.where(active: true).includes(:school).order('schools.name')
  end

  def amr_data_show
    @meter = Meter.includes(:meter_readings).find(params[:meter_id])
    @first_reading = @meter.first_reading
    @reading_summary = @meter.meter_readings.order(Arel.sql('read_at::date')).group('read_at::date').count
    @missing_array = (@first_reading.read_at.to_date..Date.today).collect do |day|
      if ! @reading_summary.key?(day)
        [ day, 'No readings' ]
      elsif @reading_summary.key?(day) && @reading_summary[day] < 48
        [ day, 'Partial readings' ]
      end
    end.reject! { |c| c.blank? }
  end

  def loading
    @schools = School.enrolled.order(:name)
  end
end
