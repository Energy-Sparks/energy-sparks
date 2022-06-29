class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum_name(attribute, key)
    I18n.t(key, scope: [:activerecord, :attributes, model_name.i18n_key, attribute])
  end
end
