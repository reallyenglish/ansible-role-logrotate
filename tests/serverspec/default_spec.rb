require "spec_helper"
require "serverspec"

logrotate_d = "/etc/logrotate.d"
logrotate_conf = "/etc/logrotate.conf"
logrotate_bin = "/usr/sbin/logrotate"
su = "root syslog"

case os[:family]
when "freebsd"
  logrotate_d = "/usr/local/etc/logrotate.d"
  logrotate_conf = "/usr/local/etc/logrotate.conf"
  logrotate_bin = "/usr/local/sbin/logrotate"
  su = "root wheel"
when "redhat"
  su = "root root"
end

case os[:family]
when "freebsd"
  describe cron do
    it { should have_entry "0 * * * * /usr/bin/env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin logrotate /usr/local/etc/logrotate.conf >/dev/null" }
  end
end

describe file(logrotate_d) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe file(logrotate_conf) do
  it { should exist }
  it { should be_file }
  its(:content) { should match(/^su #{ su }$/) }
  its(:content) { should match(/rotate 30/) }
  its(:content) { should match(/^daily$/) }
  its(:content) { should match(/^dateext/) }
  its(:content) { should match(/include #{Regexp.quote(logrotate_d)}/) }
end

describe command("#{logrotate_bin} #{logrotate_conf}") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
end

case os[:family]
when "freebsd"

  describe file("#{logrotate_d}/logstash") do
    its(:content) { should match(/#{Regexp.escape("/var/log/logstash.log")}/) }
    its(:content) { should match(/compress/) }
    its(:content) { should match(/delaycompress/) }
    its(:content) { should match(/daily/) }
    its(:content) { should match(/rotate 30/) }
    its(:content) { should match(/copytruncate/) }
  end

when "redhat"

  describe file("#{logrotate_d}/syslog") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
  compress
  delaycompress
  missingok
  daily
  rotate 30
  sharedscripts
  postrotate
    /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
  endscript
}
__EOR__
                                )
    end
  end

  describe file("#{logrotate_d}/yum") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/yum.log
{
  compress
  delaycompress
  missingok
  notifempty
  create 0600 root root
  size 30k
  yearly
  rotate 30
}
__EOR__
                                )
    end
  end

when "ubuntu"
  describe file("#{logrotate_d}/apt") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/apt/term.log
/var/log/apt/history.log
{
  compress
  delaycompress
  missingok
  notifempty
  monthly
  rotate 12
}
__EOR__
                                )
    end
  end

  describe file("#{logrotate_d}/btmp") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/btmp
{
  compress
  delaycompress
  missingok
  create 0660 root utmp
  su root syslog
  monthly
  rotate 1
}
__EOR__
                                )
    end
  end
  describe file("#{logrotate_d}/dpkg") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/dpkg.log
/var/log/alternatives.log
{
  compress
  delaycompress
  missingok
  notifempty
  create 644 root root
  su root syslog
  monthly
  rotate 12
}
__EOR__
                                )
    end
  end

  describe file("#{logrotate_d}/rsyslog") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/syslog
{
  compress
  delaycompress
  missingok
  notifempty
  su root syslog
  daily
  rotate 7
  postrotate
    reload rsyslog >/dev/null 2>&1 || true
  endscript
}
__EOR__
                                )
    end
  end

  describe file("#{logrotate_d}/rsyslog_others") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
  compress
  delaycompress
  missingok
  notifempty
  su root syslog
  weekly
  rotate 4
  sharedscripts
  postrotate
    reload rsyslog >/dev/null 2>&1 || true
  endscript
}
__EOR__
                                )
    end
  end
  describe file("#{logrotate_d}/unattended-upgrades") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/unattended-upgrades/unattended-upgrades.log
/var/log/unattended-upgrades/unattended-upgrades-shutdown.log
{
  compress
  delaycompress
  missingok
  notifempty
  monthly
  rotate 6
}
__EOR__
                                )
    end
  end
  describe file("#{logrotate_d}/upstart") do
    its(:content) do
      should match Regexp.escape(<<__EOR__
/var/log/upstart/*.log
{
  compress
  delaycompress
  missingok
  notifempty
  nocreate
  daily
  rotate 7
}
__EOR__
                                )
    end
  end
end

describe file("#{logrotate_d}/compress") do
  it { should be_file }
  its(:content) { should match(/^#{ Regexp.escape("/var/log/compress.log") }$/) }
  its(:content) { should match(/compress$/) }
  its(:content) { should match(/delaycompress$/) }
  its(:content) { should match(/missingok$/) }
  its(:content) { should match(/copytruncate$/) }
  its(:content) { should match(/daily$/) }
  its(:content) { should match(/rotate 30$/) }
  its(:content) { should match(%r{compresscmd (?:/usr)?/bin/bzip2}) }
  its(:content) { should match(%r{uncompresscmd (?:/usr)?/bin/bunzip2}) }
  its(:content) { should match(/compressext \.bz2$/) }
end
