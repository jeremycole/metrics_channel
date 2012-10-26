class PeriodicMetrics
  class Sample
    attr_reader :time, :data

    TYPES = {
      :rate     => true,
      :counter  => true,
      :absolute => true,
    }

    def initialize(time=nil)
      @time = time
      @data = {}
    end

    def inspect
      "#{self.class}: time=#{time}, size=#{@data.size}"
    end

    def dump_format(type)
      case type
      when :rate, :counter, :absolute
        "%20.4f"
      else
        "%20s"
      end
    end

    def dump
      puts self.inspect
      @data.sort { |a, b| a[0] <=> b[0] }.each do |name, value|
        puts "  %-40s#{dump_format(value[:type])}%10s" % [
          name,
          value[:value],
          value[:type].to_s,
        ]
      end
    end

    def add(name, value, type)
      @data[name] = { :value => value, :type => type }
    end

    def -(other)
      result = Sample.new(other.time)

      @data.keys.each do |name|
        unless @data.has_key? name and other.data.has_key? name
          result.add(name, nil, nil)
          next
        end
        
        unless @data[name][:type] == other.data[name][:type]
          result.add(name, nil, nil)
          next
        end

        elapsed_time = other.time - time

        case @data[name][:type]
        when :counter
          rated_value = (other.data[name][:value].to_f - @data[name][:value].to_f) / elapsed_time.to_f
          result.add(name + ".rate", rated_value, :rate)
        else
          result.add(name, @data[name][:value], @data[name][:type])
        end
      end
      result
    end

    def self.combine(samples, domain=:time)
      result = Sample.new(samples.first.time)
      result.add(".sample.count", samples.size, :absolute)
      count = Hash.new(0)
      sum = Hash.new(0.0)
      min = Hash.new(nil)
      max = Hash.new(nil)
      samples.first.data.keys.each do |name|
        type = samples.first.data[name][:type]
        samples.each do |sample|
          if sample.data.has_key? name
            value = sample.data[name][:value].to_f
            count[name] += 1
            min[name] ||= value
            min[name] = value < min[name] ? value : min[name]
            max[name] ||= value
            max[name] = value > max[name] ? value : max[name]
            sum[name] += sample.data[name][:value].to_f
          end
        end

        if domain == :space
          result.add(name + ".sum", sum[name], type)
        end

        result.add(name + ".min", min[name], type)
        result.add(name + ".max", max[name], type)
        result.add(name + ".avg", sum[name] / count[name], type)
        #result.add(name + ".count", count[name], :absolute)
      end
      result
    end
  end

  def initialize(sample_length = 2)
    @sample_length = sample_length
    @samples = []
  end

  def add_sample(sample)
    @samples.unshift sample
    @samples.pop if @samples.size > @sample_length
  end

  def collect(time)
    raise "Block not provided" unless block_given?

    sample = Sample.new(time)
    
    while metric = yield
      sample.add(metric[0], metric[1], metric[2])
    end
    
    store_sample(sample)
    sample
  end
  
  def delta
    return nil if @samples.size != 2
    @samples[0] - @samples[1]
  end

  def combine
    PeriodicMetrics::Sample.combine(@samples)
  end

  def prune_older_than(time)
    (@samples.size - 1).downto(0) do |index|
      if @samples[index].time < time
        @samples.delete_at(index)
      else
        break
      end
    end
  end
end