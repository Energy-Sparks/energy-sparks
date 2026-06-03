# frozen_string_literal: true

module Admin
  module Reports
    class UserLoginsController < AdminController
      def index
        @school_group = SchoolGroup.find(params[:id]) if params.key?(:id)
      end
    end
  end
end
