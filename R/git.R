#' Start working on assignment repository
#'
#' @export
enter = function(id, type = "assignments") {
  config = config_load()
  repo_dir = file.path(config$structure[[type]], id)

  .hwmgrEnv$repo = git2r::repository(repo_dir)
  .hwmgrEnv$oopt = options(prompt = paste0("(", repo_dir, ")# "))

  message("Enter repository: ", .hwmgrEnv$repo@path)
  message("Call leave() to leave this repo.")
  invisible()
}


#' Leave the repository
#'
#' @export
leave = function() {
  options(.hwmgrEnv$oopt)
  .hwmgrEnv$repo = NULL
}


#' A wrapper function for git2r::branches()
#'
#' @export
git_branches = function(repo = .hwmgrEnv$repo, ...) {
  git2r::branches(repo = repo, ...)
}


#' A wrapper function for git2r::checkout
#'
#' @export
git_checkout = function(object = .hwmgrEnv$repo, ...) {
  git2r::checkout(object = object, ...)
}


#' A wrapper function for git2r::add
#'
#' @export
git_add = function(path, repo = .hwmgrEnv$repo, ...) {
  git2r::add(repo = repo, path = path, ...)
}


#' A wrapper function for git2r::commit
#'
#' @export
git_commit = function(repo = .hwmgrEnv$repo, message = NULL, all = FALSE, ...) {
  git2r::commit(repo, message, all, ...)
}


#' A wrapper function for git2r::status
#'
#' @export
git_status = function(repo = .hwmgrEnv$repo, ...) {
  git2r::status(repo = repo, ...)
}


#' A wrapper function for git2r::push
#'
#' @export
git_push = function(object = .hwmgrEnv$repo, ...) {
  git2r::push(object, ..., credentials = git2r::cred_token("GITHUB_PAT"))
}


#' A wrapper function for git2r::head
#'
#' @export
git_head = function(x = .hwmgrEnv$repo, ...) {
  git2r::head(x, ...)
}



#' A wrapper function for git2r::branch_get_upstream
#'
#' @export
git_upstream_get = function(branch = git_head()) {
  git2r::branch_get_upstream(branch)
}


#' A wrapper function for git2r::branch_set_upstream
#'
#' @export
git_upstream_set = function(name, branch = git_head()) {
  git2r::branch_set_upstream(branch, name)
}


