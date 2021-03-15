# == Schema Information
#
# Table name: consent_statements
#
#  created_at :datetime         not null
#  current    :boolean          default(FALSE)
#  id         :bigint(8)        not null, primary key
#  title      :text             not null
#  updated_at :datetime         not null
#
class ConsentStatement < ApplicationRecord
  has_many :consent_grants, inverse_of: :consent_statement
  has_rich_text :content

  validates :title, :content, presence: true

  scope :by_date, -> { order(created_at: :desc) }

  def self.current
    find_by(current: true)
  end

  def editable?
    consent_grants.empty?
  end
end
