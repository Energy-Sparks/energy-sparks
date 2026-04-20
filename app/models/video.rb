# == Schema Information
#
# Table name: videos
#
#  id          :bigint           not null, primary key
#  description :text
#  featured    :boolean          default(TRUE), not null
#  position    :integer          default(1), not null
#  title       :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  youtube_id  :text             not null
#
class Video < ApplicationRecord
  validates_presence_of :youtube_id, :title, :position
  validates_uniqueness_of :youtube_id

  scope :featured, -> { where(featured: true) }

  def embed_url
    "https://www.youtube-nocookie.com/embed/#{youtube_id}"
  end
end
