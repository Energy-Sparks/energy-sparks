# == Schema Information
#
# Table name: bank_holidays
#
#  calendar_area_id :integer
#  holiday_date     :date
#  id               :bigint(8)        not null, primary key
#  notes            :text
#  title            :text
#
# Indexes
#
#  index_bank_holidays_on_calendar_area_id  (calendar_area_id)
#

class BankHoliday < ApplicationRecord
  belongs_to :calendar_area
end
