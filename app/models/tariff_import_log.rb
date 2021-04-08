class TariffImportLog < ApplicationRecord
  scope :errored,       -> { where.not(error_messages: nil) }
  scope :successful,    -> { where(error_messages: nil) }
end
