# frozen_string_literal: true

module Admin
  # Component for showing internal metadata for an active model record
  class SchoolStatusButtonsComponent < ApplicationComponent
    delegate :data_sharing_colour, to: :helpers

    def initialize(school:, **_kwargs)
      super
      @school = school
    end

    def render?
      current_user&.admin?
    end

    private

    def licence_expiry_colour(licence)
      return :danger if licence.nil? || licence.end_date <= Time.zone.today
      return :warning if licence.end_date < Time.zone.today + 1.month

      :success
    end
  end
end
