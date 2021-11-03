module DashboardSetup
  extend ActiveSupport::Concern

  def show_data_enabled_features?
    if current_user && current_user.admin?
      true unless params[:no_data]
    else
      @school.data_enabled?
    end
  end
end
