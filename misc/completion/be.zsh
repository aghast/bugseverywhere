#compdef be
#
# This file should be copied into one of the directories in $fpath;
# e. g. /usr/local/share/zsh/site-functions/_be.
# From then on, every new shell should have the be completion.

__be_commands () {
  local -a commands
  commands=(
  assign:'Assign an individual or group to fix a bug'
  comment:'Add a comment to a bug'
  commit:'Commit the currently pending changes to the repository'
  depend:'Add / remove bug dependencies'
  diff:'Compare bug reports with older tree'
  due:'Set bug due dates'
  help:'Print help for given command or topic'
  html:'Generate a static HTML dump of the current repository status'
  import_xml:'Import comments and bugs from XML'
  init:'Create an on-disk bug repository'
  list:'List bugs'
  merge:'Merge duplicate bugs'
  new:'Create a new bug'
  remove:'Remove (delete) a bug and its comments'
  serve:'Serve bug directory storage over HTTP'
  set:'Change bug directory settings'
  severity:'Change a bug’s severity level'
  show:'Show a particular bug, comment, or combination of both'
  status:'Change a bug’s status level'
  subscribe:'(Un)subscribe to change notification'
  tag:'Tag a bug, or search bugs for tags'
  target:'Assorted bug target manipulations and queries'
  )

  integer ret=1
  _describe -t commands 'command' commands && ret=0
  return ret
}

_be-assign () {
  local curcontext="$curcontext" state line expl ret=1
  assignees=("${(f)$(be assign --complete)}" "-" "none")
  ids=("${(f)$(be assign - --complete)}")
  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    ':assignee:($assignees)' \
    ':ticket ID:($ids)' \
  && return 0
}

_be-comment () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be comment --complete)}")
  ids=(${ids[5,-1]})
  mimes=("text/plain" "text/xml" "image/jpeg" "image/png" "image/svg" "application/xhtml+xml" "application/pdf")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-a --author)'{-a,--author=-}'[Set the comment author]:author:($authors)' \
    '--alt-id[Set an alternate comment ID]:($ids)' \
    '(-c --content-type)'{-c,--content-type=-}'[Set comment content-type (e.g. text/plain)]:mime type:($mimes)' \
    ':ID:($ids)' \
  && return 0
}

_be-commit () {
  local curcontext="$curcontext" state line expl ret=1

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-b --body)'{-b,--body=-}'[Provide the detailed body for the commit message]:body:((EDITOR\:"start editor" ""\:"write on command line"))' \
    '(-a --allow-empty)'{-a,--allow-empty}'[Allow empty commits]' \
    ':summary (‘-’ for stdin):' \
    && return 0
}

_be-depend () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be depend --complete)}")
  ids=(${ids[9,-1]})
  statusses=("${(f)$(be depend --status --complete)}")
  sevties=("${(f)$(be depend --severity --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --remove)'{-r,--remove}'[Remove dependency (instead of adding it)]' \
    '(-s --show-status)'{-s,--show-status}'[Show status of blocking bugs]' \
    '(-S --show-summary)'{-S,--show-summary}'[Show summary of blocking bugs]' \
    '--status=-[Only show bugs matching the STATUS specifier]:status:($statusses)' \
    '--severity=-[Only show bugs matching the SEVERITY specifier]:severity:($sevties)' \
    {-t,--tree-depth=-}'[Print dependency tree rooted at BUG-ID with DEPTH levels of both blockers and blockees]:depth:' \
    '--repair[Check for and repair one-way links]' \
    '*:ID:($ids)' \
    && return 0
}

_be-diff () {
  # TODO subscription completion is too hard for me atm… 
  #      one should probably use _combination… but how??
  # TODO maybe even a nice copletion for repo? but how??
  local curcontext="$curcontext" state line expl ret=1
  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --repo)'{-r,--repo=-}'[Compare with repository instead of the current repository]:repository:' \
    '(-s --subscription)'{-s,--subscribe=-}'[Only print changes matching subscription]:subscription:' \
    '(-u --uuids)'{-u,--uuids}'[Only print the changed bug UUIDS]' \
    && return 0
}

_be-due () {
  # XXX This command is currently defunct in be itself
}

_be-help () {
  # XXX Needs no completion. What to do?
}

_be-html () {
  local curcontext="$curcontext" state line expl ret=1

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-o --output)'{-o,--output=-}'[Set the output path]' \
    '(-t --template)'{-t,--template=-}'[Use a different template]' \
    '--title=-[Set the bug repository title]' \
    '--index-header=-[Set the index page headers]' \
    '(-e --export-template)'{-e,--export-template}'[Export the default template and exit]' \
    '(-d --export-template-dir)'{-d,--export-template-dir=-}'[Set the directory for the template export]' \
    '(-l --min-id-length)'{-l,--min-id-length=-}'[Attempt to truncate bug and comment IDs to this length]' \
    '(-v -verbose)'{-v,--verbose}'[Verbose output]' \
    && return 0
}

_be-import_xml () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be import_xml --root --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-i --ignore-missing-references)'{-i,--ignore-missing-references}'[Ignore unknown <in-reply-to> elements]' \
    '(-a --add-only)'{-a,--add-only}'[Cancel when bugs already exist]' \
    '(-p --preserve-uuids)'{-p,--preserve-uuids}'[Preserve UUIDs for trusted input (potential name collisions)]' \
    '(-r --root)'{-r,--root=-}'[Supply a bug or comment ID as the root of any standalon <comment> elements]:ID:($ids)' \
    && return 0
}

_be-init () {
  local curcontext="$curcontext" state line expl ret=1

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    && return 0
}

_be-list () {
  local curcontext="$curcontext" state line expl ret=1
  statusses=("${(f)$(be list --status --complete)}")
  sevties=("${(f)$(be list --severity --complete)}")
  devers=("${(f)$(be list --assigned --complete)}")
  crits=(assigned comments creator extra_strings full last_modified mine reporter severity status summary time uuid)

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '--status=-[Only show bugs matching the status specifier]:status level:($statusses)' \
    '--severity=-[Only show bugs matching the severity specifier]:severity:($sevties)' \
    '--important[List bugs of “serious” or higher severity]' \
    '(-a --assigned)'{-a,--assigned=-}'[Only show bugs assigned to a certain developer]:developer:($devers)' \
    '(-m --mine)'{-m,--mine}'[Only show bugs assigned to you]' \
    '(-e --extra-strings)'{-e,--extra-strings=-}'[Only show bugs matching the argument, e.g. --extra-strings TAG:working,TAG:xml]' \
    '(-S --sort)'{-S,--sort=-}'[Adjust bug-sort criteria]:sort criteria:($crits)' \
    '(-t --tags)'{-t,--tags}'[Add TAGS: field to standard listing format]' \
    '(-i --ids)'{-i,--ids}'[Only print the bug IDs]' \
    '(-x --xml)'{-x,--xml}'[Dump output in XML format]' \
    && return 0
}

_be-merge () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be merge --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '1:merge into:($ids)' \
    '2:merge what:($ids)' \
    && return 0
}

_be-new () {
  local curcontext="$curcontext" state line expl ret=1
  # These seemingly ugly lines split the output of the command in $(cmd) into an array.
  sevties=("${(f)$(be new -s --complete)}")
  statusses=("${(f)$(be new -t --complete)}")
  devers=("${(f)$(be new -a --complete)}")
  creators=("${(f)$(be new -c --complete)}")  # XXX This currently seems to give *no* results
  reporters=("${(f)$(be new -r --complete)}") # XXX This currently seems to give *no* results

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --reporter)'{-r,--reporter=-}'[The user who reported the bug]:reporter:($reporters)' \
    '(-c --creator)'{-c,--creator=-}'[The user who created the bug]:creator:($creators)' \
    '(-a --assigned)'{-a,--assigned=-}'[The developer in charge of the bug]:developer:($devers)' \
    '(-t --status)'{-t,--status=-}'[The bug’s status level]:status level:($statusses)' \
    '(-s --severity)'{-s,--severity=-}'[The bug’s severity]:severity:($sevties)' \
    && return 0
}

_be-remove () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be remove --complete)}")
  ids=(${ids[2,-1]})

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '*:ID:($ids)' \
    && return 0
}

_be-serve () {
  local curcontext="$curcontext" state line expl ret=1

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '--port=-[Bind server to port]' \
    '--host=-[Set host string]' \
    '(-r --read-only)'{-r,--read-only}'[Disable operations that require writing]' \
    '(-n --notify)'{-n,--notify=-}'[Send notification emails for changes]' \
    '(-s --ssl)'{-s,--ssl}'[Use CherryPy to serve HTTPS (HTTP over SSL/TLS)]' \
    '(-a --auth)'{-a,--auth=-}'[Require authentication]' \
    && return 0
}

_be-set () {
  local curcontext="$curcontext" state line expl ret=1

  #XXX This command is documented as not providing a good interface for some settings. Postponed!
  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    && return 0
}

_be-severity () {
  local curcontext="$curcontext" state line expl ret=1
  sevties=("${(f)$(be severity --complete)}")
  sevties=(${sevties[2,-1]})
  ids=("${(f)$(be severity ${sevties[1]} --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '1:severity:($sevties)' \
    '2:ID:($ids)' \
    && return 0
}

_be-show () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be show --complete)}")

  # TODO completion of comment IDs does *not* work!

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-x --xml)'{-x,--xml}'[Dump as XML]' \
    '--only-raw-body[When printing only a single comment, just print it’s body]' \
    '(-c --no-comments)'{-c,--no-comments}'[Disable comment output]' \
    '*:ID:($ids[5,-1])' \
    && return 0
}

_be-status () {
  local curcontext="$curcontext" state line expl ret=1
  statusses=("${(f)$(be status --complete)}")
  statusses=(${statusses[2,-1]})
  ids=("${(f)$(be status ${statusses[1]} --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '1:status:($statusses)' \
    '2:ID:($ids)' \
    && return 0
}

_be-subscribe () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be subscribe --complete)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-u --unsubscribe)'{-u,--unsubscribe}'[Unsubscribe instead of subscribing]' \
    '(-a --list-all)'{-a,--list-all}'[List subscribers for all bugs]' \
    '(-l --list)'{-l,--list}'[List subscribers]' \
    '(-s --subscriber)'{-s,--subscriber=-}'[Email address of the subscriber]:email:' \
    '(-S --servers)'{-S,--servers=-}'[Servers from which you want notification]:server:' \
    '(-t --types)'{-t,--types=-}'[Types of changes you wish to be notified about]:types:' \
    '1:ID:($ids[8,-1])' \
    && return 0
}

_be-tag () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be tag --complete)}")
  # tags=("${(f)$(be tag ${ids[1]} --complete)}") # XXX This seems to always return *nothing*
  tags=("${(f)$(be tag --list)}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --remove)'{-r,--remove}'[Remove tag (instead of adding)]' \
    '(-l --list)'{-l,--list}'[List all available tags and exit]' \
    '1:ID:($ids[4,-1])' \
    '*:tag:($tags)' \
    && return 0
}

_be-target () {
  local curcontext="$curcontext" state line expl ret=1
  ids=("${(f)$(be target --complete)}")
  # awk splits the lines into tokens delimited by ': ', then prints only the second of each line.
  targets=("${(f)$(be list --severity=target | awk -F ': ' -- '{print($2)}' )}")

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --resolve *)'{-r,--resolve+}'[Print the UUID for the target bug whose summary matches TARGET]:target:($targets)' \
    '1:ID:($ids[3,-1])' \
    '2:target:($targets)' \
    && return 0
}

_be () {
  local curcontext="$curcontext" state line expl ret=1

  _arguments -C \
    '(-h --help)'{-h,--help}'[Print a help message]' \
    '--complete[Print a list of possible completions]' \
    '(-r --repo)'{-r,--repo=-}'[Select BE repository (see ‘be help repo’) rather than the current directory]:repository: ' \
    '--paginate[Pipe all output into less (or if set, $PAGER)]' \
    '--no-pager[Do not pipe output into a pager]' \
    '--version[Print version string]' \
    '--full-version[Print full version information]' \
    '1:command:->command' \
    '*::argument:->option-or-argument' && ret=0

  case $state in
    (command)
      _wanted commands expl 'be command' __be_commands && ret=0
      #__be_commands
      ;;
    (option-or-argument)
      becommand="${words[1]}"
      curcontext="${curcontext%:*:*}:be${becommand}:"
      _call_function ret _be-${becommand}
      ;;
  esac
}

_be "$@"
