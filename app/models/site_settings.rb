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
#  temperature_recording_months          :jsonb
#  updated_at                            :datetime         not null
#

class SiteSettings < ApplicationRecord
  def self.current
    order('created_at DESC').first || new
  end

  def temperature_recording_month_numbers
    temperature_recording_months.reject(&:blank?).map(&:to_i)
  end
end
