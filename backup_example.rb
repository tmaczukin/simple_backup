#!/usr/bin/env ruby

require 'simple_backup'

SimpleBackup.run do
#  log_level           :debug
  backup_dir          '/backup'
  high_usage_treshold 0.9
  check_disk_path     '/'
  check_disk_path     '/backup'
  check_disk_path     '/home/app'

  apps do
    keep_last 9

    app '/home/app/app-1', type: :capistrano
    app '/home/app/app-2', type: :bare
  end

  mysql do
    keep_last 9

    host 'localhost'
    port 3306
    user 'backup'
    pass 'backup'
    db   'test1'
    db   'test2', exclude_tables: ['t_test1']
  end

  mailer do
    subject_prefix '[BACKUP]'

    from 'backup@localhost'
    to   'root@localhost'
    cc   'root@localhost'
    bcc  'root@localhost'
  end
end
