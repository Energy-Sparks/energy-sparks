# frozen_string_literal: true

# Base class for comparison tables that are defined as
# Postgres database views using the Scenic gem
#
# Views should define an id column which will be unique for
# all records. This would normally be the id of the latest
# alert_generation_run for a school.
module Comparison
  class View < ApplicationRecord
    self.abstract_class = true
    self.primary_key = :id
    self.table_name_prefix = 'comparison_'

    belongs_to :school

    scope :with_school, -> { includes(:school) }
    # add to query when using school configuration in tables to optimise loading
    # of School::Configuration
    scope :with_school_configuration, -> { includes(school: :configuration) }
    scope :for_schools, ->(schools) { where(school: schools).with_school }

    # Orders results by percentage change across a period. E.g.
    # :previous_year_electricity_kwh, :current_year_electricity_kwh
    #
    # +base_value_field+ should be the previous period, e.g. % change from this base
    # +new_value_field+ should be the current period
    scope :by_percentage_change, lambda { |base_value_field, new_value_field|
      null_if_base_value = "NULLIF(#{base_value_field},0.0)"
      null_if_new_value = "NULLIF(#{new_value_field},0.0)"
      order(
        Arel.sql(
          sanitize_sql_array("(#{null_if_new_value} - #{null_if_base_value}) / #{null_if_base_value} DESC NULLS FIRST")
        )
      )
    }

    # Orders the results by a percentage change value that is calculated from
    # summing together multiple attributes.
    #
    # +base_value_fields+ are the fields to be summed to create the base value, e.g. % change from
    # +new_value_fields+ are the fields to be summed for the current period
    #
    # The order by clause uses COALESCE to convert nil values for an field to zero
    # (e.g. if a school doesn't have gas or storage heaters)
    #
    # NULLIF is then used to convert a total of 0.0 for a set of fields to NULL, so the order value becomes NULL.
    # This avoids divide by zero errors in the calculations. We then sort NULLs last
    scope :by_percentage_change_across_fields, lambda { |base_value_fields, new_value_fields|
      null_if_base_values = Comparison::View.fields_total_with_zero_as_null(base_value_fields)
      null_if_new_values = Comparison::View.fields_total_with_zero_as_null(new_value_fields)
      order(
        Arel.sql(
          sanitize_sql_array(
            "(#{null_if_new_values} - #{null_if_base_values}) / #{null_if_base_values} ASC NULLS LAST"
          )
        )
      )
    }

    # Orders by the total of a number of columns. If the column is nil then its treated as zero
    scope :by_total, lambda { |columns, direction = 'ASC NULLS LAST'|
      order(
        Arel.sql(
          sanitize_sql_array(columns.map { |c| "COALESCE(#{c}, 0.0)" }.join('+') + ' ' + direction)
        )
      )
    }

    # Restricts results to rows that have values in any of the provided columns
    scope :where_any_present, lambda { |columns|
      where(Arel.sql(sanitize_sql_array(columns.map { |c| "#{c} IS NOT NULL" }.join(' OR '))))
    }

    scope :without_swimming_pool, -> { joins(:school).where({ school: { has_swimming_pool: false } }) }

    def self.fields_total_with_zero_as_null(fields)
      "NULLIF(#{fields.map { |v| "COALESCE(#{v}, 0.0)" }.join(' + ')}, 0.0)"
    end

    def readonly?
      true
    end

    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    end
  end
end
