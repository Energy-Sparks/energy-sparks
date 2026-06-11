# frozen_string_literal: true

class RemoveFootnoteFromMetricCategory < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      ALTER TYPE impact_report_metric_categories
      RENAME TO impact_report_metric_categories_old;
    SQL

    create_enum :impact_report_metric_categories, %w[
      overview
      energy_efficiency
      engagement
      potential_savings
    ]

    change_column :impact_report_metrics, :metric_category, :enum,
                  enum_type: :impact_report_metric_categories,
                  using: 'metric_category::text::impact_report_metric_categories'

    drop_enum :impact_report_metric_categories_old
  end

  def down
    add_enum_value :impact_report_metric_categories, 'footnotes'
  end
end
