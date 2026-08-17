# frozen_string_literal: true

# == Schema Information
#
# Table name: school_key_stages
#
#  key_stage_id :bigint(8)        not null
#  school_id    :bigint(8)        not null
#
# Indexes
#
#  index_school_key_stages_on_key_stage_id  (key_stage_id)
#  index_school_key_stages_on_school_id     (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (key_stage_id => key_stages.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SchoolKeyStage < ApplicationRecord
  belongs_to :school
  belongs_to :key_stage
end
