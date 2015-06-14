i := $(firstword $(iter-left))
iter-left := $(filter-out $i,$(iter-left))
$(iter-doit)
