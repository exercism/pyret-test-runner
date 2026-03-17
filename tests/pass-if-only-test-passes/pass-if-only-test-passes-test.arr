use context starter2024

include file("pass-if-only-test-passes.arr")

check "returns-true returns true":
  returns-true() is true
end
