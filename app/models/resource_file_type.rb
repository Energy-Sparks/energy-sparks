# == Schema Information
#
# Table name: resource_file_types
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          not null
#  title      :string           not null
#  updated_at :datetime         not null
#

class ResourceFileType < ApplicationRecord
  has_many :resource_files

  validates :title, :position, presence: true
  validates :position, numericality: true
end
