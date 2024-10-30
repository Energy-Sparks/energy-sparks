class SchoolSearchComponent < ApplicationComponent
  attr_reader :schools, :tab, :letter, :keyword

  TABS = [:schools, :school_groups].freeze

  def initialize(tab: :schools,
                 schools: School.active,
                 school_groups: SchoolGroup.all,
                 letter: 'A',
                 keyword: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @tab = tab.to_sym
    @letter = letter
    @keyword = keyword
    @schools = schools
    @school_groups = school_groups
  end

  def tab_active?(tab)
    @tab == tab
  end

  def letter_status(tab, letter)
    if tab == @tab && letter == @letter
      'active'
    elsif tab == :schools
      'disabled' unless schools_by_letter.key?(letter)
    else
      'disabled' unless school_groups_by_letter.key?(letter)
    end
  end

  def letter_title(tab, letter)
    count = tab == :schools ? schools_by_letter[letter] : school_groups_by_letter[letter]
    I18n.t("components.search_results.#{tab}.subtitle", count: count)
  end

  def label(tab, suffix)
    "#{tab.to_s.dasherize}-#{suffix}"
  end

  def by_letter
    @by_letter ||= default_search_scope.by_letter(@letter).by_name
  end

  def by_keyword
    @by_keyword ||= default_search_scope.by_keyword(@keyword).by_name
  end

  def default_search_scope
    @scope = if @tab == :schools
               @schools
             else
               @school_groups
             end
  end

  def default_results_title
    if @keyword
      I18n.t('components.search_results.keyword.title')
    else
      @letter
    end
  end

  def default_results_subtitle
    count = @keyword ? by_keyword.count : by_letter.count
    I18n.t('components.search_results.schools.subtitle', count: count)
  end

  def default_results
    @keyword ? by_keyword : by_letter
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
end
