# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_subject_areas
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
module Activities
  class SubjectArea < ApplicationRecord
    self.table_name = 'activities_subject_areas'
    extend Mobility

    include Deletable
    include Enums::Country

    translates :name, type: :string, fallbacks: { cy: :en }
    validates :country, presence: true
    validates :name, presence: true, uniqueness: { scope: :country }

    has_many :activity_type_subject_areas,
             class_name: 'Activities::ActivityTypeSubjectArea',
             inverse_of: :subject_area,
             dependent: :destroy
    has_many :activity_types, through: :activity_type_subject_areas

    scope :by_name, -> { i18n.order(name: :asc) }

    def deletable?
      activity_type_subject_areas.empty?
    end

    private

    def destroy_error_message
      'This subject area is used by activity types and cannot be deleted'
    end
  end
end
