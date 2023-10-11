module SubNavHelper
  def show_pupils_dashboard_button?
    return false if current_page?(pupils_school_path(@school || @tariff_holder))

    can?(:show_pupils_dash, @school || @tariff_holder)
  end

  def show_adult_dashboard_button?
    return false if current_page?(school_path(@school || @tariff_holder))

    can?(:show, @school || @tariff_holder)
  end
end
