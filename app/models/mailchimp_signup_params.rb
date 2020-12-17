class MailchimpSignupParams
  include ActiveModel::Validations

  attr_accessor :email_address, :tags, :interests, :merge_fields

  validates_presence_of :email_address
  validate :interests_specified?

  def initialize(email_address:, tags: '', interests: [], merge_fields: {})
    @email_address = email_address
    @tags = tags || ''
    @interests = interests || {}
    @merge_fields = merge_fields || {}
  end

  def user_name
    merge_fields['FULLNAME']
  end

  def school_name
    merge_fields['SCHOOL']
  end

  private

  def interests_specified?
    if @interests.blank? || @interests.values.all?(&:blank?)
      errors.add(:interests, 'At least one group must be specified')
    end
  end
end
