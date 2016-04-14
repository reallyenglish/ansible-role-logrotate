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

`files/logrotate.py` enables to create a task like this.

    - name: Rotate logstash.log
      logrotate:
        name: logstash
        files:
          - /var/log/logstash.log
        state: present
        config_dir: /usr/local/etc/logrotate.d

copy the file to `$PROJECT\_ROOT/library/`.

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
