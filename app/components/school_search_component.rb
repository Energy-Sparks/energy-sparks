class SchoolSearchComponent < ApplicationComponent
  attr_reader :schools, :tab, :letter, :search

  def initialize(tab: :schools,
                 schools: School.active,
                 school_groups: SchoolGroup.all,
                 letter: nil,
                 search: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @tab = tab
    @letter = letter
    @search = search
    @schools = schools
    @school_groups = school_groups
  end

  def active?(letter)
    return true if letter == 'A'
  end

  def school_letter_status(letter)
    if letter == 'A'
      'active'
    else
      'disabled' unless any_school?(letter)
    end
  end

  def schools_count
    @schools.count
  end

  def school_groups_count
    @school_groups.count
  end

  def schools_by_letter
    @schools_by_letter ||= @schools.group('substr(upper(name), 1, 1)').count
  end

  def school_groups_by_letter
    @school_groups_by_letter ||= @school_groups.group('substr(upper(name), 1, 1)').count
  end

  def any_school?(letter)
    schools_by_letter.key?(letter)
  end

  def any_school_group?(letter)
    school_groups_by_letter.key?(letter)
  end
end
