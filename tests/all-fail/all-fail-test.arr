include file("example-all-fail.arr")

check "year not divisible by 4 in common year":
  leap(2015) is true
end

check "year divisible by 2, not divisible by 4 in common year":
  leap(1970) is true
end
