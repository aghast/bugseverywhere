"""Close a bug"""
from libbe import cmdutil
def execute(args):
    assert(len(args) == 1)
    cmdutil.get_bug(args[0]).status = "closed"
