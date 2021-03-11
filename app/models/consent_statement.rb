class ConsentStatement < ApplicationRecord
  has_many :consent_grants, inverse_of: :consent_statement
  has_rich_text :content

  validates :title, :content, presence: true

  scope :by_date, -> { order(created_at: :desc) }

  def editable?
    consent_grants.empty?
  end
end
