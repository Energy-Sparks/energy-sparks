# == Schema Information
#
# Table name: alert_generation_runs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_alert_generation_runs_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class AlertGenerationRun < ApplicationRecord
  belongs_to :school
  has_many :alerts, dependent: :delete_all
  has_many :alert_errors, dependent: :delete_all
end
