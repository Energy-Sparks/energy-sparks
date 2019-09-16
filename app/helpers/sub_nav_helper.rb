module SubNavHelper
  def show_teachers_dashboard_button?
    return false if current_page?(teachers_school_path(@school))
    can?(:show_teachers_dash, @school)
  end

  def show_pupils_dashboard_button?
    return false if current_page?(pupils_school_path(@school))
    can?(:show_pupils_dash, @school)
  end
end
