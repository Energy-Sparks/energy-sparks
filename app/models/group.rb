# == Schema Information
#
# Table name: groups
#
#  description     :text
#  id              :bigint(8)        not null, primary key
#  parent_group_id :integer
#  title           :text
#
# Indexes
#
#  index_groups_on_parent_group_id  (parent_group_id)
#

class Group < ApplicationRecord
  belongs_to  :parent_group, class_name: 'Group'
  has_many    :child_groups, class_name: 'Group', foreign_key: :parent_group_id
end
