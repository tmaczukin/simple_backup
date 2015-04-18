#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'simple_backup'

SimpleBackup.run do
  log_level  :debug

  high_usage_treshold 0.9
  check_disk_path     '/'
  check_disk_path     '/backup'
  check_disk_path     '/home/app'

  default_keep_last 9

  sources do
    dir 'app-1', '/home/app/app-1', type: :capistrano
    dir 'app-2', '/home/app/app-2'
    dir 'none',  '/none'

    file 'hosts', '/etc/hosts'

    mysql 'test1', 'test1'
    mysql 'test2', 'test2'
    mysql 'test3', 'test3', exclude_tables: ['t_test1']
  end

  mysql do
    host 'localhost'
    port 3306
    user 'root'
    pass 'root'
  end

  mailer do
    subject_prefix '[BACKUP]'

    from 'backup@localhost'
    to   'root@localhost'
    cc   'rb@localhost'
    bcc  'root@localhost'
  end
end
