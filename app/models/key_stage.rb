# == Schema Information
#
# Table name: key_stages
#
#  id   :bigint           not null, primary key
#  name :string
#
# Indexes
#
#  index_key_stages_on_name  (name) UNIQUE
#

class KeyStage < ApplicationRecord
  scope :by_name, -> { order(name: :asc) }

  def i18n_key
    "#{self.class.model_name.i18n_key}.#{name.parameterize.underscore}"
  end
end
