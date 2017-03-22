ask_about_homework = function(config) {

  while (TRUE) {
    id = readlineD("Code name ")
    if (id == "") {
      message("Code name is required.")
    } else if (file.exists(file.path(config$structure$assignments, id))) {
      message("This name is already taken.")
    } else {
      break
    }
  }

  description = readlineD("Short description [Default: NULL]")
  publication = readlineD("Date of publication (format: 2017-4-30 17:00)")
  deadline = readlineD("Deadline (format: 2017-4-30 17:00)")

  private_txt = readlineD("Keep the starter codes privately? [y/N]")
  if (private_txt == "y" || private_txt == "Y") {
    private = TRUE
  } else {
    private = FALSE
  }

  if (length(config$structure$templates) > 0) {

    if (!is.atomic(config$structure$templates)) {
      alternatives = names(config$structure$templates)
    } else {
      alternatives = config$structure$templates
    }
    choice = utils::menu(c("NULL", alternatives), title = "Choose template")

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


#' Create a homework assignment (starter codes and instructions)
#'
#' @param ... parameters to overwrite global options
#' @param course_config used to override course parameters
#' @param credentials credential to push
#'
#' @return list(dir, repo, remote)
#' @export
#'
draft_homework = function(...,
                          course_config = config_load("config.yml"),
                          credentials = git2r::cred_token()) {

  course_config = utils::modifyList(course_config, list(...))

  hw_config = ask_about_homework(course_config)
  cfg = c(course_config, hw_config)

  target_dir = cfg$structure$assignments

  # copy template
  if (!is.null(cfg$templates)) {
    template_use(cfg$structure$templates[[cfg$template]],
                 target_dir, cfg$id, template_mapper(cfg))
  } else {
    template_use_empty(target_dir, cfg$id)
  }

  message("Copy template: ", target_dir)

  # make an rstudio project
  proj_file = make_rproj(target_dir, cfg$id, rename = TRUE)

  # create an assignment repository
  res = hw_repo_create(cfg$id, description = cfg$description,
                       homepage = cfg$course$homepage,
                       private = cfg$private, ...)
  message("Create repository: ", cfg$id)

  ## Git
  repo = git2r::init(file.path(target_dir, cfg$id))
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





