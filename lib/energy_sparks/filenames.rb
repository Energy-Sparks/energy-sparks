# frozen_string_literal: true

module EnergySparks
  module Filenames
    def self.csv(name)
      "#{I18n.t('common.application').parameterize}-#{name}-#{Time.current.iso8601.tr(':', '-')}.csv"
    end
  end
end
