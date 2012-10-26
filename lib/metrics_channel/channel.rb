require "amqp"

class MetricsChannel::Channel
  def initialize(broker_host)    
    @broker_host = broker_host
    @connection = nil
    @channel = nil

    connect
  end

  def connect
    @connection = AMQP.connect(:host => @broker_host)
    @channel = AMQP::Channel.new(@connection)

    @channel.on_error do |channel, close|
      puts "Reconnecting after channel error"
      connect
    end
  end

  def send_metrics(period, metrics, routing_key, headers)
    @channel.headers("period.#{period}ms").
      publish(Marshal.dump(metrics), :routing_key => routing_key, :headers => headers)
  end

  def send_periodic_metrics(period, r_class, r_name, r_type)
    routing_key = "#{r_class}.#{r_name}.#{r_type}"
    headers = {
      :class  => r_class,
      :name   => r_name,
      :type   => r_type,
      :period => period,
    }
    EventMachine.add_periodic_timer(period.to_f / 1000.0) do
      if sample = yield
        send_metrics(period, sample, routing_key, headers)
      end
    end
  end

  def establish_queue
    @queue = @channel.queue("", :exclusive => true)
  end

  def subscribe_period(period, match_policy="any", opts={})
    unless @queue
      raise RuntimeError.new("No queue established; use establish_queue first")
    end

    unless opts.empty?
      arguments = opts.dup
      arguments["x-match"] = match_policy
    end
    
    exchange = @channel.headers("period.#{period}ms")
    @queue.bind(exchange, :arguments => arguments)
  end

  def receive
    @queue.subscribe do |metadata, payload|
      yield metadata, Marshal.load(payload)
    end
  end
  
  def close
    @connection.close { yield }
  end
end