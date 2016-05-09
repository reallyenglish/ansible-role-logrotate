require 'spec_helper'
require 'serverspec'

describe cron do
  it { should have_entry '0 * * * * /usr/bin/env PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin logrotate /usr/local/etc/logrotate.conf >/dev/null' }
end

logrotate_d = '/etc/logrotate.d'
logrotate_conf = '/etc/logrotate.conf'
logrotate_bin = '/usr/sbin/logrotate'

case os[:family]
when 'freebsd'
  logrotate_d = '/usr/local/etc/logrotate.d'
  logrotate_conf = '/usr/local/etc/logrotate.conf'
  logrotate_bin = '/usr/local/sbin/logrotate'
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
end

describe file("#{logrotate_d}/logstash") do
  its(:content) { should match Regexp.quote('/var/log/logstash.log') }
  its(:content) { should match /compress/ }
  its(:content) { should match /delaycompress/ }
  its(:content) { should match /daily/ }
  its(:content) { should match /rotate 30/ }
  its(:content) { should match /copytruncate/ }
end
