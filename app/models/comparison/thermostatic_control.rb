# == Schema Information
#
# Table name: thermostatic_controls
#
#  id                   :bigint(8)
#  potential_saving_gbp :float
#  r2                   :float
#  school_id            :bigint(8)
#
class Comparison::ThermostaticControl < Comparison::View
  scope :with_data, -> { where.not(r2: nil) }
  scope :sort_default, -> { order(r2: :desc) }
end
