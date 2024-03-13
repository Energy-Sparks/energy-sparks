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

  scope :with_school, -> { includes(:school) }
  scope :for_schools, ->(schools) { where(school: schools).with_school }

  # E.g. previous_year, current_year
  scope :by_percentage_change, ->(base, new_val) do
    order(Arel.sql(sanitize_sql_array("(NULLIF(#{new_val},0.0) - NULLIF(#{base},0.0)) / NULLIF(#{base},0.0) DESC NULLS FIRST")))
  end

  scope :by_total, ->(columns) do
    order(Arel.sql(sanitize_sql_array(columns.map { |c| "COALESCE(#{c}, 0.0)" }.join('+'))))
  end

  scope :where_any_present, ->(columns) do
    where(Arel.sql(sanitize_sql_array(columns.map { |c| "#{c} IS NOT NULL" }.join(' OR '))))
  end

  def readonly?
    true
  end
end
