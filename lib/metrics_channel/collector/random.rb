class MetricsChannel::Collector::Random < MetricsChannel::Collector
  def self.name
    "random"
  end

  def initialize
    @random_value   = 0
    @random_counter = 0
  end

  def collect
    @random_value    = rand(1000)
    @random_counter += rand(1000)
  end

  def each_metric
    yield "random_value",   @random_value,    :absolute
    yield "random_counter", @random_counter,  :counter
  end
end