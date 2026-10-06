# frozen_string_literal: true

# == Schema Information
#
# Table name: actions_focuses
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Actions
  class Focus < ApplicationRecord
    self.table_name = 'actions_focuses'

    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
