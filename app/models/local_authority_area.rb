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
  validates_presence_of :code, :name
  validates_uniqueness_of :code

  has_many :schools
end
