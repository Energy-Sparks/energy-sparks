class AMRLoadExcelRawData < HalfHourlyLoader
  def initialize(csv_file, amrdata)
    super(csv_file, 0, 1, 3, amrdata)
  end
end