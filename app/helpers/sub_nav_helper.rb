module SubNavHelper
  def show_pupils_dashboard_button?
    return false if current_page?(pupils_school_path(@school))
    can?(:show_pupils_dash, @school)
  end

  def show_management_dashboard_button?
    return false if current_page?(management_school_path(@school))
    can?(:show_management_dash, @school)
  end

  def show_adult_dashboard_button?
    return false if current_page?(school_path(@school))
    can?(:show, @school)
  end
end
