# == Schema Information
#
# Table name: terms
#
#  academic_year :string
#  calendar_id   :integer
#  created_at    :datetime         not null
#  end_date      :date             not null
#  id            :integer          not null, primary key
#  name          :string           not null
#  start_date    :date             not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_terms_on_calendar_id  (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => calendars.id)
#

class Term < ApplicationRecord
end
