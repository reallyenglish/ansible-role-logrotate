# ansible-role-logrotate

Install logrotate

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `logrotate_config` | path to `logrotate.conf` | `{{ __logrotate_config }}` |
| `logrotate_conf_d` | path to `logrotate.d` | `{{ __logrotate_conf_d }}` |
| `logrotate_default_rotate` | default value of `rotate` in `logrotate.conf` | `30` |
| `logrotate_default_dateext` | default value of `dateformat` in `logrotate.conf` | `true` |
| `logrotate_default_dateformat` | default value of `dateformat` in `logrotate.conf` | `.%Y%m%d` |
| `logrotate_default_freq` | default value of how often rotate the logs in `logrotate.conf` | `daily` |
| `logrotate_default_su` | default value of `su` in `logrotate.conf` | `{{ __logrotate_default_su }}` |

## Debian

| Variable | Default |
|----------|---------|
| `__logrotate_config` | `/etc/logrotate.conf` |
| `__logrotate_conf_d` | `/etc/logrotate.d` |
| `__logrotate_default_su` | `root syslog` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__logrotate_config` | `/usr/local/etc/logrotate.conf` |
| `__logrotate_conf_d` | `/usr/local/etc/logrotate.d` |
| `__logrotate_default_su` | `root wheel` |

## RedHat

| Variable | Default |
|----------|---------|
| `__logrotate_config` | `/etc/logrotate.conf` |
| `__logrotate_conf_d` | `/etc/logrotate.d` |
| `__logrotate_default_su` | `root root` |

## `logrotate module`

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

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
