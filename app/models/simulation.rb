# == Schema Information
#
# Table name: simulations
#
#  configuration :text
#  created_at    :datetime         not null
#  default       :boolean
#  id            :bigint(8)        not null, primary key
#  notes         :text
#  school_id     :bigint(8)        not null
#  title         :text
#  updated_at    :datetime         not null
#  user_id       :bigint(8)        not null
#
# Indexes
#
#  index_simulations_on_school_id  (school_id)
#  index_simulations_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#

class Simulation < ApplicationRecord
  belongs_to :school
  belongs_to :user
  serialize :configuration
end
