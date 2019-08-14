# == Schema Information
#
# Table name: site_settings
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  message_for_no_contacts :boolean          default(TRUE)
#  updated_at              :datetime         not null
#

class SiteSettings < ApplicationRecord
  def self.current
    order('created_at DESC').first || new
  end
end
