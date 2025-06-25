class TabsComponentPreview < ViewComponent::Preview
  def examples
    render(TabsComponent.new) do |component|
      component.with_tab(name: :first, label: 'First') { 'first tab content' }
      component.with_tab(name: :second, label: 'Second') { 'second tab content' }
    end
  end
end
