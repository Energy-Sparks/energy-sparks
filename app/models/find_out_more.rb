# == Schema Information
#
# Table name: find_out_mores
#
#  alert_id                              :bigint(8)        not null
#  created_at                            :datetime         not null
#  find_out_more_type_content_version_id :bigint(8)        not null
#  id                                    :bigint(8)        not null, primary key
#  updated_at                            :datetime         not null
#
# Indexes
#
#  fom_fom_content_v_id              (find_out_more_type_content_version_id)
#  index_find_out_mores_on_alert_id  (alert_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (find_out_more_type_content_version_id => find_out_more_type_content_versions.id) ON DELETE => cascade
#

class FindOutMore < ApplicationRecord
  belongs_to :alert
  belongs_to :content_version, class_name: 'FindOutMoreTypeContentVersion', foreign_key: :find_out_more_type_content_version_id

  def self.latest
    select('DISTINCT ON (alert_type_id) alerts.alert_type_id AS alert_type_id, find_out_mores.*').
      joins(:alert).
      order('alerts.alert_type_id', created_at: :desc)
  end
end
