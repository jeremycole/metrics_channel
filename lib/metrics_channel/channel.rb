require "amqp"

class MetricsChannel::Channel
  attr_reader :broker
  attr_reader :session
  attr_reader :channel

  # Initialize a new Channel, broker should be a URI, e.g. "amqp://localhost"
  def initialize(broker)
    @broker = broker
    @session = nil
    @channel = nil
    @pending_metrics = []

    connect
  end

  # Connect to the broker and set up callbacks necessary to handle failures
  # and start dealing with metrics on the channel.
  def connect
    handle_failure = Proc.new do
      puts "AMQP::Session: Failed to connect. Exiting."
      exit 1
    end

    @session = AMQP.connect(@broker,
      :on_tcp_connection_failure => handle_failure)

    @session.on_open do
      puts "AMQP::Session: Connected to %s version %s on %s" % [
        @session.broker.product,
        @session.broker.version,
        @session.broker_endpoint,
      ]
    end

    @session.on_recovery do
      puts "AMQP::Session: Recovered after connection loss."
    end

    #@session.on_closed
    #@session.on_possible_authentication_failure

    @session.on_error do |session, close|
      puts "AMQP::Session: Reconnecting after session error: code = #{close.reply_code}; text = #{close.reply_text}"
      session.reconnect(false, 1)
    end

    @session.on_connection_interruption do |session|
      puts "AMQP::Session: Connection interrupted. Reconnecting."
      session.reconnect(false, 1)
    end
    #@session.on_tcp_connection_failure
    #@session.on_tcp_connection_loss

    @channel = AMQP::Channel.new(@session)
  end

  # Internal method used to store but not immediately send metrics over the
  # channel. Use send_metrics instead.
  def store_pending_metrics(period, metrics, routing_key, headers)
    @pending_metrics.push [period, metrics, routing_key, headers]
  end

  # Internal method used to send any stored (pending) metrics immediately.
  def send_pending_metrics
    while @pending_metrics.size > 0
      period, metrics, routing_key, headers = @pending_metrics.shift
      puts "Sending metrics #{metrics.inspect}"
      @channel.headers("period.#{period}ms").
        publish(Marshal.dump(metrics), :routing_key => routing_key, :headers => headers)
    end
  end

  # 
  def send_metrics(period, metrics, routing_key, headers)
    store_pending_metrics(period, metrics, routing_key, headers)
    if @session.connected?
      send_pending_metrics
    end
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
    @session.close { yield }
  end
end