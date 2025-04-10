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

  def self.add_or_insert_message!(messageable, message)
    dashboard_message = messageable.dashboard_message
    if dashboard_message
      dashboard_message.update!(message: "#{message} #{dashboard_message.message}")
    else
      DashboardMessage.create!(messageable: messageable, message: message)
    end
  end

  def self.delete_or_remove_message!(messageable, message)
    dashboard_message = messageable.dashboard_message
    return unless dashboard_message
    if dashboard_message.message == message
      dashboard_message.destroy!
    else
      updated = dashboard_message.message.gsub("#{message} ", '')
      dashboard_message.update!(message: updated)
    end
  end
end
