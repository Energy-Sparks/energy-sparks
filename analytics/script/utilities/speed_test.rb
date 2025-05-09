
require 'benchmark'


economic_tariffs = [
  {
    start_date: Date.new(2016,1,1),
    end_date:   Date.new(2020,1,1),
    rate:       0.12
  },
  {
    start_date: Date.new(2020, 1, 2),
    end_date:   Date.new(2024, 1, 1),
    rate:       0.30
  },
  {
    start_date: Date.new(2024, 1, 2),
    end_date:   Date.new(2050, 1, 1),
    rate:       0.14
  }
]

def find_tariff1(tariffs, date)
  tariffs.find { |tariff| date >= tariff[:start_date] && date <= tariff[:end_date] }
end

economic_tariff_test_dates = [
  Date.new(2017, 1, 1)..Date.new(2018, 1, 1),
  Date.new(2022, 1, 1)..Date.new(2023, 1, 1)
]

dates = economic_tariff_test_dates.map(&:to_a).flatten

puts "Dates: #{dates.length}"

loops = 1 * 48

economic_tariffs_before = { economic_tariff: 10.5 }
bm = Benchmark.measure {
  loops.times do |i|
    dates.each do |date|
      economic_tariffs_before[:economic_tariff]
    end
  end
}

puts "Economic tariff time (current) #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    dates.each do |date|
      find_tariff1(economic_tariffs, date)
    end
  end
}

puts "Economic tariff time (hash find) #{bm.to_s}"

cache = {}
bm = Benchmark.measure {
  loops.times do |i|
    dates.each do |date|
      cache[date] ||= find_tariff1(economic_tariffs, date)
    end
  end
}

puts "Economic tariff time (hash find cache) #{bm.to_s}"

times = dates.map(&:to_time)

cache = {}
bm = Benchmark.measure {
  loops.times do |i|
    times.each do |date|
      cache[date] ||= find_tariff1(economic_tariffs, date.to_date)
    end
  end
}

puts "Economic tariff time (hash find time cache) #{bm.to_s}"

puts "Economic tariff time (hash find) #{bm.to_s}"

@d1_cache = { start_date: Date.new(2008,1,1), end_date: Date.new(2008,1,1), rate: nil }
@v1 = 45.0

cache = {}
bm = Benchmark.measure {
  loops.times do |i|
    dates.each do |date|
      if date >= @d1_cache[:start_date] && date <= @d1_cache[:end_date]
        @d1_cache[:rate]
      else
        @d1_cache = find_tariff1(economic_tariffs, date)
        puts date if @d1_cache.nil?
        @d1_cache[:rate]
      end
    end
  end
}

puts "Economic tariff time (hash find cache fast 1st key) #{bm.to_s}"

exit
def create_dates
  a = {}
  (Date.new(2010,1,1)..Date.new(2020,1,1)).each do |date|
    a[date] = 1
  end
  a
end

def slow(dates, date)
  dates.delete(date)
  a,b = dates.keys.minmax
end

def fast(dates, date)
  dates.delete(date)
  a = date if date < dates.keys.first
  b = date if date > dates.keys.last
end

dates = create_dates
date = Date.new(2015,1,1)

bm = Benchmark.measure {
  10000.times do |i|
    slow(dates, date)
  end
}
puts "slow dates method #{bm.to_s}"

bm = Benchmark.measure {
  10000.times do |i|
    fast(dates, date)
  end
}
puts "fast dates method #{bm.to_s}"

exit

puts "Reorg of x48 array for gmt/bst shifting"
kwh = Array.new(48,0.0)
bm = Benchmark.measure {
  1000.times do |i|
    kwh_new = kwh[46..47] + kwh[0..45]
    kwh_new.sum
  end
}
puts "direct array creation: kwh[46..47] + kwh[0..45] t =  #{bm.to_s}"
exit

reports = 40
years = 0.75
hours = 75

loops = reports * years * 365 * 75
loops = loops.to_i

puts "loops #{loops}"

bm = Benchmark.measure {
  loops.times do |i|
    i = i * 1.1
  end
}

puts "loop #{bm.to_s}"

bm = Benchmark.measure {
  z = 0.556
  loops.times do |i|
    x = [:ddd, :rrr, :zzz, :aaa, :bbb, :sss][i % 6]
    if x == :ddd
      z += 1
    elsif x == :rrr
      z += 2
    elsif x == :zzz
      z += 3
    elsif x == :aaa
      z += 4
    elsif x == :bbb
      z += 5
    elsif x == :sss
      z += 6
    end
  end
}

puts "if #{bm.to_s}"

bm = Benchmark.measure {
  z = 0.556
  loops.times do |i|
    x = [:ddd, :rrr, :zzz, :aaa, :bbb, :sss][i % 6]
    case x
    when :ddd
      z += 1
    when :rrr
      z += 2
    when :zzz
      z += 3
    when :aaa
      z += 4
    when :bbb
      z += 5
    when :sss
      z += 6
    end
  end
}

puts "if #{bm.to_s}"

a = Array.new(48, 6.7)
b = Array.new(48, 5.7)

bm = Benchmark.measure {
  loops.times do |i|
    a.zip(b).map{|x, y| x * y}
  end
}
puts "array multiply zip method #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    [a,b].transpose.map {|z| z.inject(:*)}
  end
}
puts "array multiply transpose map method #{bm.to_s}"

q = []

bm = Benchmark.measure {
  loops.times do |i|
    q = a.map.with_index{ |x, i| a[i]*b[i]}
  end
}
puts "array multiply with index method #{bm.to_s} #{q.sum}"

bm = Benchmark.measure {
  loops.times do |i|
    q = a.map.with_index{ |x, i| x*b[i]}
  end
}
puts "array multiply with index carry value method #{bm.to_s}  #{q.sum}"

bm = Benchmark.measure {
  loops.times do |i|
    a.size.times.collect { |i| a[i] * b[i] }
  end
}
puts "array multiply collect method #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = Array.new(48)
    (0..47).each { |i| c[i] = a[i] * b[i] }
  end
}
puts "array multiply i loop #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = Array.new(48, 0.0)
    (0..47).each { |x| c[x] = a[x] * b[x] }
  end
}
puts "array multiply i loop zeroed array #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = []
    (0..47).each { |i| c.push(a[i] * b[i]) }
  end
}
puts "array multiply i loop with push #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = Array.new(48,0.0)
    (0..47).each do |i|
      c[i] = a[i] * b[i]
    end
  end
}
puts "array multiply i loop zeroed array multi line #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = Array.new(48, 0.0)
    (0..47).each { |i| c[i] = a[i] + b[i] }
  end
}
puts "array addition i loop zeroed array #{bm.to_s}"

bm = Benchmark.measure {
  bs = 1.5
  loops.times do |i|
    c = Array.new(48, 0.0)
    (0..47).each { |i| c[i] = a[i] * bs }
  end
}
puts "array scale i loop zeroed array #{bm.to_s}"

bm = Benchmark.measure {
  bs = 1.5
  loops.times do |i|
    c = a.map { |v| v * bs }
  end
}
puts "array scale map array #{bm.to_s}"


def simple_args(a,b)
  a * b
end

def keyword_args(a:, b:)
  a * b
end

bm = Benchmark.measure {
  loops.times do |i|
    c = simple_args(6.0,5.4)
  end
}
puts "simple args #{bm.to_s}"

bm = Benchmark.measure {
  loops.times do |i|
    c = keyword_args(b: 6.0, a: 5.4)
  end
}
puts "keyword args #{bm.to_s}"

