class AMRLoader < HalfHourlyLoader
  def initialize(csv_file, amrdata)
    super(csv_file, 2, 3, 0, amrdata)
  end
end