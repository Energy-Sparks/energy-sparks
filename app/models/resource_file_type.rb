# == Schema Information
#
# Table name: resource_file_types
#
#  id         :bigint           not null, primary key
#  position   :integer          not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ResourceFileType < ApplicationRecord
  has_many :resource_files

  validates :title, :position, presence: true
  validates :position, numericality: true
end
