# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_stages
#
#  id         :bigint(8)        not null, primary key
#  country    :enum             default("england"), not null, enum_type: country
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Enums
#
#  country  england, scotland, wales
#
class LearningStage < ApplicationRecord
  self.table_name = 'learning_stages'

  extend Mobility
  include Enums::Country

  # Currently we have school_key_stages and activity_type_key_stages
  # So need to look at replacing / supporting these, if this is what we would like to do

  # Eng: KS1 KS2 KS3 KS4 KS5
  # Wales: PS1 PS2 PS3 PS4 PS5
  # Scotland: 1st Level, 2nd Level, 3rd Level, 4th Level, Senior Phase

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :abbreviation, type: :string, fallbacks: { cy: :en }
  validates :name, presence: true, uniqueness: { scope: :country }
  validates :abbreviation, presence: true, uniqueness: { scope: :country }
end
