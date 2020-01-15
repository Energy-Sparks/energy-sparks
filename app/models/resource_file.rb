# == Schema Information
#
# Table name: resource_files
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  updated_at :datetime         not null
#

class ResourceFile < ApplicationRecord
  has_one_attached :file
  has_rich_text :description

  validates :title, :file, presence: true
end
