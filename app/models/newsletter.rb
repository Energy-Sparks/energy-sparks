# == Schema Information
#
# Table name: newsletters
#
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  published_on :date             not null
#  title        :text             not null
#  updated_at   :datetime         not null
#  url          :text             not null
#

class Newsletter < ApplicationRecord
  has_one_attached :image

  validates_presence_of :title, :url, :published_on
end
