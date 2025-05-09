require_relative '../utilities/solar_irradiance.rb'
class SolarIrradianceFromPV < SolarIrradiance
  # derived from comparitive analsysis of WU irradiance and ShefUniv data
  # TODO(PH, 22May2019) - one of the feeds seems to be out by GMT/BST
  #                     - refer to xomparison spreadsheets, but also need to adjust simulator lighting curves
  PV_TO_IRRADIANCE_SCALING_BY_MONTH = [
     650,  # Jan
     780,  # Feb
     937,  # Mar
    1050,  # Apr
    1140,  # May
    1190,  # June
    1190,  # Jul
    1100,  # Aug
     915,  # Sep
     815,  # Oct
     700,  # Nov
     585   # Dec
  ].freeze

  def initialize(type, solar_pv_data: nil)
    super(type, solar_pv_data: solar_pv_data)
  end

  protected def scaling_factor(date)
    scale_pv_to_irradiance_by_month(date)
  end

  private def scale_pv_to_irradiance_by_month(date)
    PV_TO_IRRADIANCE_SCALING_BY_MONTH[date.month - 1]
  end
end

