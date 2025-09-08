# == Schema Information
#
# Table name: resource_files
#
#  created_at            :datetime         not null
#  id                    :bigint(8)        not null, primary key
#  resource_file_type_id :bigint(8)
#  title                 :string           not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_resource_files_on_resource_file_type_id  (resource_file_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (resource_file_type_id => resource_file_types.id) ON DELETE => restrict
#

class ResourceFile < ApplicationRecord
  belongs_to :resource_file_type, optional: true
  has_one_attached :file
  has_rich_text :description

  validates :title, :file, presence: true

  def self.user_guide_download_path
    user_guide = find_by(title: 'Energy Sparks User Guide')
    return Rails.application.routes.url_helpers.resources_path unless user_guide
    Rails.application.routes.url_helpers.resource_file_download_path(user_guide, :download)
  end
end
