# ansible-role-logrotate

Install logrotate

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| logrotate\_config | path to `logrotate.conf` | {{ \_\_logrotate\_config }} |
| logrotate\_conf\_d | path to `logrotate.d` | {{ \_\_logrotate\_conf\_d }} |
| logrotate\_default\_rotate | the default value of `rotate` in `logrotate.conf` | 30 |
| logrotate\_default\_dateext | the default value of `dateext` in `logrotate.conf` | true |
| logrotate\_default\_dateformat | the default value of `dateformat` in `logrotate.conf` | .%Y%m%d |
| logrotate\_default\_freq | the default value of how often rotate the logs in `logrotate.conf` | daily |

## Debian

| Variable | Default |
|----------|---------|
| \_\_logrotate\_config | /etc/logrotate.conf |
| \_\_logrotate\_conf\_d | /etc/logrotate.d |

## FreeBSD

| Variable | Default |
|----------|---------|
| \_\_logrotate\_config | /usr/local/etc/logrotate.conf |
| \_\_logrotate\_conf\_d | /usr/local/etc/logrotate.d |

## RedHat

| Variable | Default |
|----------|---------|
| \_\_logrotate\_config | /etc/logrotate.conf |
| \_\_logrotate\_conf\_d | /etc/logrotate.d |


Created by [yaml2readme.rb](https://gist.github.com/trombik/b2df709657c08d845b1d3b3916e592d3)

# logrotate module

`action_plugins/logrotate.py` enables to create a task like this.

```yaml
- name: Rotate logstash.log
  logrotate:
    name: logstash
    files:
      - /var/log/logstash.log
    delaycompress: yes
    compress: yes
    state: present
    frequency: daily
```

# Dependencies

None

# Example Playbook

The following `yaml` creates configurations for default ubuntu.

```yaml
- hosts: localhost
  roles:
    - ansible-role-logrotate
  post_tasks:

    - name: Roate wtmp
      logrotate:
        name: wtmp
        files:
          - /var/log/wtmp
        frequency: monthly
        missingok: yes
        create: 0664 root utmp
        rotate: 1
        su: root syslog
        state: present

    - name: Rotate btmp
      logrotate:
        name: btmp
        files:
          - /var/log/btmp
        missingok: yes
        frequency: monthly
        create: 0660 root utmp
        rotate: 1
        su: root syslog
        state: present

    - name: Rotate apt
      logrotate:
        name: apt
        files:
          - /var/log/apt/term.log
          - /var/log/apt/history.log
        rotate: 12
        frequency: monthly
        compress: yes
        missingok: yes
        notifempty: yes
        state: present

    - name: Rotate dpkg
      logrotate: 
        name: dpkg
        files:
          - /var/log/dpkg.log
          - /var/log/alternatives.log
        frequency: monthly
        rotate: 12
        compress: yes
        delaycompress: yes
        missingok: yes
        notifempty: yes
        create: 644 root root
        su: root syslog
        state: present

    - name: Create rsyslog
      logrotate:
        name: rsyslog
        files:
          - /var/log/syslog
        rotate: 7
        frequency: daily
        missingok: yes
        notifempty: yes
        delaycompress: yes
        compress: yes
        su: root syslog
        sharedscripts: no
        postrotate:
          - "reload rsyslog >/dev/null 2>&1 || true"
        state: present
    - name: Rotate other rsyslog logs
      logrotate:
        name: rsyslog_others
        files:
          - /var/log/mail.info
          - /var/log/mail.warn
          - /var/log/mail.err
          - /var/log/mail.log
          - /var/log/daemon.log
          - /var/log/kern.log
          - /var/log/auth.log
          - /var/log/user.log
          - /var/log/lpr.log
          - /var/log/cron.log
          - /var/log/debug
          - /var/log/messages
        rotate: 4
        frequency: weekly
        missingok: yes
        notifempty: yes
        compress: yes
        delaycompress: yes
        su: root syslog
        sharedscripts: yes
        postrotate:
          - "reload rsyslog >/dev/null 2>&1 || true"
        state: present

    - name: Rotate unattended-upgrades-shutdown.log
      logrotate:
        name: unattended-upgrades
        files:
          - /var/log/unattended-upgrades/unattended-upgrades.log
          - /var/log/unattended-upgrades/unattended-upgrades-shutdown.log
        rotate: 6
        frequency: monthly
        compress: yes
        missingok: yes
        notifempty: yes
        state: present

    - name: Rotate upstart
      logrotate:
        name: upstart
        files:
          - /var/log/upstart/*.log
        frequency: daily
        missingok: yes
        rotate: 7
        compress: yes
        notifempty: yes
        nocreate: yes
        state: present

  vars:
```
# License

BSD

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
