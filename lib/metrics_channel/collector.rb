class MetricsChannel::Collector
  # Find a collector by comparing its name field; return the class of
  # the first exact match.
  def self.by_name(name)
    constants.each do |class_name|
      if const_get(class_name).respond_to?(:name) &&
          (name == const_get(class_name).name)
        return const_get(class_name)
      end
    end
    nil
  end

  def initialize
  end

  # Return the name of this collector. This name will be used in various
  # comparisons to load collectors and find them.
  def self.name
    raise "Collector is abstract and should not be used directly"
  end

  # Defer to the class method in the instance. There is probably no reason
  # to override this method.
  def name
    self.class.name
  end

  # Collect metrics from the underlying system. This is provided as a
  # separate method so that expensive collection can be done separately
  # from the #each_method iterator, and so that cleanup work can be
  # deferred to the #reset method.
  #
  # Nothing needs to be done here necessarily. As long as each_metric
  # can return some stats, everything works.
  def collect
  end

  # Return the current time in some timebase that makes sense for this
  # collector. If the system being collected from can return its own
  # time, this can be used to achieve more accurate results when various
  # aggregations are performed on the data.
  def time
    Time.now.utc.to_f * 1000.0
  end

  # Iterate through all available metrics.
  def each_metric
    raise "Collector is abstract and should not be used directly"
  end

  # Reset any stored data after collection has been completed, if necessary.
  def reset
  end
end

# Load all collectors found in the 'collector' subdirectory.
module_glob = File.dirname(__FILE__) + "/collector/*.rb"
Dir.glob(module_glob).each do |file|
  require file
end
