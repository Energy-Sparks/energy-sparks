# == Schema Information
#
# Table name: issue_meters
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  issue_id   :bigint(8)
#  meter_id   :bigint(8)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_issue_meters_on_issue_id  (issue_id)
#  index_issue_meters_on_meter_id  (meter_id)
#
# Foreign Keys
#
#  fk_rails_...  (issue_id => issues.id)
#  fk_rails_...  (meter_id => meters.id)
#
class IssueMeter < ApplicationRecord
  belongs_to :issue
  belongs_to :meter
end
