# == Schema Information
#
# Table name: videos
#
#  created_at  :datetime         not null
#  description :text
#  featured    :boolean          default(TRUE), not null
#  id          :bigint(8)        not null, primary key
#  position    :integer          default(1), not null
#  title       :text             not null
#  updated_at  :datetime         not null
#  youtube_id  :text             not null
#
class Video < ApplicationRecord
  validates_presence_of :youtube_id, :title, :position
  validates_uniqueness_of :youtube_id

  scope :featured, -> { where(featured: true) }

  def embed_url
    "https://www.youtube.com/embed/#{youtube_id}"
  end
end
