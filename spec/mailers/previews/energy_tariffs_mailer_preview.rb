class EnergyTariffsMailerPreview < ActionMailer::Preview
  def group_admin_review_group_tariffs_reminder
    EnergyTariffsMailer.with(school_group_id: SchoolGroup.first.id).group_admin_review_group_tariffs_reminder
  end

  def school_admin_review_school_tariffs_reminder
    EnergyTariffsMailer.with(school_id: School.first.id).school_admin_review_school_tariffs_reminder
  end

  private

  def locale
    locale = @params["locale"].present? ? @params["locale"] : "en"
  end
end
