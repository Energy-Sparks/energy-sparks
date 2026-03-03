# == Schema Information
#
# Table name: management_priorities
#
#  alert_id                             :bigint(8)        not null
#  alert_type_rating_content_version_id :bigint(8)        not null
#  content_generation_run_id            :bigint(8)        not null
#  created_at                           :datetime         not null
#  find_out_more_id                     :bigint(8)
#  id                                   :bigint(8)        not null, primary key
#  priority                             :decimal(, )      default(0.0), not null
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_management_priorities_on_alert_id                   (alert_id)
#  index_management_priorities_on_content_generation_run_id  (content_generation_run_id)
#  index_management_priorities_on_find_out_more_id           (find_out_more_id)
#  mp_altrcv                                                 (alert_type_rating_content_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => restrict
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (find_out_more_id => find_out_mores.id) ON DELETE => nullify
#

class ManagementPriority < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :find_out_more, optional: true
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  validates :priority, numericality: true

  scope :by_priority, -> { order(priority: :desc) }
  # priorities that don't involve capital investment
  scope :without_investment, -> do
    joins(:alert, alert: :alert_type).where.not(alert_type: { class_name: ['AlertSolarPVBenefitEstimator', 'AlertHotWaterInsulationAdvice'] })
  end


  # Returns an Array of OpenStruct
  def self.for_schools(schools)
    query = <<~SQL.squish
      WITH latest_runs AS (
        SELECT DISTINCT ON (school_id) id
        FROM content_generation_runs
        WHERE school_id IN (#{schools.pluck(:id).join(',')})
        ORDER BY school_id, created_at DESC
      )
      SELECT
        alerts.school_id,
        alerts.id,
        alert_type_rating_content_versions.alert_type_rating_id,
        vars.average_one_year_saving_£,
        vars.one_year_saving_co2,
        vars.one_year_saving_kwh
      FROM management_priorities
      JOIN alert_type_rating_content_versions
        ON management_priorities.alert_type_rating_content_version_id = alert_type_rating_content_versions.id
      JOIN alerts
        ON management_priorities.alert_id = alerts.id
      JOIN latest_runs
        ON management_priorities.content_generation_run_id = latest_runs.id
      JOIN LATERAL (
        SELECT *
        FROM JSON_TO_RECORD(alerts.template_data) AS vars(
          one_year_saving_kwh TEXT,
          one_year_saving_co2 TEXT,
          average_one_year_saving_£ TEXT
        )
        WHERE vars.average_one_year_saving_£ IS NOT NULL
          AND vars.one_year_saving_co2 IS NOT NULL
          AND vars.one_year_saving_kwh IS NOT NULL
      ) AS vars ON TRUE
      ORDER BY alerts.school_id, alerts.id;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    ManagementPriority.connection.select_all(sanitized_query).rows.map do |row|
      OpenStruct.new(
        school_id: row[0],
        alert_id: row[1],
        alert_type_rating_id: row[2],
        average_one_year_saving_gbp: row[3],
        one_year_saving_co2: row[4],
        one_year_saving_kwh: row[5]
      )
    end
  end
end
