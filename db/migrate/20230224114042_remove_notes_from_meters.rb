class RemoveNotesFromMeters < ActiveRecord::Migration[6.0]

  def issue_attrs_from_meter(meter)
    fuel_type_map = {
      electricity: :electricity,
      gas: :gas,
      solar_pv: :solar,
      exported_solar_pv: :solar }

    title = "#{meter.fuel_type} meter: #{meter.mpan_mprn}".capitalize
    title += " - #{meter.name}" unless meter.name.blank?
    attrs = {  issue_type: :issue,
               title: title,
               issueable: meter.school,
               fuel_type: fuel_type_map[meter.fuel_type] }
  end

  def up
    # Remove all meter notes from DB
    ActionText::RichText.where(record_type: 'Meter', name: 'notes').delete_all

    # Strip trix-content divs from imported meter notes while here
    Meter.all.each do |meter|
      if issue = Issue.find_by(issue_attrs_from_meter(meter))
        issue.description = issue.description.body.to_html.to_s.gsub(/\A<div class="trix-content">(.*)<\/div>\z/m, '\1').strip.html_safe
        issue.save!
      end
    end
  end

  def down
    Meter.all.each do |meter|
      if issue = Issue.find_by(issue_attrs_from_meter(meter))
        meter.notes = issue.description.body.to_html
        meter.save!
      end
    end
  end
end
