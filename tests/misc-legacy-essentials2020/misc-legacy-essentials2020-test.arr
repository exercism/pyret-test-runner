use context essentials2020

include file("misc-legacy-essentials2020.arr")

check "returns-true returns true":
  returns-true() is true
end

check "returns-false returns true":
  returns-false() is false
end
