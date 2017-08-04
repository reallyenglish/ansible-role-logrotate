require "spec_helper"

sleep 10 if ENV["JENKINS_HOME"]
log_file = "/var/log/foo.log"

shared_examples_for :server do |s|
  let(:current_server) { server(s).server }
  let(:log_file) { log_file }
  let(:log_file_regexp) { Regexp.escape(log_file) }

  it "writes a log entry to #{log_file}" do
    result = current_server.ssh_exec("echo 1st log entry | sudo tee #{log_file}; cat #{log_file}")
    expect(result).to match(/1st log entry/)
  end

  it "runs logrotate -f" do
    conf_path = current_server.ssh_exec("ls /etc/logrotate.conf /usr/local/etc/logrotate.conf 2>/dev/null")
    expect(conf_path).to match(/logrotate\.conf/)

    result = current_server.ssh_exec("sudo logrotate -f -v #{conf_path}")
    expect(result).not_to match(/^\s+log #{ log_file_regexp }.*skipping$/)
    expect(result).to match(/^reading config file foo$/)
    expect(result).to match(/^rotating pattern:\s+#{ log_file_regexp }$/)
    expect(result).to match(/^considering log #{ log_file_regexp }\n\s+log needs rotating$/)
    expect(result).to match(/^renaming #{ log_file_regexp } to #{ log_file_regexp}\.1$/)
  end

  it "creates #{log_file}.1" do
    result = current_server.ssh_exec("ls #{log_file}.1")
    expect(result).to match(/#{ log_file_regexp }\.1/)
    result = current_server.ssh_exec("cat #{log_file}.1")
    expect(result).to match(/1st log entry/)
  end

  it "has foo.log" do
    result = current_server.ssh_exec("ls #{log_file}")
    expect(result).to match(/#{ log_file_regexp }/)
  end

  it "writes second log entry to #{log_file}" do
    result = current_server.ssh_exec("echo 2nd log entry | sudo tee #{log_file}; cat #{log_file}")
    expect(result).to match(/2nd log entry/)
  end

  it "runs logrotate -f" do
    conf_path = current_server.ssh_exec("ls /etc/logrotate.conf /usr/local/etc/logrotate.conf 2>/dev/null")
    expect(conf_path).to match(/logrotate\.conf/)

    result = current_server.ssh_exec("sudo logrotate -f -v #{conf_path}")
    expect(result).not_to match(/^\s+log #{ log_file_regexp }.*skipping$/)
    expect(result).to match(/^reading config file foo$/)
    expect(result).to match(/^rotating pattern:\s+#{ log_file_regexp }$/)
    expect(result).to match(/^considering log #{ log_file_regexp }\n\s+log needs rotating$/)
    expect(result).to match(/^renaming #{ log_file_regexp } to #{ log_file_regexp}\.1$/)
  end

  it "creates #{log_file}.1" do
    result = current_server.ssh_exec("ls #{log_file}.1")
    expect(result).to match(/#{ log_file_regexp }\.1/)
    result = current_server.ssh_exec("cat #{log_file}.1")
    expect(result).to match(/2nd log entry/)
  end

  it "creates #{log_file}.2.bz2" do
    result = current_server.ssh_exec("ls #{log_file}.2.bz2")
    expect(result).to match(/#{ log_file_regexp }\.2\.bz2/)
    result = current_server.ssh_exec("bzcat #{log_file}.2.bz2")
    expect(result).to match(/1st log entry/)
  end
end

context "after provisioning finished" do
  [:server0, :server1, :server2].each do |s|
    it_behaves_like :server, s
  end
end
