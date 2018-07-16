# == Schema Information
#
# Table name: simulators
#
#  configuration :text
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  notes         :text
#  school_id     :bigint(8)
#  title         :text
#  updated_at    :datetime         not null
#  user_id       :bigint(8)
#
# Indexes
#
#  index_simulators_on_school_id  (school_id)
#  index_simulators_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#

class Simulator < ApplicationRecord
  belongs_to :school
  belongs_to :user
  serialize :configuration
end
