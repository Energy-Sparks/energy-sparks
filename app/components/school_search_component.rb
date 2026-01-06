class SchoolSearchComponent < ApplicationComponent
  attr_reader :schools, :school_groups, :tab, :letter, :keyword, :schools_total_key

  DEFAULT_TAB = :schools
  TABS = [:schools, :school_groups, :diocese, :areas].freeze
  DIOCESE_PREFIX = 'Diocese of'.freeze # common prefix for CofE diocese

  # i18n-tasks-use t("components.school_search.schools.total")
  # i18n-tasks-use t("components.school_search.schools.total_for_admins")
  def initialize(tab: DEFAULT_TAB,
                 schools: School.visible,
                 letter: 'A',
                 keyword: nil,
                 schools_total_key: 'components.school_search.schools.total',
                 id: nil, classes: '', **_kwargs)
    super
    @tab = self.class.sanitize_tab(tab)
    @letter = letter || 'A'
    @keyword = keyword.present? ? keyword : nil
    @schools = schools
    @school_groups = SchoolGroup.organisation_groups.with_visible_schools
    @diocese = SchoolGroup.diocese_groups.with_visible_schools
    @areas = SchoolGroup.area_groups.with_visible_schools
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

  def self.ignore_prefix(tab)
    tab == :diocese ? DIOCESE_PREFIX : nil
  end

  def all_tabs
    if Flipper.enabled?(:find_new_group_types, current_user)
      TABS
    else
      [:schools, :school_groups].freeze
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
    elsif tab == :diocese
      'disabled' unless diocese_by_letter.key?(letter)
    elsif tab == :areas
      'disabled' unless areas_by_letter.key?(letter)
    else
      'disabled' unless school_groups_by_letter.key?(letter)
    end
  end

  # i18n-tasks-use t("components.search_results.schools.subtitle")
  # i18n-tasks-use t("components.search_results.school_groups.subtitle")
  # i18n-tasks-use t("components.search_results.diocese.subtitle")
  # i18n-tasks-use t("components.search_results.areas.subtitle")
  def letter_title(tab, letter)
    count = case tab
            when :schools
              schools_by_letter[letter]
            when :diocese
              diocese_by_letter[letter]
            when :areas
              areas_by_letter[letter]
            else
              school_groups_by_letter[letter]
            end
    return '' if count.nil?
    I18n.t("components.search_results.#{tab}.subtitle", count: count)
  end

  def label(tab, suffix = nil)
    if suffix
      "#{tab.to_s.dasherize}-#{suffix}"
    else
      tab.to_s.dasherize
    end
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
      search_scope.by_keyword(@keyword).by_name
    elsif tab_active?(tab)
      by_letter
    else
      by_letter('A', tab)
    end
  end

  def schools_count
    @schools.count
  end

  private

  def search_scope(scope = @tab)
    case scope
    when :schools
      @schools
    when :diocese
      @diocese
    when :areas
      @areas
    else
      @school_groups
    end
  end

  def by_letter(letter = @letter, scope = @tab)
    search_scope(scope).by_letter(letter, self.class.ignore_prefix(scope)).by_name
  end

  def schools_by_letter
    @schools_by_letter ||= group_by_letter(:schools)
  end

  def school_groups_by_letter
    @school_groups_by_letter ||= group_by_letter(:school_groups)
  end

  def diocese_by_letter
    @diocese_by_letter ||= group_by_letter(:diocese)
  end

  def areas_by_letter
    @areas_by_letter ||= group_by_letter(:areas)
  end

  def group_by_letter(scope)
    search_scope(scope).group_by_letter(self.class.ignore_prefix(scope)).count
  end
end
