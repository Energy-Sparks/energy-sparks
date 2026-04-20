# frozen_string_literal: true

# == Schema Information
#
# Table name: regeneration_errors
#
#  id         :bigint           not null, primary key
#  message    :text             not null
#  raised_at  :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint           not null
#
# Indexes
#
#  index_regeneration_errors_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class RegenerationError < ApplicationRecord
  belongs_to :school
end
