RED="\033[0;31m"
GREEN="\033[0;32m"
NOCOLOR="\033[0m"

NB_FAILURES=0
NB_TESTS=0
IN_TEST='FALSE'

function sucess()
{
  printf "$GREEN\nok\n$NOCOLOR"
}

function failure()
{
  LINE=$1
  shift
  MSG=$*
  printf "$RED FAILURE on line $LINE$NOCOLOR\n  => $MSG"
  printf "\n  ==STDERR==\n"
  cat $RUN_STDERR
  printf "\n  ==STDOUT==\n"
  cat $RUN_STDOUT
  printf "\n"
  NB_FAILURES=`expr $NB_FAILURES + 1`
}

function setup()
{
  teardown
  IN_TEST='TRUE'
  if [ -n "$1" ] ; then
    printf "\n=== TEST: $1"
  fi
  RUN_STDOUT=/tmp/$$_stdout
  RUN_STDERR=/tmp/$$_stderr
  my_setup
}

function teardown()
{
  if [ $IN_TEST = 'TRUE' ] ; then
    rm -f $RUN_STDOUT
    rm -f $RUN_STDERR
    NB_TESTS=`expr $NB_TESTS + 1`
    unstub_all
    my_teardown
    IN_TEST='FALSE'
  fi
}

function run()
{
  eval "$* >$RUN_STDOUT 2>$RUN_STDERR"
}

# you need to use source_run if you stubbed things
function source_run()
{
  eval "source $* >$RUN_STDOUT 2>$RUN_STDERR"
}

function finish()
{
  teardown
  printf "\n"
  if [[ $NB_FAILURES -gt 0 ]] ; then
    printf "$RED Finished $NB_TESTS tests with $NB_FAILURES failure $NOCOLOR"
  else
    printf "$GREEN Finished $NB_TESTS tests. All success $NOCOLOR"
  fi
}

## stubbing
STUBS=''
function increment()
{
  varname=$1
  #echo "####### incrementing $varname"
  value=`eval echo \\$$varname`
  eval $varname=`expr $value + 1`
}

function count_calls()
{
  #echo "####### count_call $*"
  name=$1
  with=$2
  shift 2
  #echo "####### args $*"
  #echo "####### with $with"
  echo "$*" | grep -qe "$with" && increment STUB_NB_CALLS_$name
}

function stub()
{
  name=$1
  with='.*'
  while shift ; do
    case $1 in
      --with)
        shift
        with="$1"
        ;;
    esac
  done
  eval "function $name(){ count_calls $name '$with' \$*; }"
  eval "STUB_NB_CALLS_$name=0"
  STUBS="$STUBS $name"
}

function unstub_all()
{
  for s in $STUBS ; do
    unset -f $s
  done
  STUBS=''
}
