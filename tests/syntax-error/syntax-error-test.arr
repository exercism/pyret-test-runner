include file("syntax-error.arr")

check "year not divisible by 4 in common year":
  leap(2015) is-not true
end
