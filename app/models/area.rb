# == Schema Information
#
# Table name: areas
#
#  active          :boolean          default(TRUE)
#  back_fill_years :integer          default(4)
#  description     :text
#  gsp_id          :integer
#  gsp_name        :string
#  id              :bigint(8)        not null, primary key
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  title           :text
#  type            :text             not null
#

class Area < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :by_title, -> { order(title: :asc) }
end
