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

  def query(sql)
    # This should be handling reconnect, backoff, etc.
    @mysql.query(sql)
  end
end