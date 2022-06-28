# == Schema Information
#
# Table name: staff_roles
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  updated_at :datetime         not null
#

class StaffRole < ApplicationRecord
  has_many :users

  enum dashboard: [:management, :teachers]

  def translated_title
    I18n.t(i18n_key)
  end

  def i18n_key
    "#{self.class.model_name.i18n_key}.#{title.parameterize.underscore}"
  end

  def as_symbol
    title.parameterize.underscore.to_sym
  end
end
