library(hwmgr)
context("Utility functions")

test_that("put_trailing_slash puts a trailing slash unless there is already", {
  expect_equal(put_trailing_slash("a"), "a/")
  expect_equal(put_trailing_slash("a/"), "a/")
  expect_equal(put_trailing_slash("/a/b/c"), "/a/b/c/")
})

