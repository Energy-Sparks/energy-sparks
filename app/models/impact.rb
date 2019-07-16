# frozen_string_literal: true

# == Schema Information
#
# Table name: impacts
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#

class Impact < ApplicationRecord
  has_and_belongs_to_many :activity_types, join_table: :activity_type_impacts
end
