ansible-role-logrotate
=========

Install logrotate

Requirements
------------

None

Role Variables
--------------

|Variable|Description|Default|
|--------|-----------|-------|
| logrotate\_config  | path to logrotate.conf | see vars |
| logrotate\_conf\_d | path to logrotate.d    | see vars |

logrotate module
----------------

`action_plugins/logrotate.py` enables to create a task like this.

    - name: Rotate logstash.log
      logrotate:
        name: logstash
        files:
          - /var/log/logstash.log
        delaycompress: yes
        compress: yes
        state: present
        frequency: daily

Dependencies
------------

None

Example Playbook
----------------

    - hosts: all
      roles:
         - ansible-role-logrotate

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
