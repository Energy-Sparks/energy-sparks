# frozen_string_literal: true

# == Schema Information
#
# Table name: issue_tags
#
#  id         :bigint(8)        not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class IssueTag < ApplicationRecord
end
