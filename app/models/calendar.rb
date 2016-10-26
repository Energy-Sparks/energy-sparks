# == Schema Information
#
# Table name: calendars
#
#  created_at :datetime         not null
#  deleted    :boolean          default(FALSE)
#  id         :integer          not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#

class Calendar < ApplicationRecord
  default_scope { where(deleted: false) }
  validates_presence_of :name
end
