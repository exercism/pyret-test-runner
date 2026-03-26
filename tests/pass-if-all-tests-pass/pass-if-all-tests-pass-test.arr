use context starter2024

include file("pass-if-all-tests-pass.arr")

check "returns-true returns true":
  returns-true() is true
end

check "returns-false returns true":
  returns-false() is false
end
