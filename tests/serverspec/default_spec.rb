require 'spec_helper'
require 'serverspec'

logrotate_d = '/etc/logrotate.d'
logrotate_conf = '/etc/logrotate.conf'
logrotate_bin = '/usr/sbin/logrotate'

case os[:family]
when 'freebsd'
  logrotate_d = '/usr/local/etc/logrotate.d'
  logrotate_conf = '/usr/local/etc/logrotate.conf'
  logrotate_bin = '/usr/local/sbin/logrotate'
when 'ubuntu'
end

case os[:family]
when 'freebsd'
  describe cron do
    it { should have_entry '0 * * * * /usr/bin/env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin logrotate /usr/local/etc/logrotate.conf >/dev/null' }
  end
when 'ubuntu'
end

describe file(logrotate_d) do
  it { should be_directory }
  it { should be_mode 755 }
end

describe file(logrotate_conf) do
  it { should exist }
  it { should be_file }
  its(:content) { should match /rotate 30/ }
  its(:content) { should match /^daily$/ }
  its(:content) { should match /^dateext/ }
  its(:content) { should match /include #{Regexp.quote(logrotate_d)}/ }
end

describe command("#{logrotate_bin} #{logrotate_conf}") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match /^$/ }
end

case os[:family]
when 'freebsd'
  describe file("#{logrotate_d}/logstash") do
    its(:content) { should match Regexp.quote('/var/log/logstash.log') }
    its(:content) { should match /compress/ }
    its(:content) { should match /delaycompress/ }
    its(:content) { should match /daily/ }
    its(:content) { should match /rotate 30/ }
    its(:content) { should match /copytruncate/ }
  end
when 'ubuntu'
  describe file("#{ logrotate_d }/apt") do
    its(:content) { should match Regexp.escape(<<__EOR__
/var/log/apt/term.log
/var/log/apt/history.log
{
  rotate 12
  monthly
  compress
  missingok
  notifempty
}
__EOR__
                                              )}
  end

  describe file("#{ logrotate_d }/dpkg") do
    its(:content) { should match Regexp.escape(<<__EOR__
/var/log/alternatives.log
/var/log/dpkg.log
{
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
__EOR__
                                              )}
  end

  describe file("#{ logrotate_d }/rsyslog") do
    its(:content) { should match Regexp.escape(<<__EOR__
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        reload rsyslog >/dev/null 2>&1 || true
    endscript
}
__EOR__
                                              )}
  end

  describe file("#{ logrotate_d }/rsyslog_others") do
    its(:content) { should match Regexp.escape(<<__EOR__
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
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        reload rsyslog >/dev/null 2>&1 || true
    endscript
}
__EOR__
                                              )}
  end
  describe file("#{ logrotate_d }/unattended-upgrades") do
    its(:content) { should match Regexp.escape(<<__EOR__
/var/log/unattended-upgrades/unattended-upgrades.log 
/var/log/unattended-upgrades/unattended-upgrades-shutdown.log
{
  rotate 6
  monthly
  compress
  missingok
  notifempty
}
__EOR__
                                              )}
  end
  describe file("#{ logrotate_d }/upstart") do
    its(:content) { should match Regexp.escape(<<__EOR__
/var/log/upstart/*.log {
        daily
        missingok
        rotate 7
        compress
        notifempty
    nocreate
}
__EOR__
                                              )}
  end
end
