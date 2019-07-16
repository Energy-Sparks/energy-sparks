# frozen_string_literal: true

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
  has_many :find_out_mores
  has_many :dashboard_alerts
  has_many :alert_subscription_events
  belongs_to :school
end
