# == Schema Information
#
# Table name: staff_roles
#
#  created_at                  :datetime         not null
#  id                          :bigint(8)        not null, primary key
#  mailchimp_fields_changed_at :datetime
#  title                       :string           not null
#  updated_at                  :datetime         not null
#

class StaffRole < ApplicationRecord
  include MailchimpUpdateable

  watch_mailchimp_fields :title

  has_many :users

  attribute :dashboard, :string
  enum :dashboard, { management: 0, teachers: 1 }

  def translated_title
    I18n.t(i18n_key)
  end

  def i18n_key
    "#{self.class.model_name.i18n_key}.#{title.parameterize.underscore}"
  end

  def as_symbol
    title.parameterize.underscore.to_sym
  end

  def self.translated_names_and_ids
    all.map { |staff_role| [staff_role.translated_title, staff_role.id] }.sort
  end
end
