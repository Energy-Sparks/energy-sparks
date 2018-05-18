# == Schema Information
#
# Table name: bank_holidays
#
#  area_id      :bigint(8)
#  holiday_date :date
#  id           :bigint(8)        not null, primary key
#  notes        :text
#  title        :text
#
# Indexes
#
#  index_bank_holidays_on_area_id  (area_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_id => areas.id)
#

class BankHoliday < ApplicationRecord
  belongs_to :group
end
