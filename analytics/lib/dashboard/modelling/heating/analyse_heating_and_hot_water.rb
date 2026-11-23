# Analyse heating, hot water and kitchen
# FYI: some abiguity in use of terms may confuse:
#   summer - equivalent to - non_heating, kitchen_only, hotwater_only
#   winter - equivalent to - heating
#
module AnalyseHeatingAndHotWater
  # both these constants are 'publicly' documented on the model fitting advice web pages
  MINIMUM_NON_HEATING_MODEL_SAMPLES = 15
  MINIMUM_SAMPLES_FOR_SIMPLE_MODEL_TO_RUN_WELL = 35
  MINIMUM_SAMPLES_FOR_THERMALLY_MASSIVE_MODEL_TO_RUN_WELL = 60
end
