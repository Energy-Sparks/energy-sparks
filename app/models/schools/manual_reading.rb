# frozen_string_literal: true

module Schools
  class ManualReading < ApplicationRecord
    def self.table_name_prefix
      'schools_'
    end

    belongs_to :school
    validates :month, presence: true, format: { with: ->(record) { record.month&.day == 1 },
                                                message: 'must be the first day of the month' }
    validates :electricity, presence: true, unless: :gas?
    validates :gas, presence: true, unless: :electricity?
    validates :electricity, numericality: { greater_than_or_equal_to: 0 }, if: :electricity?
    validates :gas, numericality: { greater_than_or_equal_to: 0 }, if: :gas?
  end
end
