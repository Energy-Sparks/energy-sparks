# frozen_string_literal: true

module Admin
  module Reports
    class UserLoginsController < AdminController
      def index
        # @school_groups = SchoolGroup.order(name: :asc)
        # debugger if params[:id]
        @school_group = SchoolGroup.find(params[:id]) if params.key?(:id)
      end

      def show
        debugger
      end
    end
  end
end
