# == Schema Information
#
# Table name: dashboard_messages
#
#  created_at       :datetime         not null
#  id               :bigint(8)        not null, primary key
#  message          :text
#  messageable_id   :bigint(8)
#  messageable_type :string
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_dashboard_messages_on_messageable_type_and_messageable_id  (messageable_type,messageable_id) UNIQUE
#
class DashboardMessage < ApplicationRecord
  belongs_to :messageable, polymorphic: true

  validates :message, presence: true
end
