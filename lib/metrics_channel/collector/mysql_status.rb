require "metrics_channel/mysql_collector"

class MetricsChannel::Collector::MysqlStatus < MetricsChannel::MysqlCollector
  def self.name
    "mysql_status"
  end

  MYSQL_STATUS_TYPES = {
    "Aborted_clients"                             => :counter,   # | 1           |
    "Aborted_connects"                            => :counter,   # | 0           |
    "Binlog_cache_disk_use"                       => :absolute,  # | 0           |
    "Binlog_cache_use"                            => :absolute,   # | 0           |
    "Binlog_stmt_cache_disk_use"                  => :absolute,   # | 0           |
    "Binlog_stmt_cache_use"                       => :absolute,   # | 0           |
    "Bytes_received"                              => :counter,   # | 3443713     |
    "Bytes_sent"                                  => :counter,   # | 43265011    |
    #"Com_admin_commands"                          => :counter,   # | 0           |
    #"Com_assign_to_keycache"                      => :counter,   # | 0           |
    #"Com_alter_db"                                => :counter,   # | 0           |
    #"Com_alter_db_upgrade"                        => :counter,   # | 0           |
    #"Com_alter_event"                             => :counter,   # | 0           |
    #"Com_alter_function"                          => :counter,   # | 0           |
    #"Com_alter_procedure"                         => :counter,   # | 0           |
    #"Com_alter_server"                            => :counter,   # | 0           |
    #"Com_alter_table"                             => :counter,   # | 0           |
    #"Com_alter_tablespace"                        => :counter,   # | 0           |
    #"Com_analyze"                                 => :counter,   # | 0           |
    "Com_begin"                                   => :counter,   # | 0           |
    #"Com_binlog"                                  => :counter,   # | 0           |
    #"Com_call_procedure"                          => :counter,   # | 0           |
    "Com_change_db"                               => :counter,   # | 1           |
    #"Com_change_master"                           => :counter,   # | 0           |
    #"Com_check"                                   => :counter,   # | 0           |
    #"Com_checksum"                                => :counter,   # | 0           |
    "Com_commit"                                  => :counter,   # | 0           |
    #"Com_create_db"                               => :counter,   # | 0           |
    #"Com_create_event"                            => :counter,   # | 0           |
    #"Com_create_function"                         => :counter,   # | 0           |
    #"Com_create_index"                            => :counter,   # | 0           |
    #"Com_create_procedure"                        => :counter,   # | 0           |
    #"Com_create_server"                           => :counter,   # | 0           |
    #"Com_create_table"                            => :counter,   # | 0           |
    #"Com_create_trigger"                          => :counter,   # | 0           |
    #"Com_create_udf"                              => :counter,   # | 0           |
    #"Com_create_user"                             => :counter,   # | 0           |
    #"Com_create_view"                             => :counter,   # | 0           |
    #"Com_dealloc_sql"                             => :counter,   # | 0           |
    "Com_delete"                                  => :counter,   # | 0           |
    "Com_delete_multi"                            => :counter,   # | 0           |
    #"Com_do"                                      => :counter,   # | 0           |
    #"Com_drop_db"                                 => :counter,   # | 0           |
    #"Com_drop_event"                              => :counter,   # | 0           |
    #"Com_drop_function"                           => :counter,   # | 0           |
    #"Com_drop_index"                              => :counter,   # | 0           |
    #"Com_drop_procedure"                          => :counter,   # | 0           |
    #"Com_drop_server"                             => :counter,   # | 0           |
    #"Com_drop_table"                              => :counter,   # | 0           |
    #"Com_drop_trigger"                            => :counter,   # | 0           |
    #"Com_drop_user"                               => :counter,   # | 0           |
    #"Com_drop_view"                               => :counter,   # | 0           |
    "Com_empty_query"                             => :counter,   # | 0           |
    "Com_execute_sql"                             => :counter,   # | 0           |
    #"Com_flush"                                   => :counter,   # | 0           |
    #"Com_grant"                                   => :counter,   # | 0           |
    "Com_ha_close"                                => :counter,   # | 0           |
    "Com_ha_open"                                 => :counter,   # | 0           |
    "Com_ha_read"                                 => :counter,   # | 0           |
    #"Com_help"                                    => :counter,   # | 0           |
    "Com_insert"                                  => :counter,   # | 0           |
    "Com_insert_select"                           => :counter,   # | 0           |
    #"Com_install_plugin"                          => :counter,   # | 0           |
    "Com_kill"                                    => :counter,   # | 2           |
    "Com_load"                                    => :counter,   # | 0           |
    "Com_lock_tables"                             => :counter,   # | 0           |
    #"Com_optimize"                                => :counter,   # | 0           |
    #"Com_preload_keys"                            => :counter,   # | 0           |
    "Com_prepare_sql"                             => :counter,   # | 0           |
    #"Com_purge"                                   => :counter,   # | 0           |
    #"Com_purge_before_date"                       => :counter,   # | 0           |
    #"Com_release_savepoint"                       => :counter,   # | 0           |
    #"Com_rename_table"                            => :counter,   # | 0           |
    #"Com_rename_user"                             => :counter,   # | 0           |
    #"Com_repair"                                  => :counter,   # | 0           |
    "Com_replace"                                 => :counter,   # | 0           |
    "Com_replace_select"                          => :counter,   # | 0           |
    #"Com_reset"                                   => :counter,   # | 0           |
    #"Com_resignal"                                => :counter,   # | 0           |
    #"Com_revoke"                                  => :counter,   # | 0           |
    #"Com_revoke_all"                              => :counter,   # | 0           |
    "Com_rollback"                                => :counter,   # | 0           |
    "Com_rollback_to_savepoint"                   => :counter,   # | 0           |
    "Com_savepoint"                               => :counter,   # | 0           |
    "Com_select"                                  => :counter,   # | 69767       |
    "Com_set_option"                              => :counter,   # | 0           |
    #"Com_signal"                                  => :counter,   # | 0           |
    #"Com_show_authors"                            => :counter,   # | 0           |
    #"Com_show_binlog_events"                      => :counter,   # | 0           |
    #"Com_show_binlogs"                            => :counter,   # | 0           |
    #"Com_show_charsets"                           => :counter,   # | 0           |
    #"Com_show_collations"                         => :counter,   # | 0           |
    #"Com_show_contributors"                       => :counter,   # | 0           |
    #"Com_show_create_db"                          => :counter,   # | 0           |
    #"Com_show_create_event"                       => :counter,   # | 0           |
    #"Com_show_create_func"                        => :counter,   # | 0           |
    #"Com_show_create_proc"                        => :counter,   # | 0           |
    #"Com_show_create_table"                       => :counter,   # | 0           |
    #"Com_show_create_trigger"                     => :counter,   # | 0           |
    #"Com_show_databases"                          => :counter,   # | 4           |
    #"Com_show_engine_logs"                        => :counter,   # | 0           |
    #"Com_show_engine_mutex"                       => :counter,   # | 0           |
    #"Com_show_engine_status"                      => :counter,   # | 0           |
    #"Com_show_events"                             => :counter,   # | 0           |
    #"Com_show_errors"                             => :counter,   # | 0           |
    #"Com_show_fields"                             => :counter,   # | 10          |
    #"Com_show_function_status"                    => :counter,   # | 0           |
    #"Com_show_grants"                             => :counter,   # | 0           |
    #"Com_show_keys"                               => :counter,   # | 0           |
    #"Com_show_master_status"                      => :counter,   # | 0           |
    #"Com_show_open_tables"                        => :counter,   # | 0           |
    #"Com_show_plugins"                            => :counter,   # | 0           |
    #"Com_show_privileges"                         => :counter,   # | 0           |
    #"Com_show_procedure_status"                   => :counter,   # | 0           |
    #"Com_show_processlist"                        => :counter,   # | 0           |
    #"Com_show_profile"                            => :counter,   # | 0           |
    #"Com_show_profiles"                           => :counter,   # | 0           |
    #"Com_show_relaylog_events"                    => :counter,   # | 0           |
    #"Com_show_slave_hosts"                        => :counter,   # | 0           |
    #"Com_show_slave_status"                       => :counter,   # | 0           |
    #"Com_show_status"                             => :counter,   # | 17209       |
    #"Com_show_storage_engines"                    => :counter,   # | 0           |
    #"Com_show_table_status"                       => :counter,   # | 0           |
    #"Com_show_tables"                             => :counter,   # | 4           |
    #"Com_show_triggers"                           => :counter,   # | 0           |
    #"Com_show_variables"                          => :counter,   # | 2           |
    #"Com_show_warnings"                           => :counter,   # | 0           |
    #"Com_slave_start"                             => :counter,   # | 0           |
    #"Com_slave_stop"                              => :counter,   # | 0           |
    "Com_stmt_close"                              => :counter,   # | 0           |
    "Com_stmt_execute"                            => :counter,   # | 0           |
    "Com_stmt_fetch"                              => :counter,   # | 0           |
    "Com_stmt_prepare"                            => :counter,   # | 0           |
    "Com_stmt_reprepare"                          => :counter,   # | 0           |
    "Com_stmt_reset"                              => :counter,   # | 0           |
    "Com_stmt_send_long_data"                     => :counter,   # | 0           |
    #"Com_truncate"                                => :counter,   # | 0           |
    #"Com_uninstall_plugin"                        => :counter,   # | 0           |
    #"Com_unlock_tables"                           => :counter,   # | 0           |
    "Com_update"                                  => :counter,   # | 0           |
    "Com_update_multi"                            => :counter,   # | 0           |
    #"Com_xa_commit"                               => :counter,   # | 0           |
    #"Com_xa_end"                                  => :counter,   # | 0           |
    #"Com_xa_prepare"                              => :counter,   # | 0           |
    #"Com_xa_recover"                              => :counter,   # | 0           |
    #"Com_xa_rollback"                             => :counter,   # | 0           |
    #"Com_xa_start"                                => :counter,   # | 0           |
    #"Compression"                                 => :discard,   # | OFF         |
    "Connections"                                 => :counter,   # | 53          |
    "Created_tmp_disk_tables"                     => :counter,   # | 0           |
    "Created_tmp_files"                           => :counter,   # | 5           |
    "Created_tmp_tables"                          => :counter,   # | 17242       |
    #"Delayed_errors"                              => :counter,   # | 0           |
    #"Delayed_insert_threads"                      => :counter,   # | 0           |
    #"Delayed_writes"                              => :counter,   # | 0           |
    #"Flush_commands"                              => :counter,   # | 1           |
    "Handler_commit"                              => :counter,   # | 23          |
    "Handler_delete"                              => :counter,   # | 0           |
    #"Handler_discover"                            => :counter,   # | 0           |
    #"Handler_prepare"                             => :counter,   # | 0           |
    "Handler_read_first"                          => :counter,   # | 34          |
    "Handler_read_key"                            => :counter,   # | 3133470     |
    "Handler_read_last"                           => :counter,   # | 0           |
    "Handler_read_next"                           => :counter,   # | 0           |
    "Handler_read_prev"                           => :counter,   # | 0           |
    "Handler_read_rnd"                            => :counter,   # | 510         |
    "Handler_read_rnd_next"                       => :counter,   # | 6268934     |
    "Handler_rollback"                            => :counter,   # | 3           |
    "Handler_savepoint"                           => :counter,   # | 0           |
    "Handler_savepoint_rollback"                  => :counter,   # | 0           |
    "Handler_update"                              => :counter,   # | 3132930     |
    "Handler_write"                               => :counter,   # | 945587      |
    "Innodb_buffer_pool_LRU_search_scanned"       => :counter,   # | 256937      |
    "Innodb_buffer_pool_LRU_unzip_search_scanned" => :counter,   # | 0           |
    "Innodb_buffer_pool_LRU_get_free_search"      => :counter,   # | 265128      |
    "Innodb_buffer_pool_flush_LRU_batch_scanned"  => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_LRU_page_count"     => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_adaptive_pages"     => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_anticipatory_pages" => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_background_pages"   => :counter,   # | 1           |
    "Innodb_buffer_pool_flush_batch_scanned"      => :counter,   # | 1           |
    "Innodb_buffer_pool_flush_max_dirty_pages"    => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_neighbor_pages"     => :counter,   # | 0           |
    "Innodb_buffer_pool_flush_sync_page"          => :counter,   # | 0           |
    "Innodb_buffer_pool_pages_data"               => :absolute,  # | 8191        |
    "Innodb_buffer_pool_pages_dirty"              => :absolute,  # | 0           |
    "Innodb_buffer_pool_pages_flushed"            => :counter,   # | 1           |
    "Innodb_buffer_pool_pages_free"               => :absolute,  # | 0           |
    "Innodb_buffer_pool_pages_misc"               => :absolute,  # | 0           |
    "Innodb_buffer_pool_pages_total"              => :absolute,  # | 8191        |
    "Innodb_buffer_pool_read_ahead_rnd"           => :counter,   # | 0           |
    "Innodb_buffer_pool_read_ahead"               => :counter,   # | 0           |
    "Innodb_buffer_pool_read_ahead_evicted"       => :counter,   # | 7191        |
    "Innodb_buffer_pool_read_requests"            => :counter,   # | 1225175     |
    "Innodb_buffer_pool_reads"                    => :counter,   # | 265128      |
    "Innodb_buffer_pool_wait_free"                => :counter,   # | 0           |
    "Innodb_buffer_pool_write_requests"           => :counter,   # | 1           |
    "Innodb_corrupted_page_reads"                 => :counter,   # | 0           |
    "Innodb_corrupted_table_opens"                => :counter,   # | 0           |
    "Innodb_data_fsyncs"                          => :counter,   # | 7           |
    "Innodb_data_pending_fsyncs"                  => :counter,   # | 0           |
    "Innodb_data_pending_reads"                   => :counter,   # | 0           |
    "Innodb_data_pending_writes"                  => :counter,   # | 0           |
    "Innodb_data_read"                            => :counter,   # | 4346040320  |
    "Innodb_data_reads"                           => :counter,   # | 265138      |
    "Innodb_data_writes"                          => :counter,   # | 7           |
    "Innodb_data_written"                         => :counter,   # | 35328       |
    "Innodb_dblwr_pages_written"                  => :counter,   # | 1           |
    "Innodb_dblwr_writes"                         => :counter,   # | 1           |
    "Innodb_files_open"                           => :absolute,  # | 3           |
    "Innodb_files_opened"                         => :counter,   # | 6           |
    "Innodb_files_closed"                         => :counter,   # | 3           |
    "Innodb_files_flushed"                        => :counter,   # | 7           |
    #"Innodb_have_atomic_builtins"                 => :discard,   # | ON          |
    "Innodb_lock_deadlocks"                       => :counter,   # | 0           |
    "Innodb_log_waits"                            => :counter,   # | 0           |
    "Innodb_log_write_requests"                   => :counter,   # | 0           |
    "Innodb_log_writes"                           => :counter,   # | 2           |
    "Innodb_lsn_current"                          => :absolute,  # | 410120377   |
    "Innodb_lsn_flushed"                          => :absolute,  # | 410120377   |
    "Innodb_lsn_checkpoint"                       => :absolute,  # | 410120377   |
    #"Innodb_mysql_master_log_file"                => :string,    # |             |
    #"Innodb_mysql_master_log_pos"                 => :absolute,  # | 0           |
    "Innodb_os_log_fsyncs"                        => :counter,   # | 5           |
    "Innodb_os_log_pending_fsyncs"                => :absolute,  # | 0           |
    "Innodb_os_log_pending_writes"                => :absolute,  # | 0           |
    "Innodb_os_log_written"                       => :counter,   # | 1024        |
    #"Innodb_page_size"                            => :absolute,  # | 16384       |
    "Innodb_pages_created"                        => :counter,   # | 0           |
    "Innodb_pages_read"                           => :counter,   # | 265127      |
    "Innodb_pages_written"                        => :counter,   # | 1           |
    "Innodb_row_lock_current_waits"               => :absolute,  # | 0           |
    "Innodb_row_lock_time"                        => :absolute,  # | 0           |
    "Innodb_row_lock_time_avg"                    => :absolute,  # | 0           |
    "Innodb_row_lock_time_max"                    => :absolute,  # | 0           |
    "Innodb_row_lock_waits"                       => :counter,   # | 0           |
    "Innodb_rows_deleted"                         => :counter,   # | 0           |
    "Innodb_rows_inserted"                        => :counter,   # | 0           |
    "Innodb_rows_read"                            => :counter,   # | 5306094     |
    "Innodb_rows_updated"                         => :counter,   # | 0           |
    "Innodb_tablespace_files_open"                => :absolute,  # | 3           |
    "Innodb_tablespace_files_opened"              => :counter,   # | 3           |
    "Innodb_tablespace_files_closed"              => :counter,   # | 0           |
    "Innodb_truncated_status_writes"              => :counter,   # | 0           |
    "Key_blocks_not_flushed"                      => :counter,   # | 0           |
    "Key_blocks_unused"                           => :absolute,  # | 6698        |
    "Key_blocks_used"                             => :absolute,  # | 0           |
    "Key_read_requests"                           => :counter,   # | 0           |
    "Key_reads"                                   => :counter,   # | 0           |
    "Key_write_requests"                          => :counter,   # | 0           |
    "Key_writes"                                  => :counter,   # | 0           |
    #"Last_query_cost"                             => :absolute,  # | 0.000000    |
    "Max_statement_time_exceeded"                 => :counter,   # | 0           |
    "Max_statement_time_set"                      => :counter,   # | 0           |
    "Max_statement_time_set_failed"               => :counter,   # | 0           |
    #"Max_used_connections"                        => :absolute,  # | 3           |
    #"Not_flushed_delayed_rows"                    => :counter,   # | 0           |
    "Open_files"                                  => :absolute,  # | 18          |
    "Open_streams"                                => :absolute,  # | 0           |
    "Open_table_definitions"                      => :absolute,  # | 21          |
    "Open_tables"                                 => :absolute,  # | 15          |
    "Opened_files"                                => :counter,   # | 84          |
    "Opened_table_definitions"                    => :counter,   # | 21          |
    "Opened_tables"                               => :counter,   # | 22          |
    "Prepared_stmt_count"                         => :absolute,  # | 0           |
    "Qcache_free_blocks"                          => :absolute,  # | 0           |
    "Qcache_free_memory"                          => :absolute,  # | 0           |
    "Qcache_hits"                                 => :counter,   # | 0           |
    "Qcache_inserts"                              => :counter,   # | 0           |
    "Qcache_lowmem_prunes"                        => :counter,   # | 0           |
    "Qcache_not_cached"                           => :counter,   # | 0           |
    "Qcache_queries_in_cache"                     => :absolute,  # | 0           |
    "Qcache_total_blocks"                         => :absolute,  # | 0           |
    "Queries"                                     => :counter,   # | 87049       |
    "Questions"                                   => :counter,   # | 87049       |
    #"Rpl_status"                                  => :string,    # | AUTH_MASTER |
    "Select_full_join"                            => :counter,   # | 0           |
    "Select_full_range_join"                      => :counter,   # | 0           |
    "Select_range"                                => :counter,   # | 0           |
    "Select_range_check"                          => :counter,   # | 0           |
    "Select_scan"                                 => :counter,   # | 17252       |
    #"Slave_heartbeat_period"                      => :absolute,  # | 0.000       |
    #"Slave_open_temp_tables"                      => :absolute,  # | 0           |
    #"Slave_received_heartbeats"                   => :counter,   # | 0           |
    #"Slave_retried_transactions"                  => :counter,   # | 0           |
    #"Slave_running"                               => :string,    # | OFF         |
    "Slow_launch_threads"                         => :counter,   # | 0           |
    "Slow_queries"                                => :counter,   # | 0           |
    "Sort_merge_passes"                           => :counter,   # | 0           |
    "Sort_range"                                  => :counter,   # | 0           |
    "Sort_rows"                                   => :counter,   # | 510         |
    "Sort_scan"                                   => :counter,   # | 17          |
    "Table_locks_immediate"                       => :counter,   # | 51          |
    "Table_locks_waited"                          => :counter,   # | 0           |
    #"Tc_log_max_pages_used"                       => :counter,   # | 0           |
    #"Tc_log_page_size"                            => :counter,   # | 0           |
    #"Tc_log_page_waits"                           => :counter,   # | 0           |
    "Threads_cached"                              => :absolute,  # | 0           |
    "Threads_connected"                           => :counter,   # | 2           |
    "Threads_created"                             => :counter,   # | 52          |
    "Threads_running"                             => :absolute,  # | 1           |
    "Uptime"                                      => :counter,   # | 1216727     |
    "Uptime_since_flush_status"                   => :counter,   # | 1216727     |
  }

  def collect
    @metrics = {}
    result = query("SHOW GLOBAL STATUS")
    result.each_hash do |row|
      @metrics[row["Variable_name"]] = row["Value"]
    end

    true
  end

  def time
    if @metrics
      @metrics['Uptime_since_flush_status']
    end
  end

  def each_metric
    unless @metrics
      raise "No metrics to iterate; call collect first?"
    end

    @metrics.each do |name, value|
      if type = MYSQL_STATUS_TYPES[name]
        yield name, value, type
      end
    end

    nil
  end

  def reset
    @metrics = nil
  end
end