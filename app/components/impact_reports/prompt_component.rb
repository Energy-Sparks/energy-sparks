# frozen_string_literal: true

module ImpactReports
  class PromptComponent < ImpactReports::BaseComponent # rubocop:disable ViewComponent/PreferComposition
    def render?
      Flipper.enabled?(:impact_reporting, current_user) &&
        @config&.visible? &&
        @run&.enough_data?
    end
  end
end
