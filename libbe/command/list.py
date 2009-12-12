# Copyright (C) 2005-2009 Aaron Bentley and Panometrics, Inc.
#                         Gianluca Montecchi <gian@grys.it>
#                         Oleg Romanyshyn <oromanyshyn@panoramicfeedback.com>
#                         W. Trevor King <wking@drexel.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import os
import re

import libbe
import libbe.bug
import libbe.command
import libbe.command.util

# get a list of * for cmp_*() comparing two bugs. 
AVAILABLE_CMPS = [fn[4:] for fn in dir(libbe.bug) if fn[:4] == 'cmp_']
AVAILABLE_CMPS.remove('attr') # a cmp_* template.

class Filter (object):
    def __init__(self, status, severity, assigned, extra_strings_regexps):
        self.status = status
        self.severity = severity
        self.assigned = assigned
        self.extra_strings_regexps = extra_strings_regexps

    def __call__(self, bug):
        if self.status != "all" and not bug.status in self.status:
            return False
        if self.severity != "all" and not bug.severity in self.severity:
            return False
        if self.assigned != "all" and not bug.assigned in self.assigned:
            return False
        if len(bug.extra_strings) == 0:
            if len(self.extra_strings_regexps) > 0:
                return False
        else:
            for string in bug.extra_strings:
                for regexp in self.extra_strings_regexps:
                    if not regexp.match(string):
                        return False
        return True

class List (libbe.command.Command):
    """List bugs

    >>> import libbe.bugdir
    >>> bd = libbe.bugdir.SimpleBugDir()
    >>> bd.uuid = '1234abcd'
    >>> cmd = List()
    >>> cmd._setup_io = lambda i_enc,o_enc : None
    >>> cmd.run(bd)
    123/a:om: Bug A
    >>> cmd.run(bd, {'status':'closed'})
    123/b:cm: Bug B
    >>> bd.cleanup()
    """

    name = 'list'

    def __init__(self, *args, **kwargs):
        libbe.command.Command.__init__(self, *args, **kwargs)
        self.options.extend([
                libbe.command.Option(name='status',
                    help='Only show bugs matching the STATUS specifier',
                    arg=libbe.command.Argument(
                        name='status', metavar='STATUS', default='active',
                        completion_callback=libbe.command.util.complete_status)),
                libbe.command.Option(name='severity',
                    help='Only show bugs matching the SEVERITY specifier',
                    arg=libbe.command.Argument(
                        name='severity', metavar='SEVERITY', default='all',
                        completion_callback=libbe.command.util.complete_severity)),
                libbe.command.Option(name='assigned', short_name='a',
                    help='Only show bugs matching ASSIGNED',
                    arg=libbe.command.Argument(
                        name='assigned', metavar='ASSIGNED', default='all',
                        completion_callback=libbe.command.util.complete_assigned)),
                libbe.command.Option(name='extra-strings', short_name='e',
                    help='Only show bugs matching STRINGS, e.g. --extra-strings'
                         ' TAG:working,TAG:xml',
                    arg=libbe.command.Argument(
                        name='extra-strings', metavar='STRINGS', default=None,
                        completion_callback=libbe.command.util.complete_extra_strings)),
                libbe.command.Option(name='sort', short_name='S',
                    help='Adjust bug-sort criteria with comma-separated list '
                         'SORT.  e.g. "--sort creator,time".  '
                         'Available criteria: %s' % ','.join(AVAILABLE_CMPS),
                    arg=libbe.command.Argument(
                        name='sort', metavar='SORT', default=None,
                        completion_callback=libbe.command.util.Completer(AVAILABLE_CMPS))),
                libbe.command.Option(name='uuids', short_name='u',
                    help='Only print the bug UUIDS'),
                libbe.command.Option(name='xml', short_name='x',
                    help='Dump output in XML format'),
                ])
#    parser.add_option("-S", "--sort", metavar="SORT-BY", dest="sort_by",
#                      help="Adjust bug-sort criteria with comma-separated list SORT-BY.  e.g. \"--sort creator,time\".  Available criteria: %s" % ','.join(AVAILABLE_CMPS), default=None)
#    # boolean options.  All but uuids and xml are special cases of long forms
#             ("w", "wishlist", "List bugs with 'wishlist' severity"),
#             ("i", "important", "List bugs with >= 'serious' severity"),
#             ("A", "active", "List all active bugs"),
#             ("U", "unconfirmed", "List unconfirmed bugs"),
#             ("o", "open", "List open bugs"),
#             ("T", "test", "List bugs in testing"),
#             ("m", "mine", "List bugs assigned to you"))
#    for s in bools:
#        attr = s[1].replace('-','_')
#        short = "-%c" % s[0]
#        long = "--%s" % s[1]
#        help = s[2]
#        parser.add_option(short, long, action="store_true",
#                          dest=attr, help=help, default=False)
#    return parser
#                
#                ])

    def _run(self, bugdir, **params):
        cmp_list, status, severity, assigned, extra_strings_regexps = \
            self._parse_params(params)
        filter = Filter(status, severity, assigned, extra_strings_regexps)
        bugs = [bugdir.bug_from_uuid(uuid) for uuid in bugdir.uuids()]
        bugs = [b for b in bugs if filter(b) == True]
        self.result = bugs
        if len(bugs) == 0 and params['xml'] == False:
            print "No matching bugs found"
    
        # sort bugs
        bugs = self._sort_bugs(bugs, cmp_list)

        # print list of bugs
        if params['uuids'] == True:
            for bug in bugs:
                print bug.uuid
        else:
            self._list_bugs(bugs, xml=params['xml'])

    def _parse_params(self, params):
        cmp_list = []
        if params['sort'] != None:
            for cmp in params['sort'].sort_by.split(','):
                if cmp not in AVAILABLE_CMPS:
                    raise libbe.command.UserError(
                        "Invalid sort on '%s'.\nValid sorts:\n  %s"
                    % (cmp, '\n  '.join(AVAILABLE_CMPS)))
            cmp_list.append(eval('libbe.bug.cmp_%s' % cmp))
        # select status
        if params['status'] == 'all':
            status = libbe.bug.status_values
        elif params['status'] == 'active':
            status = list(libbe.bug.active_status_values)
        elif params['status'] == 'inactive':
            status = list(libbe.bug.inactive_status_values)
        else:
            status = libbe.command.util.select_values(
                params['status'], libbe.bug.status_values)
        # select severity
        if params['severity'] == 'all':
            severity = libbe.bug.severity_values
        elif params['important'] == True:
            serious = libbe.bug.severity_values.index('serious')
            severity.append(list(libbe.bug.severity_values[serious:]))
        else:
            severity = libbe.command.util.select_values(
                params['severity'], bug.severity_values)
        # select assigned
        if params['assigned'] == "all":
            assigned = "all"
        else:
            possible_assignees = []
            for bug in self.bugdir:
                if bug.assigned != None \
                        and not bug.assigned in possible_assignees:
                    possible_assignees.append(bug.assigned)
            assigned = libbe.command.util.select_values(
                params['assigned'], possible_assignees)
        for i in range(len(assigned)):
            if assigned[i] == '-':
                assigned[i] = params['user-id']
        if params['extra-strings'] == None:
            extra_strings_regexps = []
        else:
            extra_strings_regexps = [re.compile(x)
                                     for x in params['extra-strings'].split(',')]
        return (cmp_list, status, severity, assigned, extra_strings_regexps)

    def _sort_bugs(self, bugs, cmp_list=[]):
        cmp_list.extend(libbe.bug.DEFAULT_CMP_FULL_CMP_LIST)
        cmp_fn = libbe.bug.BugCompoundComparator(cmp_list=cmp_list)
        bugs.sort(cmp_fn)
        return bugs

    def _list_bugs(self, bugs, xml=False):
        if xml == True:
            print '<?xml version="1.0" encoding="%s" ?>' % self.stdout.encoding
            print "<bugs>"
        if len(bugs) > 0:
            for bug in bugs:
                if xml == True:
                    print bug.xml(show_comments=True)
                else:
                    print bug.string(shortlist=True)
        if xml == True:
            print "</bugs>"

    def _long_help(self):
        return """
This command lists bugs.  Normally it prints a short string like
  576:om: Allow attachments
Where
  576   the bug id
  o     the bug status is 'open' (first letter)
  m     the bug severity is 'minor' (first letter)
  Allo... the bug summary string

You can optionally (-u) print only the bug ids.

There are several criteria that you can filter by:
  * status
  * severity
  * assigned (who the bug is assigned to)
Allowed values for each criterion may be given in a comma seperated
list.  The special string "all" may be used with any of these options
to match all values of the criterion.  As with the --status and
--severity options for `be depend`, starting the list with a minus
sign makes your selections a blacklist instead of the default
whitelist.

status
  %s
severity
  %s
assigned
  free form, with the string '-' being a shortcut for yourself.

In addition, there are some shortcut options that set boolean flags.
The boolean options are ignored if the matching string option is used.
""" % (','.join(bug.status_values), ','.join(bug.severity_values))

def complete(options, args, parser):
    for option, value in cmdutil.option_value_pairs(options, parser):
        if value == "--complete":
            if option == "status":
                raise cmdutil.GetCompletions(bug.status_values)
            elif option == "severity":
                raise cmdutil.GetCompletions(bug.severity_values)
            raise cmdutil.GetCompletions()
    if "--complete" in args:
        raise cmdutil.GetCompletions() # no positional arguments for list
