# == Schema Information
#
# Table name: areas
#
#  description :text
#  id          :bigint(8)        not null, primary key
#  parent_id   :integer
#  title       :text
#
# Indexes
#
#  index_areas_on_parent_id  (parent_id)
#

class Area < ApplicationRecord

end
