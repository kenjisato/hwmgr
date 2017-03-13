
#' Create an assignment (starter codes and instructions)
#'
#' This function creates assignment_dir/shortname directory.
#' Put the template into the folder. A new repository for the course
#' organization will be created with the specified name
#'
#' @param name Common name for local and remote repos.
#' @param template key for template. If unspecified or nonexistent,
#'     the first template is used.
#' @param ... parameters passed to \code{hw_repo_create()}
#'
#' @return Remote repository URL
#' @export
#'
#' @examples
#' \dontrun{
#' hw_init("assignment01", "template1")
#' }
hw_init = function(name,
                   description = NULL,
                   homepage = NULL,
                   template = NULL,
                   ...,
                   credentials = git2r::cred_token()) {

  cfg = config_load()

  # copy template
  target_dir = hw_copy_template(name, template)
  message("Copy template: ", target_dir)

  # make an rstudio project
  proj_file = make_rproj(target_dir, rename = TRUE)

  # create an assignment repository
  res = hw_repo_create(name, description = description,
                       homepage = homepage, ...)
  message("Create repository: ", name)

  ## Git
  repo = git2r::init(target_dir)
  git2r::add(repo, proj_file)
  git2r::commit(repo, message = "Initial commit.")
  git2r::remote_add(repo, "origin", res$clone_url)
  git2r::push(repo, "origin", "refs/heads/master",
              credentials = credentials)

  return(list(
    dir = target_dir,
    repo = repo,
    remote = res$clone_url
  ))
}


hw_copy_template = function(name, template = NULL) {
  # Copy template directory as a new assignment

  cfg = config_load()

  if (is.null(template) || is.null(cfg$templates[[template]])) {
    template = 1
  }

  from_dir = cfg$templates[[template]]
  to_dir = cfg$assignments

  # if template directory (specified in YAML) not existent, abort
  if (!dir.exists(from_dir)) {
    stop("template directory does not exist.")
  }

  # if assignments directory (specified in YAML) not existent,
  # then create it
  if (!dir.exists(to_dir)) {
    dir.create(to_dir)
  }

  # if the target directory already exists, abort
  target_dir = file.path(to_dir, name)
  if (dir.exists(target_dir)) {
    stop("Assignment name ", name, " is already taken.")
  }

  # copy template into assignments dir
  file.copy(put_trailing_slash(from_dir),
            put_trailing_slash(to_dir), recursive = TRUE)

  # rename the target directory
  file.rename(file.path(to_dir, basename(from_dir)), target_dir)

  message("Copy created in ", target_dir)

  # remove unnecessary files
  git_dir =
    message("--- Removing .git/")
  unlink(file.path(to_dir, name, ".git"), recursive = TRUE)

  message("--- Remove .Ruser/")
  unlink(file.path(to_dir, name, ".Rproj.user"), recursive = TRUE)

  return(target_dir)
}


# Create Repository -------------------------------------------------------

hw_repo_create = function(name, personal = FALSE, ...,
                          description = NULL, homepage = NULL) {
  # Create a repository
  # https://developer.github.com/v3/repos/#create

  # Set body using config.yml
  cfg = config_load()

  if (is.null(description)) {
    description = paste(cfg$course$title, ":", name)
  }

  if (is.null(homepage)) {
    homepage = cfg$course$homepage
  }

  body = body_create(name = name,
                     description = description,
                     homepage = homepage, ...)

  req = if (personal) {
    github_api_create()
  } else {
    github_api_create(org = cfg$course$github)
  }
  github_request(req, body = body, ...)
}

hw_repo_delete = function(..., owner, repo) {
  # DELETE /repos/:owner/:repo

  cat("This operation cannot be undone. Are you sure to delete the remote repo?\n")
  confirm = utils::menu(c("YES", "NO"))

  if (confirm != 1) {
    cat("Operation cancelled.\n")
    return()
  }

  req = github_api_delete(owner, repo)
  github_request(req, ...)
}

