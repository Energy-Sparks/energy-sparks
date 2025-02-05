# frozen_string_literal: true

module Admin
  module Reports
    class HeatingTypesController < AdminController
      def humanize_type(type)
        %i[lpg chp].include?(type) ? type.to_s.upcase : type.to_s.titleize
      end
    end
  end
end
