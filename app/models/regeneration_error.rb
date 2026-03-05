# frozen_string_literal: true

# == Schema Information
#
# Table name: regeneration_errors
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  message    :text
#  raised_at  :datetime
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
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
