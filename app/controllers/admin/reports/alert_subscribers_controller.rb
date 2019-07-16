# frozen_string_literal: true

module Admin::Reports
  class AlertSubscribersController < AdminController
    def index
      @contacts = Contact.includes(:school).all.order(:school_id)
    end
  end
end
