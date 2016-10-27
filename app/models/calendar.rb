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
  has_many :terms, inverse_of: :calendar, dependent: :destroy

  default_scope { where(deleted: false) }
  validates_presence_of :name
  accepts_nested_attributes_for(
    :terms,
    reject_if: :term_attributes_blank?,
    allow_destroy: true
  )

private

  def term_attributes_blank?(attributes)
    attributes[:name].blank? && attributes[:start_date].blank? && attributes[:end_date].blank?
  end
end
