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

    include Enums::Country

    translates :name, type: :string, fallbacks: { cy: :en }
    validates :name, presence: true, uniqueness: { scope: :country }
  end
end
