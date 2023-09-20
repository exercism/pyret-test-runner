use context essentials2020

include file("success-multiple.arr")

#|
  When working offline, all tests except the first one are skipped by default.
  Once you get the first test running, unskip the next one until all tests pass locally.
  Check the block comment below for further details.
|#

fun returns-true-is-true():
  check "returns-true returns true":
    returns-true() is true
  end
end

fun returns-false-is-false():
  check "returns-false returns true":
    returns-false() is false
  end
end

#|
  Code to run each test. Each line corresponds to a test above and whether it should be run.
  To mark a test to be run, replace `false` with `true` on that same line after the comma.
  test(test-a, true) will be run. test(test-a, false) will be skipped.
|#

data TestRun: test(run, active) end

[list: 
  test(returns-true-is-true, true),
  test(returns-false-is-false, false)
].each(lam(t): when t.active: t.run() end end)