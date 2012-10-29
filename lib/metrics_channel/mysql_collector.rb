require 'mysql'

class MetricsChannel::MysqlCollector < MetricsChannel::Collector
  def initialize(config)
    @mysql_config = {
      "mysql.host"      => "localhost",
      "mysql.user"      => "root",
      "mysql.password"  => "",
      #"mysql.port"      => nil,
      #"mysql.socket"    => nil,
    }

    @mysql_config.keys.each do |key|
      if config[key]
        @mysql_config[key] = config[key]
      end
    end

    connect
  end

  def connect
    @mysql = Mysql.new(
      @mysql_config["mysql.host"],
      @mysql_config["mysql.user"],
      @mysql_config["mysql.password"]
    )
  end

  def yield_with_retry(retries = 1)
    backoff = 0
    while retries > 0
      begin
        return yield
      rescue Mysql::Error
        puts "%s: Error %d: %s (reconnecting)" % [
          self.class,
          @mysql.errno,
          @mysql.error,
        ]
        # ERROR 2006 (HY000): MySQL server has gone away
        if @mysql.errno == 2006
          sleep((2**backoff).to_f / 1000.0)
          connect
          retries -= 1
          backoff += 1 if backoff < 16
        else
          raise
        end
      end
    end
  end

  def query(sql)
    # This should be handling reconnect, backoff, etc.
    yield_with_retry do
      @mysql.query(sql)
    end
  end
end