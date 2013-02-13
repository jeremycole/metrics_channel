require "metrics_channel/periodic_metrics"
require "pp"

p = PeriodicMetrics.new

s1 = PeriodicMetrics::Sample.new(Time.now.utc.to_f*1000.0)
s2 = PeriodicMetrics::Sample.new(Time.now.utc.to_f*1000.0 + 100.0)

("a".."z").each_with_index do |letter, index|
  name = "test_#{letter}"
  s1_value = index.to_f
  s2_value = s1_value + index.to_f*2.0
  type = [:counter, :absolute][index % 2]
  s1.add(name, s1_value, type)
  s2.add(name, s2_value, type)
end

p.add_sample(s1)
p.add_sample(s2)

puts
s1.dump
s2.dump

puts
p.delta.dump

puts
p.combine.dump

puts
pp s1.sum(["test_a", "test_b", "test_c"])
pp s1.sum("test_c")