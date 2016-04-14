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
