# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

GOBIN=/usr/local/go/bin
GOPATH=/root/wemall
GOROOT=/usr/local/go
export GOPATH
PATH=$PATH:$HOME/bin:$GOROOT/bin

export PATH
