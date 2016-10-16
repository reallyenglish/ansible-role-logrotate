# ansible-role-logrotate

Install logrotate

# Requirements

None

# Role Variables

|Variable|Description|Default|
|--------|-----------|-------|
| logrotate\_config  | path to logrotate.conf | see vars |
| logrotate\_conf\_d | path to logrotate.d    | see vars |

| Variable | Description | Default |
|----------|-------------|---------|
| logrotate\_config | path to `logrotate.conf` | {{ \_\_logrotate\_config }} |
| logrotate\_conf\_d | path to `logrotate.d` | {{ \_\_logrotate\_conf\_d }} |
| logrotate\_default\_rotate | TBW | 30 |
| logrotate\_default\_dateext | TBW | true |
| logrotate\_default\_dateformat | TBW | .%Y%m%d |
| logrotate\_default\_freq | TBW | daily |

## FreeBSD

| Variable | Default |
|----------|---------|
| \_\_logrotate\_config | /usr/local/etc/logrotate.conf |
| \_\_logrotate\_conf\_d | /usr/local/etc/logrotate.d |


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

```yaml
- hosts: all
  roles:
     - ansible-role-logrotate
```

# License

BSD

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
