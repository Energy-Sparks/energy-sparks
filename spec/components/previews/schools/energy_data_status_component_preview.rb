class Schools::EnergyDataStatusComponentPreview < ViewComponent::Preview
  # @param slug select :school_options
  # @param table_small toggle
  # @param show_fuel_icon toggle
  def default(slug: nil, table_small: false, show_fuel_icon: true)
    @slug = slug
    render(Schools::EnergyDataStatusComponent.new(school: school, table_small:, show_fuel_icon:))
  end

  private

  def school
    @slug ? School.find(@slug) : schools.sample
  end

  def schools
    School.data_visible
  end

  def school_options
    {
      choices: schools.by_name.map { |g| [g.name, g.slug] }
    }
  end
end
