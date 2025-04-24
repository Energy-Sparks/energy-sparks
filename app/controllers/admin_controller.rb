class AdminController < ApplicationController
  include Adminable
  before_action :admin_authorized?

  def index
  end

  private

  def permit_params(model_class)
    fields = model_class.column_names.map(&:to_sym) - [:id, :created_at, :updated_at]
    params.require(model_class.name.underscore.to_sym).permit(*fields)
  end
end
