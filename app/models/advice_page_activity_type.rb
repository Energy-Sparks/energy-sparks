# == Schema Information
#
# Table name: advice_page_activity_types
#
#  activity_type_id :bigint(8)
#  advice_page_id   :bigint(8)
#  id               :bigint(8)        not null, primary key
#  position         :integer
#
# Indexes
#
#  index_advice_page_activity_types_on_activity_type_id  (activity_type_id)
#  index_advice_page_activity_types_on_advice_page_id    (advice_page_id)
#
class AdvicePageActivityType < ApplicationRecord
  belongs_to :advice_page
  belongs_to :activity_type

  validates :activity_type, :advice_page, presence: true
end
