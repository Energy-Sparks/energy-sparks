class FindOutMoreTypeContentVersion < ApplicationRecord
  belongs_to :find_out_more_type
  belongs_to :replaced_by, class_name: 'FindOutMoreTypeContentVersion', foreign_key: :replaced_by_id

  validates :dashboard_title, :page_title, :page_content, presence: true

  scope :latest, -> { where(replaced_by_id: nil) }
end
