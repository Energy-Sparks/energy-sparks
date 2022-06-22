# == Schema Information
#
# Table name: transifex_loads
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  pulled     :integer
#  pushed     :integer
#  updated_at :datetime         not null
#
class TransifexLoad < ApplicationRecord
  has_many :transifex_load_errors, :dependent => :destroy

  scope :by_date, -> { order(created_at: :desc) }

  def errors?
    transifex_load_errors.any?
  end
end
