
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
hw_init = function(name, template = NULL, ...) {

  cfg = config_load()

  # copy template
  message("Copy template to ", file.path(cfg$assignments, name))
  hw_copy_template(name, template)

  # create an assignment repository
  message("Create repository ", name)
  res = hw_repo_create(name, ...)

  ## git subtree
  ## res$clone_url

  return(res$clone_url)
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
  if (dir.exists(file.path(to_dir, name))) {
    stop("Assignment name ", name, " is already taken.")
  }

  # copy template into assignments dir
  file.copy(put_trailing_slash(from_dir),
            put_trailing_slash(to_dir), recursive = TRUE)

  # rename the target directory
  file.rename(file.path(to_dir, basename(from_dir)), file.path(to_dir, name))

  message("Copy created in ", file.path(to_dir, name))

  # remove unnecessary files
  git_dir =
    message("--- Removing .git/")
  unlink(file.path(to_dir, name, ".git"), recursive = TRUE)

  message("--- Remove .Ruser/")
  unlink(file.path(to_dir, name, ".Rproj.user"), recursive = TRUE)
}


# Create Repository -------------------------------------------------------

hw_repo_create = function(name, personal = FALSE, ...,
                          description, homepage) {
  # Create a repository
  # https://developer.github.com/v3/repos/#create

  # Set body using config.yml
  cfg = config_load()

  if (missing(description)) {
    description = paste(cfg$course$title, ":", name)
  }

  if (missing(homepage)) {
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

