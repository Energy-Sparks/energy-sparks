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

  def readonly?
    true
  end
end
