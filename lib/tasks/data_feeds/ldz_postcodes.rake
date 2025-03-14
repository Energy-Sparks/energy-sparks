# frozen_string_literal: true

namespace :data_feeds do
  desc 'Load calorific values from National Gas'
  task ldz_postcodes: :environment do
    # from https://www.xoserve.com/a-to-z/#p - https://www.xoserve.com/media/2008/postcode-exit-zone-list-may-2017.zip
    xlsx = Roo::Excelx.new('../Postcode-Exit-Zone-List-May-2017.xlsx')

    # postcodes = Hash.new { |h, k| h[k] = {} }
    postcode_to_zone = Hash.new { |h, k| h[k] = Set.new }

    # postcodes = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Set.new } }
    # postcode_to_zone = Hash.new { |h, k| h[k] = Set.new }


    xlsx.sheets.each do |name|
      sheet = xlsx.sheet(name)
      header = sheet.row(1).each.with_index(1).to_h
      (2..sheet.last_row).each do |row|
        postcode = "#{sheet.cell(row, header['Outcode'])}#{sheet.cell(row, header['Incode'])}"
        postcode_to_zone[postcode] << sheet.cell(row, header['LDZ'])
        # postcodes[sheet.cell(row, header['Outcode'])][sheet.cell(row, header['Incode'])] << sheet.cell(row, header['LDZ'])
        # debugger if sheet.cell(row, 1).is_a?(Integer)
        # next
        # sheet.cell(row, 0)
        # xlsx.sheet(name).to_a[1..].each do |row|
      end
    end

    postcodes.transform_values { |v| v.values.uniq.count == 1 ? v.values.uniq.first : v }

    multiple_postcodes = postcodes.map { |k, v| [k, v.select { |k, v| v.count != 1 }] }.filter { |k, v| v.any? }.to_h

    raise multiple_postcodes if multiple_postcodes != { 'SE1' => { '6HZ' => Set['SE', 'NT'] },
                                                        'SW11' => { '3GQ' => Set['SE', 'NT'] } }

    postcodes['SE1']['6HZ'] = ['SE']
    postcodes['SW11']['3GQ'] = ['SE']

    # remove sets for zones
    postcodes = postcodes.transform_values { |v| v.transform_values(&:first) }
    # make outcode return a zone if all incodes have the same zone
    postcodes = postcodes.transform_values { |v| v.values.uniq.count == 1 ? v.values.first : v }
    # debugger

    # File.write('postcode_to_ldz.json', postcodes.to_json)


    # multiple_postcodes = postcode_to_zone.select { |k, v| v.length != 1 }

    # raise multiple_postcodes if Set.new(multiple_postcodes) != Set.new[%w[SE16HZ SW113GQ]]
    # postcode_to_zone['SW113GQ'] = ['SE']
    # postcode_to_zone['SE16HZ'] = ['SE']

    # postcode_to_zone.transform_values!(&:first)
    # debugger



    # def get(code)
    #   uri = URI('https://services3.arcgis.com/wu6UaLFpe7o7IEYM/ArcGIS/rest/services/IDNS_LDZ_Postcode_Map_WFL1/' \
    #             "FeatureServer/13/query?where=1%3D1&f=json&outFields=#{code}")
    #   body = Net::HTTP.get(uri)
    #   JSON.parse(body)
    # end

    # postcode_to_zone = Hash.new { |h, k| h[k] = [] }
    # LocalDistributionZone.find_each do |zone|
    #   data = get(zone.code)
    #   data['features'].map { |item| item['attributes'].values.first }.reject(&:empty?).each do |postcode|
    #     postcode_to_zone[postcode] << zone.code
    #   end
    #   # debugger
    # end
    # File.write('postcode_to_ldz.json', postcode_to_zone.to_json)
    # debugger
  end
end
