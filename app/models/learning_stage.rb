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

  include Deletable
  include Enums::Country

  # Currently we have school_key_stages and activity_type_key_stages
  # So need to look at replacing / supporting these

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :abbreviation, type: :string, fallbacks: { cy: :en }
  validates :country, presence: true
  validates :name, presence: true, uniqueness: { scope: :country }
  validates :abbreviation, presence: true, uniqueness: { scope: :country }

  scope :by_name, -> { i18n.order(name: :asc) }

  has_many :activity_type_learning_stages, class_name: 'Activities::ActivityTypeLearningStage',
                                           inverse_of: :learning_stage, dependent: :destroy
  has_many :activity_types, through: :activity_type_learning_stages

  def deletable?
    activity_type_learning_stages.empty?
  end

  private

  def destroy_error_message
    'This learning stage is used by activity types and cannot be deleted'
  end
end
