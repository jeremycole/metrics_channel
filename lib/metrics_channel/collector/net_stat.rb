require "pp"

class MetricsChannel::Collector::NetStat < MetricsChannel::Collector
  def self.name
    "net_stat"
  end

  def initialize(config)
  end

  def collect
    @metrics = {}
    File.open("/proc/net/netstat") do |netstat|
      netstat.readlines.each_slice(2) do |names, values|
        name_list  = names.chomp.split(/\s+/)
        value_list = values.chomp.split(/\s+/)
        group = name_list.shift.sub(":", "")
        value_list.shift # discard

        name_list.each do |name|
          value = value_list.shift
          @metrics["#{group}_#{name}"] = value
        end
      end
    end

    true
  end

  def each_metric
    @metrics.each do |name, metric|
      yield name, metric, :counter
    end

    true
  end

  def each_derived_metric(sample)
  end
end
