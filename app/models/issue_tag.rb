# frozen_string_literal: true

# == Schema Information
#
# Table name: issue_tags
#
#  id         :bigint(8)        not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  system_id  :string
#
# Indexes
#
#  index_issue_tags_on_label      (label) UNIQUE
#  index_issue_tags_on_system_id  (system_id) UNIQUE
#
class IssueTag < ApplicationRecord
  include Deletable

  has_and_belongs_to_many :issues, inverse_of: :issue_tags # rubocop:disable Rails/HasAndBelongsToMany

  scope :by_label, -> { order(label: :asc) }

  validates :label, presence: true, uniqueness: true

  def deletable?
    system_id.nil?
  end
end
