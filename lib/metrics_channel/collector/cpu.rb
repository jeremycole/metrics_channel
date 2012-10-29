require "pp"

class MetricsChannel::Collector::Cpu < MetricsChannel::Collector
  def self.name
    "cpu"
  end

  CPU_FIELDS = [
    "user",       # Normal processes in user mode
    "nice",       # Niced processes in user mode
    "system",     # Kernel mode
    "idle",       # Executing the idle task
    "iowait",     # Waiting for I/O to complete
    "irq",        # Servicing interrupts
    "softirq",    # Servicing softirqs
    "steal",      # Involuntarily waiting
    "guest",      # Running a normal guest (Xen)
    "guest_nice", # Running a niced guest (Xen)
  ]

  def getconf(name)
    %x{/usr/bin/getconf #{name}}.chomp
  end

  def initialize(config)
    # The system's configured HZ (jiffies per second) value. This is needed
    # to calculate CPU in percent instead of jiffies.
    @HZ   = getconf("CLK_TCK").to_f
    # Number of processors online.
    @CPUS = getconf("_NPROCESSORS_ONLN").to_f
  end

  def collect
    @metrics = {}
    File.open("/proc/stat") do |diskstats|
      diskstats.readlines.each do |line|
        fields = line.chomp.split(/[ ]+/)
        name = fields.shift
        case name
        when /^cpu[0-9]+/
          # Ignore.
        when /^cpu/
          fields.each_with_index do |field, index|
            field_name = CPU_FIELDS[index]
            @metrics["#{name}_#{field_name}_jiffies"] = {
              :value => field.to_i,
              :type  => :counter,
            }
          end
        when "intr"
          # Need to parse all interrupts.
        when /^procs_/
          @metrics[name] = {
            :value => fields.first,
            :type  => :absolute,
          }
        when "btime"
          # Ignore system boot time, as it is static.
        else
          @metrics[name] = {
            :value => fields.first,
            :type  => :counter,
          }
        end
      end
    end

    true
  end

  def each_metric
    @metrics.each do |name, metric|
      yield name, metric[:value], metric[:type]
    end

    true
  end

  def jiffies_to_percent(jiffies, cpus=1)
    100.0 * (jiffies / cpus / @HZ) * 1000.0
  end

  def each_derived_metric(sample)
    CPU_FIELDS.each do |metric|
      if jiffies = sample.data["cpu_#{metric}_jiffies.rate"]
        yield "cpu_#{metric}_percent",
          jiffies_to_percent(jiffies[:value], @CPUS),
          :absolute
      end
    end
  end
end
