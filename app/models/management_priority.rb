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
    query = <<-SQL.squish
      SELECT a.school_id, a.id, cv.alert_type_rating_id, vars.average_one_year_saving_£, vars.one_year_saving_co2, vars.one_year_saving_kwh
      FROM management_priorities mp
      INNER JOIN alert_type_rating_content_versions cv ON mp.alert_type_rating_content_version_id = cv.id
      INNER JOIN alerts a ON mp.alert_id = a.id,
      JSON_TO_RECORD(a.template_data) AS vars(one_year_saving_kwh TEXT, one_year_saving_co2 TEXT, average_one_year_saving_£ TEXT)
      WHERE
        content_generation_run_id IN (
            SELECT c1.id FROM content_generation_runs c1
            LEFT OUTER JOIN content_generation_runs c2 ON c1.school_id = c2.school_id AND c1.created_at < c2.created_at
            WHERE
            c2.created_at IS NULL AND
            c1.school_id IN (#{schools.pluck(:id).join(',')})
        )
      ORDER BY a.school_id, a.id;
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
