module AnalysisPages
  extend ActiveSupport::Concern

  def find_analysis_page_of_class(school, analysis_class)
    alert_type = AlertType.where('lower(class_name) = ?', analysis_class.downcase).first
    if alert_type && school.latest_analysis_pages.any?
      school.latest_analysis_pages.includes(:alert).detect { |page| page.alert.alert_type_id == alert_type.id }
    end
  end

  def find_advice_page_of_class(analysis_class)
    AlertType.where('lower(class_name) = ?', analysis_class.downcase).first
  end

  def process_analysis_templates(pages)
    pages.by_priority.map do |page|
      TemplateInterpolation.new(
        page.content_version,
        with_objects: {
          rating: page.alert.rating,
          analysis_page: page,
          alert: page.alert,
          priority: page.priority
        }
      ).interpolate(
        :analysis_title, :analysis_subtitle,
        with: page.alert.template_variables
      )
    end
  end
end
