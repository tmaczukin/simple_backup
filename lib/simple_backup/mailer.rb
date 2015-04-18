require 'mail'
require 'socket'

module SimpleBackup
  class Mailer
    @@logger = Logger.instance
    @@sources = Sources.instance

    def initialize()
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
      @@logger.scope_start :info, "Sending e-mail notification"

      @@logger.info "Setting sender to: #{@from}"
      from = @from
      @@logger.scope_start :info, "Adding recipients:"
      to = @to
      to.each do |mail|
        @@logger.info "to: #{mail}"
      end
      cc = @cc
      cc.each do |mail|
        @@logger.info "cc: #{mail}"
      end
      bcc = @bcc
      bcc.each do |mail|
        @@logger.info "bcc: #{mail}"
      end
      @@logger.scope_end

      @subject_prefix += '[FAILED]' if SimpleBackup.status == :failed

      subject = "%s Backup %s for %s" % [@subject_prefix, TIMESTAMP, @hostname]
      @@logger.debug "Subject: #{subject}"

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
      @@logger.debug "Setting delivery method to sendmail"

      mail.deliver
      @@logger.info "Notification sent"

      @@logger.scope_end
    end

    private
    def get_body
      sources = ''

      @@sources.each do |name, source|
        sources += " - %s\n" % source.desc
      end

      backup_files = ''
      @@sources.backup_files.each do |f|
        backup_files += " - %s\n" % f[:file]
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
#{@@logger.buffer.join("\n")}
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
