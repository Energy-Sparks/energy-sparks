# == Schema Information
#
# Table name: site_settings
#
#  created_at                            :datetime         not null
#  id                                    :bigint(8)        not null, primary key
#  management_priorities_dashboard_limit :integer          default(5)
#  management_priorities_page_limit      :integer          default(10)
#  message_for_no_contacts               :boolean          default(TRUE)
#  message_for_no_pupil_accounts         :boolean          default(TRUE)
#  updated_at                            :datetime         not null
#

class SiteSettings < ApplicationRecord
  def self.current
    order('created_at DESC').first || new
  end
end
