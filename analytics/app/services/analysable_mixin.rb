# frozen_string_literal: true

# This module provides methods for a consistent interface across the analytics services classes. It's intended to be
# included and overridden where appropriate.
module AnalysableMixin
  # This method should return true or false if the service can run the analysis.
  # It should largely just check for data availability (e.g. whether there's a years worth of data) but some
  # implementations may also check whether we can construct a valid heating model.
  def enough_data?
    true
  end

  # This method should return an estimated Date when there ought to be enough data for the analysis (e.g. if the code
  # requires a years worth of data, then it should work out from the relevant amr_data when a year will be available).
  # If there is enough data, or the date can't be determined, or if there are other issues (e.g. we can't generate a model) then it should
  # return nil.
  def data_available_from
    nil
  end
end
