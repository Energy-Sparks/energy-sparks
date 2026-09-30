# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks_aims
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Tasks
  class Aim < ApplicationRecord
    self.table_name = 'tasks_aims'

    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
