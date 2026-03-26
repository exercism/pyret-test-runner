use context starter2024

include file("fail-if-all-tests-fail.arr")

check "returns-false() returns true":
  returns-false() is true
end

check "return-false() returns 5":
  returns-false() is 5
end
