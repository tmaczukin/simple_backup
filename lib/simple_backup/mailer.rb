require 'mail'
require 'socket'

module SimpleBackup
  class Mailer
    def initialize(dsl, storage)
      @dsl = dsl
      @storage = storage

      @to = []
      @cc = []
      @bcc = []
      @hostname = Socket.gethostbyname(Socket.gethostname).first
    end

    def subject_prefix(prefix)
      @subject_prefix = prefix
    end

    def from(from)
      @from = from
    end

    def to(to)
      @to << to
    end

    def cc(cc)
      @cc << cc
    end

    def bcc(bcc)
      @bcc << bcc
    end

    def send
      Logger::scope_start :info, "Sending e-mail notification"

      Logger::info "Setting sender to: #{@from}"
      from = @from
      Logger::scope_start :info, "Adding recipients:"
      to = @to
      to.each do |mail|
        Logger::info "to: #{mail}"
      end
      cc = @cc
      cc.each do |mail|
        Logger::info "cc: #{mail}"
      end
      bcc = @bcc
      bcc.each do |mail|
        Logger::info "bcc: #{mail}"
      end
      Logger::scope_end

      @subject_prefix += '[FAILED]' if SimpleBackup.status == :failed

      subject = "%s Backup %s for %s" % [@subject_prefix, TIMESTAMP, @hostname]
      Logger::debug "Subject: #{subject}"

      body = get_body

      mail = Mail.new do
        from    from
        to      to
        cc      cc
        bcc     bcc
        subject subject.strip
        body    body
      end

      mail.delivery_method :sendmail
      Logger::debug "Setting delivery method to sendmail"

      mail.deliver
      Logger::info "Notification sent"

      Logger::scope_end
    end

    private
    def get_body
      sources = ''
      @dsl.sources.each do |type, srcs|
        sources += "+ %s:\n" % type.to_s
        srcs.each do |src|
          sources += "  - %s\n" % src
        end
      end

      backup_files = ''
      @storage.created_files.each do |file|
        backup_files += "- %s\n" % file
      end

      body = <<MAIL
Hi,

Backup #{TIMESTAMP} was created!

Backup contains:
#{sources}
Created backup files:
#{backup_files}
Disk usage after backup:
#{disk_usage}
Backup log:
------------
#{Logger::buffer.join("\n")}
------------

Have a nice day,
  Backuper

-- 
Mail was send automatically
Do not respond!
MAIL

     body
   end

   def disk_usage
     content = "%16s %25s %12s %12s %12s  %12s\n" % ['Mount', 'Filesystem', 'Size', 'Used', 'Available', 'Percent used']

     usage = Utils::Disk::usage
     usage[:mounts].each do |m|
       percent_usage = (m[:percent] * 100).to_s
       percent_usage = '(!!) ' + percent_usage if m[:high_usage_exceeded]
       content += "%16s %25s %8s MiB %8s MiB %8s MiB  %11s%%\n" % [m[:mount], m[:fs], m[:size], m[:used], m[:available], percent_usage]
     end

     content += "\nHigh usage treshold exceeded!\nMax usage is #{usage[:high_usage]} where treshold is set to #{Utils::Disk::high_usage_treshold}\n" if usage[:high_usage_exceeded]

     content
   end
  end
end
