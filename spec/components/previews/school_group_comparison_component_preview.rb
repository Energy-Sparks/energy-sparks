class SchoolGroupComparisonComponentPreview < ViewComponent::Preview
  def with_cluster
    render SchoolGroupComparisonComponent.new(id: 'my-id', comparison: comparison, advice_page_key: :baseload,
                                              include_cluster: true)
  end

  def without_cluster
    render SchoolGroupComparisonComponent.new(id: 'my-id', comparison: comparison, advice_page_key: :baseload,
                                              include_cluster: false)
  end

  private

  def comparison
    schools = School.active.last(8)
    allocation = [0, 2, 6].shuffle
    rows = schools.collect do |school|
      { 'school_id' => school.id, 'school_slug' => school.slug, 'school_name' => school.name,
        'cluster_name' => school.school_group_cluster_name }
    end

    {
      benchmark_school: rows.shift(allocation.shift),
      exemplar_school: rows.shift(allocation.shift),
      other_school: rows.shift(allocation.shift)
    }
  end
end
