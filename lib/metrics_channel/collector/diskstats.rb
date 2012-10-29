require "pp"

class MetricsChannel::Collector::Diskstats < MetricsChannel::Collector
  def self.name
    "diskstats"
  end

  FIELDS_ORDERED = [
    "r_ios",
    "r_merges",
    "r_sectors",
    "r_ticks",
    "w_ios",
    "w_merges",
    "w_sectors",
    "w_ticks",
    "in_progress",
    "ticks",
    "aveq",
  ]

  FIELDS = {
    "r_ios"         => :counter,
    "r_merges"      => :counter,
    "r_sectors"     => :counter,
    "r_ticks"       => :counter,
    "w_ios"         => :counter,
    "w_merges"      => :counter,
    "w_sectors"     => :counter,
    "w_ticks"       => :counter,
    "in_progress"   => :absolute,
    "ticks"         => :counter,
    "aveq"          => :counter,
  }

  def initialize(config)
    @device_map = {
      "data" => "cciss/c0d1",
    }
  end

  #  104    0 cciss/c0d0 12890 8017 621864 20297 11525460 55423899 535599912 14461254 0 1206332 14480492
  def collect
    @metrics = {}
    File.open("/proc/diskstats") do |diskstats|
      diskstats.readlines.each do |line|
        fields = line.chomp.sub(/^\s+/, "").split(/[ ]+/)
        major, minor, device = fields.shift(3)
        @metrics[device] = {}
        FIELDS_ORDERED.each_with_index do |metric, index|
          @metrics[device][metric] = fields[index].to_i
        end
      end
    end

    true
  end

  def each_metric
    @device_map.each do |name, device|
      next unless @metrics[device]
      @metrics[device].each do |metric, value|
        yield "#{name}_#{metric}", value, FIELDS[metric]
      end
    end

    true
  end

  def each_derived_metric(sample)
    @device_map.each do |name, device|
      next unless @metrics[device]
      ["r", "w"].each do |type|
        ticks = sample.data["#{name}_#{type}_ticks.rate"]
        ios   = sample.data["#{name}_#{type}_ios.rate"]
        if ticks && ios
          yield "#{name}_#{type}_svctm",
            ticks[:value] / ios[:value],
            :absolute
        end
      end
    end
  end
end
