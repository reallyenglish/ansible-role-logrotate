#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2016, Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
#
# This file is NOT part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.
#
import time
import os
import hashlib

DOCUMENTATION = '''
---
module: logrotate
short_description: Manage config files for logrotate
description:
     - Creates a config flie for I(logrotate)
version_added: "1.0"
options:
  name:
    description:
      - Unique name of the config
    required: true
    default: null
  files:
    description:
      - An array of path to files the I(logrotate) program to rotate
    required: true
    default: null
  state:
    description:
      - The state of the logrotate config
    required: true
    default: null
    choices: [ "present", "absent" ]
  frequency:
    description:
      - rotate frequency
    required: false
    choices: [ "daily", "weekly", "monthly", "yearly" ]
    default: "daily
  rotate:
    description:
      - number of times before being removed
    required: false
    default: 30
  files:
    description:
      - an array of paths to files to rotate
    required: true
    default: null
  compress:
    description:
      - compress the rotated file if true
    required: false
    choices: [ "yes", "no" ]
    default: true
  compresscmd:
    description:
      - command to use to compress log files
    required: false
    default: False
  uncompresscmd:
    description:
      - command to use to uncompress log files
    required: false
    default: False
  compressext
    description:
      - extension to use on compressed logfiles, if compression is enabled
    required: false
    default: False
  delaycompress:
    description:
      - delay compress
    required: false
    choices: [ "yes", "no" ]
    default: true
  copytruncate:
    description:
      - Truncate  the original log file to zero size in place after creating a copy, instead of moving the old log file and optionally creating a new one.
    required: false
    choices: [ "yes", "no" ]
    default: false
  missingok:
    description:
      - proceed without a warning if the file to rotate is missing
    required: false
    choices: [ "yes", "no" ]
    default: true
  sharedscripts:
    description:
      - postrotate commands for multiple files are run only once
    required: false
    choices: [ "yes", "no" ]
    default: false
  notifempty:
    description:
      - do not rotate the log if it is empty
    required: false
    choices: [ "yes", "no" ]
    default: no
  postrotate:
    description:
      - an array of commands to run in postrotate
    required: false
    default: null
  config_dir:
    description:
      - base directory of config files
    required: false
    default: /etc/logrotate.d
  create:
    description:
      - Immediately after rotation (before the postrotate script is run) the log file is created
    required: false
    default: False
  nocreate:
    description:
      - disable 'create' option
    required: false
    default: False
  su:
    description:
      - Rotate log files  set under this user and group instead of using default user/group
    required: false
    default: False
  maxsize:
    description:
      - Log  files  are rotated when they grow bigger than size bytes even before the additionally specified time interval
    required: false
    default: False
  minsize:
    description:
      - Log files are rotated when they grow bigger than size bytes, but not before  the  additionally  specified  time  interval
    required: false
    default: False
  size:
    description:
      - Log files are rotated only if they grow bigger then size bytes
    required: false
    default: False

requirements: [ ]
author: "Tomoyuki Sakurai <tomoyukis@reallyenglish.com>" 
'''

EXAMPLES = '''
# lotate /var/log/messages and maillog daily, keep 30 files and restart syslog only once
- logrotate: frequency="daily", rotate="30", files=[ "/var/log/messages", "/bar/log/maillog" ] postrotate="kill -HUP `cat /var/run/syslog.pid`" sharedscripts=yes
'''

def validate_config(module):
    """Validate a file given with logrotate -d file"""

    name = module.params.get('name')
    contents = generate_config(module)

    fd, temppath = tempfile.mkstemp(prefix='ansible-logrotate')
    fh = os.fdopen(fd, 'w')
    fh.write(contents)
    fh.close()

    LOGROTATE = module.get_bin_path('logrotate', True)

    # read not only the file to validate but the default configuration because
    # some defaults are needed to validate, notably `su` directive
    default_config_path = get_default_config_path(module)
    rc, out, err = module.run_command('%s -d %s %s' % (LOGROTATE, default_config_path, temppath), check_rc=True)
    os.unlink(temppath)
    if rc != 0:
        module.fail_json(msg='failed to validate config for: %s' % (name), stdout=out, stderr=err)

def get_default_config_path(module):
    """Look for the default configuration and return the first one found"""
    locations = [
        # Linux
        '/etc/logrotate.conf',
        # FreeBSD
        '/usr/local/etc/logrotate.conf'
        ]
    found = ''
    for path in locations:
        if os.path.exists(path):
            found = path
            break
    if not found:
        module.fail_json(msg='cannot find logrotate.conf in default locations')
    return found

def get_config_path(module):
    return os.path.join(module.params.get('config_dir'), module.params.get('name'))

def create_config(module):
    with open(get_config_path(module), 'w') as f:
        f.write(generate_config(module))

def generate_config(module):
    files = "\n".join(module.params.get('files'))

    options = []
    if module.params.get('compress'):
        options += [ 'compress' ]
    if module.params.get('compresscmd'):
        options += [ 'compresscmd %s' % module.params.get('compresscmd') ]
    if module.params.get('uncompresscmd'):
        options += [ 'uncompresscmd %s' % module.params.get('uncompresscmd') ]
    if module.params.get('compressext'):
        options += [ 'compressext %s' % module.params.get('compressext') ]
    if module.params.get('delaycompress'):
        options += [ 'delaycompress' ]
    if module.params.get('missingok'):
        options += [ 'missingok' ]
    if module.params.get('notifempty'):
        options += [ 'notifempty' ]
    if module.params.get('copytruncate'):
        options += [ 'copytruncate' ]
    if module.params.get('create'):
        options += [ 'create %s' % module.params.get('create') ]
    if module.params.get('nocreate'):
        options += [ 'nocreate' ]
    if module.params.get('su'):
        options += [ 'su %s' % module.params.get('su') ]
    if module.params.get('maxsize'):
        options += [ 'maxsize %s' % module.params.get('maxsize') ]
    if module.params.get('minsize'):
        options += [ 'minsize %s' % module.params.get('minsize') ]
    if module.params.get('size'):
        options += [ 'size %s' % module.params.get('size') ]

    options += [ '%s' % module.params.get('frequency') ]
    options += [ 'rotate %s' % module.params.get('rotate') ]

    if module.params.get('postrotate'):
        if module.params.get('sharedscripts'):
            options += [ 'sharedscripts' ]
        options += [ 'postrotate' ]
        options += map(lambda x: "  %s" % x, module.params.get('postrotate'))
        options += [ 'endscript' ]

    TEMPLATE = """\
# Generated by ansible logrotate module
{files_text}
{{
  {option_text}
}}
"""
    return TEMPLATE.format(files_text=files, option_text='\n  '.join(options))

def is_identical(a, b):
    a_hash = hashlib.sha1(a).hexdigest()
    b_hash = hashlib.sha1(b).hexdigest()
    return a_hash == b_hash

def create_if_absent(module):
    validate_config(module)
    path = get_config_path(module)
    if os.path.isfile(path):
        data = None
        with open(path) as f:
            data = f.read()
        if is_identical(data, generate_config(module)):
            module.exit_json(changed=False, result="Success")
        else:
            create_config(module)
            module.exit_json(changed=True, result="Created")
    else:
        create_config(module)
        module.exit_json(changed=True, result="Created")

def remove_if_present(module):
    path = get_config_path(module)
    if os.path.isfile(path):
        os.remove(path)
        module.exit_json(changed=True, result="Removed")
    else:
        module.exit_json(changed=False, result="Success")
        

def main():
    arg_spec = dict(
        name            = dict(required=True),
        files           = dict(required=True, type='list'),
        state           = dict(required=True, choices=['present', 'absent']),
        frequency       = dict(required=False, default='daily', choices=['daily', 'weekly', 'monthly', 'yearly']),
        rotate          = dict(required=False, default=30, type='int'),
        compress        = dict(required=False, default='yes', type='bool'),
        compresscmd     = dict(required=False),
        uncompresscmd   = dict(required=False),
        compressext     = dict(required=False),
        copytruncate    = dict(required=False, default='no', type='bool'),
        delaycompress   = dict(required=False, default='yes', type='bool'),
        missingok       = dict(required=False, default='yes', type='bool'),
        sharedscripts   = dict(required=False, default='yes', type='bool'),
        notifempty      = dict(required=False, default='no', type='bool'),
        postrotate      = dict(required=False, type='list'),
        config_dir      = dict(required=False, default='/etc/logrotate.d'),
        create          = dict(required=False),
        nocreate        = dict(required=False, type='bool'),
        su              = dict(required=False),
        maxsize         = dict(required=False),
        minsize         = dict(required=False),
        size            = dict(required=False)
    )

    module = AnsibleModule(argument_spec=arg_spec, supports_check_mode=False)

    if module.check_mode:
        module.exit_json(changed=True)
    else:
        if module.params.get('state') == 'present':
            create_if_absent(module)
        elif module.params.get('state') == 'absent':
            remove_if_present(module)
        else:
            module.fail_json('Unknown state: %s' % mudule.params.get('state'))

# import module snippets
from ansible.module_utils.basic import *
if __name__ == '__main__':
    main()
