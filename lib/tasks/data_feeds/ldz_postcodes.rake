# frozen_string_literal: true

namespace :data_feeds do
  desc 'Load calorific values from National Gas'
  task ldz_postcodes: :environment do
    # from https://www.xoserve.com/a-to-z/#p - https://www.xoserve.com/media/2008/postcode-exit-zone-list-may-2017.zip
    xlsx = Roo::Excelx.new('../Postcode-Exit-Zone-List-May-2017.xlsx')
    postcode_to_zone = Hash.new { |h, k| h[k] = Set.new }
    xlsx.sheets.each do |name|
      sheet = xlsx.sheet(name)
      header = sheet.row(1).each.with_index(1).to_h
      (2..sheet.last_row).each do |row|
        postcode = "#{sheet.cell(row, header['Outcode'])}#{sheet.cell(row, header['Incode'])}"
        postcode_to_zone[postcode] << sheet.cell(row, header['LDZ'])
      end
    end
    File.write('postcode_to_ldz.json', postcode_to_zone.to_json)
  end
end
