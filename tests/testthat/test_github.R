library(hwmgr)

# github_api_list() ----
context("Paths to list repositories.")

test_that("Path to list user repositories including private.", {
  expect_equal(github_api_list(),
               list(path = "/user/repos", method = "GET"))
})

test_that("Path to list user's public repositories.", {
  expect_equal(github_api_list(username = "mylogin"),
               list(path = "/users/mylogin/repos", method = "GET"))
  expect_warning(github_api_list(username = "mylogin", org = "myorg"))
})

test_that("Path to list organization's repositories.", {
  expect_equal(github_api_list(org = "myorg"),
               list(path = "/orgs/myorg/repos", method = "GET"))
})

# github_api_create() ----
context("Paths to create a repository")

test_that("", {
  expect_equal(github_api_create(),
               list(path = "/user/repos", method = "POST"))
  expect_equal(github_api_create(org = "myorg"),
               list(path = "/orgs/myorg/repos", method = "POST"))
})
