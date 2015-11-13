# tiny_sh_tests

## usage

```sh
source $SOME_PLACE_YOUR_STORE_CODE/tiny_sh_tests/test_init.sh
function my_setup()
{
  # some code you want to run BEFORE each test
}

function my_teardown()
{
  # some code you want to run AFTER each test
}

###
setup 'my first test'
###

run hello_world.sh

if grep -q 'hello' $RUN_STDERR ; then
  sucess
else
  failure $LINENO 'it should greet people'
fi


###
setup 'a test with stub'
###

stub echo --with hello

run hello_world.sh

if [ $STUB_NB_CALLS_echo -eq 1 ] ; then
  sucess
else
  failure $LINENO 'it should greet people'
fi

###
finish
```
