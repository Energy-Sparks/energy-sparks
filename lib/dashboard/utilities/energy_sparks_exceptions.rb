class EnergySparksBadDataException < StandardError
  # def initialize(message)
  #   super.initialize(message)
  # end
end

class EnergySparksUnexpectedStateException < StandardError
end

class EnergySparksUnsupportedFunctionalityException < StandardError
end

class EnergySparksNotEnoughDataException < StandardError
end

class EnergySparksCalculationException < StandardError
end

class EnergySparksMeterDataTooOutOfDate < StandardError
end

class EnergySparksUnexpectedSchoolDataConfiguration < StandardError
end

class EnergySparksDeprecatedException < StandardError
end

class EnergySparksUnableToDetermineLatitudeLongitudeFromPostCode < StandardError
end

class EnergySparksBadAMRDataTypeException < StandardError
end

class EnergySparksAbstractBaseClass < NotImplementedError
end

class EnergySparksMissingPeriodForSpecifiedPeriodChart < StandardError
end

class EnergySparksNoMeterDataAvailableForFuelType < StandardError
end

class EnergySparksBadHolidayDataException < StandardError
end

class EnergySparksBadChartSpecification < StandardError
end

class EnergySparksMeterSpecification < StandardError
end

class EnergySparksChartNotRelevantForSchoolException < StandardError
end
