require 'mysql'

class MetricsChannel::MysqlCollector < MetricsChannel::Collector
  def initialize
    @mysql = Mysql.new("localhost", "root", "")
  end
end