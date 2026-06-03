require 'daru'
require 'statsample'

begin
  puts "Starting calculation"
  x1 = Daru::Vector.new([5.6,10.56])
  x2 = Daru::Vector.new([3.25, 5.2])
  y = Daru::Vector.new([0, 25.7])
  ds = Daru::DataFrame.new({:heating_dd => x1, :lighting_ir => x2, :kwh => y})
  lr = Statsample::Regression.multiple(ds, :kwh)
  puts "Calculation Worked"
  puts ds
rescue Statsample::Regression::LinearDependency => x
  puts "Stat sample exception handled"
rescue => e
  puts "Exception captured"
  puts e.message
else
  puts "Else"
ensure
  puts "Ensure"
end

puts "End of programme"
