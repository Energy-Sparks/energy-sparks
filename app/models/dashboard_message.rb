# == Schema Information
#
# Table name: dashboard_messages
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  message    :text
#  updated_at :datetime         not null
#
class DashboardMessage < ApplicationRecord
  has_one :school_group, dependent: :nullify
end
