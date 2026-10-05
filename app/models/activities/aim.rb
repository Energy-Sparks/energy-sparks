# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_aims
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Activities
  class Aim < ApplicationRecord
    self.table_name = 'activities_aims'

    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
