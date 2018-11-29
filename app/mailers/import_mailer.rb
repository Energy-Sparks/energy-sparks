class ImportMailer < ApplicationMailer
  def import_summary
    @logs = params[:logs]
    subject_description = params[:description] || 'import'
    mail(to: 'services@energysparks.uk', subject: "[energy-sparks] Energy Sparks #{subject_description}: #{@logs.size} #{'import'.pluralize(@logs.size)} processed")
  end
end
