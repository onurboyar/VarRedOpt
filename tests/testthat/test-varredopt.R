testthat::expect_length(simulate.outer(n=1e3,d=3,q.outer = myq_asian), 2)
testthat::expect_length(simulate.outer(n=1e3,d=3,auto_repetition=100,q.outer = myq_asian), 3)
