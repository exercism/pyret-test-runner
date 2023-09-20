use context essentials2020

include file("all-fail.arr")

#|
  When working offline, all tests except the first one are skipped by default.
  Once you get the first test running, unskip the next one until all tests pass locally.
  Check the block comment below for further details.
|#

fun will-fail():
  check "returns-false() returns true":
    returns-false() is true
  end
end

fun will-also-fail():
  check "return-false() returns 5":
    returns-false() is 5
  end
end

#|
  Code to run each test. Each line corresponds to a test above and whether it should be run.
  To mark a test to be run, replace `false` with `true` on that same line after the comma.
  test(test-a, true) will be run. test(test-a, false) will be skipped.
|#

data TestRun: test(run, active) end

[list: 
  test(will-fail, true),
  test(will-also-fail, false)
].each(lam(t): when t.active: t.run() end end)