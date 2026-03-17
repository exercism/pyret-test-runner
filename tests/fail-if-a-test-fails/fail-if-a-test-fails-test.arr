use context starter2024

include file("fail-if-a-test-fails.arr")

check "returns-true returns true":
  returns-true() is true
end

check "returns-false returns true":
  returns-false() is true
end
