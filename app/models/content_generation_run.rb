# == Schema Information
#
# Table name: content_generation_runs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_content_generation_runs_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class ContentGenerationRun < ApplicationRecord
  has_many :dashboard_alerts, dependent: :delete_all
  has_many :find_out_mores, dependent: :delete_all
  has_many :management_priorities, dependent: :delete_all
  has_many :management_dashboard_tables, dependent: :delete_all

  has_many :find_out_more_content_versions, through: :find_out_mores, source: :content_version
  has_many :find_out_more_alert_type_ratings, through: :find_out_more_content_versions, source: :alert_type_rating
  has_many :find_out_more_activity_types, through: :find_out_more_alert_type_ratings, source: :activity_types
  has_many :find_out_more_intervention_types, through: :find_out_more_alert_type_ratings, source: :intervention_types

  belongs_to :school
end
