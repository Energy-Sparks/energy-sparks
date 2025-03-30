# frozen_string_literal: true

namespace :data_feeds do
  desc 'Load calorific values from National Gas'
  task ldz_postcodes: :environment do
    # from https://www.xoserve.com/a-to-z/#p - https://www.xoserve.com/media/2008/postcode-exit-zone-list-may-2017.zip
    # looksups also available at https://www.jaxi.co.uk/tools/ldz-lookup and
    # https://www.energybrokers.co.uk/gas/ldz-search
    xlsx = Roo::Excelx.new('tmp/Postcode-Exit-Zone-List-May-2017.xlsx')
    CSV.open('Postcode-Exit-Zone-List-May-2017.csv', 'w', write_headers: true, headers: %w[Postcode Zone]) do |csv|
      xlsx.sheets.each do |name|
        sheet = xlsx.sheet(name)
        header = sheet.row(1).each.with_index(1).to_h
        (2..sheet.last_row).each do |row|
          postcode = "#{sheet.cell(row, header['Outcode'])} #{sheet.cell(row, header['Incode'])}"
          csv << [postcode, sheet.cell(row, header['LDZ'])]
        end
      end
    end
  end
end
