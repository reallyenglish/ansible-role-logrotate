from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()


# a wrapper action module for logrotate module
class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)

        logrotate_conf_d = self._templar.template(task_vars['logrotate_conf_d'])
        display.vv("logrotate_conf_d: %s" % logrotate_conf_d)

        if not 'config_dir' in self._task.args:
            self._task.args['config_dir'] = logrotate_conf_d

        result.update(self._execute_module(module_name='logrotate', module_args=self._task.args, task_vars=task_vars))

        return result
