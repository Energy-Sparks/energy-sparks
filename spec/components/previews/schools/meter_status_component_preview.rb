class Schools::MeterStatusComponentPreview < ViewComponent::Preview
  # @param slug select :school_options
  # @param table_small toggle
  def default(slug: nil, table_small: false)
    @slug = slug
    render(Schools::MeterStatusComponent.new(school: school, table_small:))
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
