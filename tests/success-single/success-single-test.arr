use context essentials2020

include file("success-single.arr")

check "year not divisible by 4 in common year":
  leap(2015) is false
end