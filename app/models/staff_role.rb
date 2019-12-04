# == Schema Information
#
# Table name: staff_roles
#
#  created_at :datetime         not null
#  dashboard  :integer          default("management"), not null
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  updated_at :datetime         not null
#

class StaffRole < ApplicationRecord
  has_many :users

  enum dashboard: [:management, :teachers]

  def as_symbol
    title.parameterize.underscore.to_sym
  end
end
