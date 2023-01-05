# == Schema Information
#
# Table name: advice_pages
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  key        :string           not null
#  restricted :boolean          default(FALSE)
#  updated_at :datetime         not null
#
# Indexes
#
#  index_advice_pages_on_key  (key) UNIQUE
#
class AdvicePage < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  translates :learn_more, backend: :action_text
end
