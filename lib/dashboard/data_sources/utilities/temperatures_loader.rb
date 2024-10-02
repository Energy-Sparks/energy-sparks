class TemperaturesLoader < HalfHourlyLoader
  def initialize(csv_file, temperatures)
    # csv_file, date_column, data_start_column, header_rows, data
    super(csv_file, 0, 1, 0, temperatures)
  end
end
