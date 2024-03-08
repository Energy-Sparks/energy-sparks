# Base class for comparison tables that are defined as
# Postgres database views using the Scenic gem
#
# Views should define an id column which will be unique for
# all records. This would normally be the id of the latest
# alert_generation_run for a school.
class Comparison::View < ApplicationRecord
  self.abstract_class = true
  self.primary_key = :id

  belongs_to :school

  # E.g. previous_year, current_year
  scope :by_percentage_change, ->(base, new_val) do
    order(Arel.sql("(NULLIF(#{new_val},0.0) - NULLIF(#{base},0.0)) / NULLIF(#{base},0.0) DESC NULLS FIRST"))
  end

  def readonly?
    true
  end
end
