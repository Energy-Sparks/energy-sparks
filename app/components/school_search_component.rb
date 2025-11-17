class SchoolSearchComponent < ApplicationComponent
  attr_reader :schools, :school_groups, :tab, :letter, :keyword, :schools_total_key

  DEFAULT_TAB = :schools
  TABS = [:schools, :school_groups].freeze

  # i18n-tasks-use t("components.school_search.schools.total")
  # i18n-tasks-use t("components.school_search.schools.total_for_admins")
  def initialize(tab: DEFAULT_TAB,
                 schools: School.visible,
                 school_groups: SchoolGroup.organisation_groups.with_visible_schools,
                 letter: 'A',
                 keyword: nil,
                 schools_total_key: 'components.school_search.schools.total',
                 id: nil, classes: '')
    super(id: id, classes: classes)
    @tab = self.class.sanitize_tab(tab)
    @letter = letter || 'A'
    @keyword = keyword.present? ? keyword : nil
    @schools = schools
    @school_groups = school_groups
    @schools_total_key = schools_total_key
  end

  def self.sanitize_tab(tab)
    return DEFAULT_TAB unless tab
    if TABS.include?(tab.to_sym)
      tab.to_sym
    else
      DEFAULT_TAB
    end
  end

  def tab_active?(tab)
    @tab == tab
  end

  def letter_status(tab, letter)
    if !tab_active?(tab) && letter == 'A'
      'active' # Ensure A is active by default
    elsif tab_active?(tab) && letter == @letter && @keyword.nil?
      'active' # Activate letter based on parameter
    elsif tab == :schools
      'disabled' unless schools_by_letter.key?(letter)
    else
      'disabled' unless school_groups_by_letter.key?(letter)
    end
  end

  # i18n-tasks-use t("components.search_results.schools.subtitle")
  # i18n-tasks-use t("components.search_results.school_groups.subtitle")
  def letter_title(tab, letter)
    count = tab == :schools ? schools_by_letter[letter] : school_groups_by_letter[letter]
    return '' if count.nil?
    I18n.t("components.search_results.#{tab}.subtitle", count: count)
  end

  def label(tab, suffix)
    "#{tab.to_s.dasherize}-#{suffix}"
  end

  def default_results_title(tab)
    if tab_active?(tab) && @keyword
      I18n.t('components.search_results.keyword.title')
    else
      tab_active?(tab) ? @letter : 'A'
    end
  end

  def default_results_subtitle(tab)
    count = default_results(tab).count
    I18n.t("components.search_results.#{tab}.subtitle", count: count)
  end

  def default_results(tab)
    if tab_active?(tab) && @keyword
      by_keyword
    elsif tab_active?(tab)
      by_letter
    else
      by_letter('A', tab)
    end
  end

  def schools_count
    @schools.count
  end

  def school_groups_count
    @school_groups.count
  end

  private

  def by_letter(letter = @letter, scope = @tab)
    search_scope(scope).by_letter(letter).by_name
  end

  def by_keyword
    search_scope.by_keyword(@keyword).by_name
  end

  def search_scope(scope = @tab)
    if scope == :schools
      @schools
    else
      @school_groups
    end
  end

  def schools_by_letter
    @schools_by_letter ||= @schools.group_by_letter.count
  end

  def school_groups_by_letter
    @school_groups_by_letter ||= @school_groups.group_by_letter.count
  end
end
