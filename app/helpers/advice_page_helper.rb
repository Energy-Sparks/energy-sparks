module AdvicePageHelper
  def advice_page_path(school, advice_page, tab = :insights)
    polymorphic_path([tab, school, :advice, advice_page.key.to_sym])
  end

  def advice_baseload_high?(val)
    val > 0.0
  end
end
