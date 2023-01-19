class AdvicePageActivityType < ApplicationRecord
  belongs_to :advice_page
  belongs_to :activity_type

  validates :activity_type, :advice_page, presence: true
end
