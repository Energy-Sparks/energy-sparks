# frozen_string_literal: true

# == Schema Information
#
# Table name: activities_topics
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Activities
  class Topic < ApplicationRecord
    self.table_name = 'activities_topics'

    extend Mobility

    translates :name, type: :string, fallbacks: { cy: :en }
  end
end
