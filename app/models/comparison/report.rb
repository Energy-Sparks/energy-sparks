class Comparison::Report < ApplicationRecord
  extend Mobility

  validates :key, presence: true, uniqueness: true
  validates :title, :fuel_type, presence: true

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :introduction, backend: :action_text
  translates :notes, backend: :action_text

  # These need deciding on. Add as needed?
  # [:last_12_months, :financial_year, :academic_year]
  enum reporting_period: { custom: 0 }

  belongs_to :custom_latest_period, class_name: 'Comparison::Period'
  belongs_to :custom_previous_period, class_name: 'Comparison::Period'

  has_rich_text :introduction
  has_rich_text :notes
end
