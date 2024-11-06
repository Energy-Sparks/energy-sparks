class SchoolSearchComponentPreview < ViewComponent::Preview
  def example(letter: 'A', keyword: nil, tab: :schools)
    component = SchoolSearchComponent.new(
      letter: letter,
      keyword: keyword,
      tab: tab
    )
    render(component)
  end
end
