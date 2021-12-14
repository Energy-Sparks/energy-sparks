# == Schema Information
#
# Table name: jobs
#
#  closing_date :date
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  title        :string           not null
#  updated_at   :datetime         not null
#  voluntary    :boolean          default(FALSE)
#
class Job < ApplicationRecord
  has_one_attached :file
  has_rich_text :description
  validates :title, :file, presence: true

  scope :current_jobs, -> { where(closing_date: nil).or(where("closing_date >= ?", Time.zone.today)) }
  scope :by_created_date, -> { order(created_at: :asc) }
end
