require "pp"

class MetricsChannel::Collector::NetDev < MetricsChannel::Collector
  def self.name
    "net_dev"
  end

  NET_DEV_FIELDS = [
    "rx_bytes",
    "rx_packets",
    "rx_errors",
    "rx_dropped",
    "rx_fifo",
    "rx_frame",
    "rx_compressed",
    "rx_multicast",
    "tx_bytes",
    "tx_packets",
    "tx_errors",
    "tx_dropped",
    "tx_fifo",
    "tx_collisions",
    "tx_carrier",
    "tx_compressed",
  ]

  def initialize(config)
  end

  def collect
    @metrics = {}
    File.open("/proc/net/dev") do |file|
      lines = file.readlines
      lines.shift(2) # Discard first two lines.

      lines.each do |line|
        fields = line.chomp.sub(/^\s+/, "").split(/[ :]+/)
        device = fields.shift
        next if fields[0].to_i == 0 && fields[1].to_i == 0
        fields.each_with_index do |value, index|
          name = NET_DEV_FIELDS[index]
          @metrics["#{device}/#{name}"] = value.to_i
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
