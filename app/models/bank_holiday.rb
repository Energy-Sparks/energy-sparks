# == Schema Information
#
# Table name: bank_holidays
#
#  group_id     :bigint(8)
#  holiday_date :date
#  id           :bigint(8)        not null, primary key
#  notes        :text
#  title        :text
#
# Indexes
#
#  index_bank_holidays_on_group_id  (group_id)
#

class BankHoliday < ApplicationRecord
  belongs_to :group
end
