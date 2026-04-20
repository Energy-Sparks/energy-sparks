# frozen_string_literal: true

# == Schema Information
#
# Table name: schools_manual_readings
#
#  id          :bigint(8)        not null, primary key
#  electricity :float
#  gas         :float
#  month       :date             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  school_id   :bigint(8)        not null
#
# Indexes
#
#  index_schools_manual_readings_on_school_id            (school_id)
#  index_schools_manual_readings_on_school_id_and_month  (school_id,month) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
module Schools
  class ManualReading < ApplicationRecord
    def self.table_name_prefix
      'schools_'
    end

    belongs_to :school
    validates :month, presence: true
    validates :electricity, presence: true, if: -> { gas.nil? }
    validates :gas, presence: true, if: -> { electricity.nil? }
    validates :electricity, numericality: { greater_than: 0 }, unless: -> { electricity.nil? }
    validates :gas, numericality: { greater_than: 0 }, unless: -> { gas.nil? }
    validate :start_of_month

    def start_of_month
      errors.add(:month, 'must be the first day of the month') unless month&.day == 1
    end
  end
end
