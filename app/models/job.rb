# == Schema Information
#
# Table name: jobs
#
#  id           :bigint           not null, primary key
#  closing_date :date
#  title        :string           not null
#  voluntary    :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Job < ApplicationRecord
  has_one_attached :file
  has_rich_text :description
  validates :title, :file, presence: true

  scope :current_jobs, -> { where(closing_date: nil).or(where('closing_date >= ?', Time.zone.today)) }
  scope :by_created_date, -> { order(created_at: :asc) }

  def to_job_posting
    {
      '@context' => 'https://schema.org/',
      '@type' => 'JobPosting',
      'title' => title,
      'description' => description.to_s,
      "identifier": {
        '@type' => 'PropertyValue',
        'name' => 'Energy Sparks',
        'value' => id
      },
      'datePosted' => created_at.strftime('%Y-%m-%d'),
      'validThrough' => closing_date.present? ? closing_date.strftime('%Y-%m-%d') : '',
      'hiringOrganization' => {
        '@type' => 'Organization',
        'name' => 'Energy Sparks',
        'sameAs' => 'https://energysparks.uk',
      },
      'applicantLocationRequirements' => {
        '@type' => 'Country',
        'name' => 'UK'
      },
      'jobLocationType' => 'TELECOMMUTE',
      'employmentType' => voluntary ? 'VOLUNTEER' : 'OTHER'
    }
  end
end
