# == Schema Information
#
# Table name: areas
#
#  id              :bigint(8)        not null, primary key
#  active          :boolean          default(TRUE)
#  back_fill_years :integer          default(4)
#  description     :text
#  gsp_name        :string
#  latitude        :decimal(10, 6)
#  longitude       :decimal(10, 6)
#  title           :text
#  type            :text             not null
#  gsp_id          :integer
#

class Area < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :by_title, -> { order(title: :asc) }
end
