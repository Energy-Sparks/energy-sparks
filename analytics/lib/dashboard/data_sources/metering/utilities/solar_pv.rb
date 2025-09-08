class SolarPV < HalfHourlyData
  def initialize(type)
    super(type)
  end

  def solar_pv_yield(date, half_hour_index)
    data(date, half_hour_index)
  end
end

# simple model for a school's panel capacity, supports
# phased installation of groups of panels
# querying for capacity is always by date, so the given capacity of a date
# calculates panel degredation, fixed at 0.5% per year
# doesn't support panel retirement, orientation, aspect and shading
class SolarPVInstallation
  PANEL_DEGREDATION = 0.005 # 0.5% per year from install date
  class SolarPVPanelSet
    attr_reader :installation_date, :kwp, :tilt, :orientation, :shading
    def initialize(installation_date, kwp, tilt, orientation, shading)
      @installation_date = installation_date
      @kwp = kwp
      @tilt = tilt
      @orientation = orientation
      @shading = shading
    end

    def to_s
      installation_date.strftime('%Y-%m-%d') + ': ' + kwp.round(1) + ' kWp'
    end
  end

  def initialize
    @sets_of_panels = []
  end

  def add_panels(solar_panel_set)
    @sets_of_panels.push(solar_panel_set)
  end

  def capacity_kwp_on_date(date)
    total_capacity_kwp = 0.0
    @sets_of_panels.each do |solar_panel_set|
      if date >= solar_panel_set.installation_date
        factor = (1.0 - solar_panel_set.shading) * degredation_factor(solar_panel_set.installation_date, date)
        total_capacity_kwp += solar_panel_set.kwp * factor
      end
    end
    total_capacity_kwp
  end

  def degredation_factor(installation_date, date)
    years = (date - installation_date) / 365.25
    (1 - PANEL_DEGREDATION)**years
  end
end

class SolarPVLoader < HalfHourlyLoader
  def initialize(csv_file, pv)
    super(csv_file, 0, 1, 0, pv)
  end
end
