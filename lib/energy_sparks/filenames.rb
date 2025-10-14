# frozen_string_literal: true

module EnergySparks
  module Filenames
    def self.name(name, time: nil, extension: nil)
      time ||= Time.current
      "#{I18n.t('common.application').parameterize}-#{name}-#{time.iso8601.tr(':', '-')}#{".#{extension}" if extension}"
    end

    def self.csv(name, time: nil)
      name(name, time:, extension: :csv)
    end
  end
end
