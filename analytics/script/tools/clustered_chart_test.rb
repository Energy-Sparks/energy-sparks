#

# A demo of a clustered category chart in Excel::Writer::XLSX.

#

# reverse ('(c)'), March 2015, John McNamara, jmcnamara@cpan.org

# convert to ruby by Hideo NAKAMURA, cxn03651@msj.biglobe.ne.jp

#



require 'write_xlsx'



workbook  = WriteXLSX.new('chart_clustered.xlsx')

worksheet = workbook.add_worksheet

bold      = workbook.add_format(:bold => 1)



# Add the worksheet data that the charts will refer to.

headings = ['Types',  'Sub Type',   'Value 1', 'Value 2', 'Value 3']

data = [

  ['Type 1', 'Sub Type A', 5000,      8000,      Float::NAN],

  ['',       'Sub Type B', 2000,      3000,      4000],

  ['',       'Sub Type C', 250,       1000,      2000],

  ['Type 2', 'Sub Type D', 6000,      6000,      6500],

  ['',       'Sub Type E', 500,       300,       200]

]



worksheet.write('A1', headings, bold)

worksheet.write_col('A2', data)



# Create a new chart object. In this case an embedded chart.

chart = workbook.add_chart(:type => 'column', :embedded => 1)



# Configure the series. Note, that the categories are 2D ranges (from column A

# to column B). This creates the clusters. The series are shown as formula

# strings for clarity but you can also use the array syntax. See the docs.

chart.add_series(

  :name       => '=Sheet1!$C$1',

  :categories => '=Sheet1!$A$2:$B$6',

  :values     => '=Sheet1!$C$2:$C$6'

)



chart.add_series(

  :name       => '=Sheet1!$D$1',

  :categories => '=Sheet1!$A$2:$B$6',

  :values     => '=Sheet1!$D$2:$D$6'

)



chart.add_series(

  :name       => '=Sheet1!$E$1',

  :categories => '=Sheet1!$A$2:$B$6',

  :values     => '=Sheet1!$E$2:$E$6'

)



# Set the Excel chart style.

chart.set_style(37)



# Turn off the legend.

chart.set_legend(:position => 'none')



# Insert the chart into the worksheet.

worksheet.insert_chart('G3', chart)



workbook.close