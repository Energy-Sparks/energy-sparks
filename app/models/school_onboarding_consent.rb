class SchoolOnboardingConsent
  include ActiveModel::Model

  attr_accessor :privacy

  validates :privacy, acceptance: { message: 'Please confirm' }
end
