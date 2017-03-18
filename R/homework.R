ask_about_homework = function(config) {

  if (is.null(config$id)) {
    readlineD("Code name [Default: NULL]")
  }

  id = readlineD("Code name [Default: NULL]")
  description = readlineD("Short description [Default: NULL]")
  publication = readlineD("Date of publication (format: 2017-4-30 17:00)")
  deadine = readlineD("Deadline (format: 2017-4-30 17:00)")

  private_txt = readlineD("Keep the starter codes privately? [y/N]")
  if (private_txt == "y" || private_txt == "Y") {
    private = TRUE
  } else {
    private = FALSE
  }

  if (length(config$templates) > 0) {

    if (!is.atomic(config$templates)) {
      alternatives = names(config$templates)
    } else {
      alternatives = config$templates
    }
    choice = menu(c("NULL", alternatives), title = "Choose template")

    if (choice == 1) {
      template = NULL
    } else {
      template = alternatives[[choice - 1]]
    }

  } else {
    template = NULL
  }

  invisible(list(
    id = id,
    description = description,
    publication = clean_datetime(publication),
    deadline = clean_datetime(deadline),
    private = private,
    template = template
  ))
}


#' Create an assignment (starter codes and instructions)
#'
#' @param ... parameters to overwrite global options
#' @param credentials credential to push
#'
#' @return list(dir, repo, remote)
#' @export
#'
hw_init = function(...,
                   cfg = config_load("config.yml"),
                   credentials = git2r::cred_token()) {

  hw = ask_about_homework()
  cfg = modifyList(cfg, c(hw, list(...)))

  target_dir = cfg$structure$assignments

  # copy template
  if (!is.null(hw$template)) {
    template_use(cfg$structure[[hw$template]],
                 target_dir, cfg$id, template_mapper(cfg))
  } else {
    template_use_empty()
  }

  message("Copy template: ", target_dir)

  # make an rstudio project
  proj_file = make_rproj(target_dir, rename = TRUE)

  # create an assignment repository
  res = hw_repo_create(cfg$id, description = cfg$description,
                       homepage = cfg$course$homepage,
                       private = cfg$private, ...)
  message("Create repository: ", cfg$id)

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


hw_copy_template = function(template = NULL, name, data) {
  # Copy template directory as a new assignment
  # data is the assignment specifig configurations

  config = config_load()


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
                          description = NULL, homepage = NULL,
                          private = FALSE) {
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





