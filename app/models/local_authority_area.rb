# == Schema Information
#
# Table name: local_authority_areas
#
#  code       :string
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string
#  updated_at :datetime         not null
#
class LocalAuthorityArea < ApplicationRecord
  validates :code, :name, presence: true
  validates :code, uniqueness: true

  has_many :schools
end
