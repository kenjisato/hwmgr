#' Set up a course directory.
#'
#' The default structure will be something like below:
#'
#' course
#' ├── assignments
#' │   ├── asgm01
#' │   └── asgm02
#' ├── collected
#' │   ├── asgm01-alice
#' │   ├── asgm01-bob
#' │   ├── asgm02-alice
#' │   └── asgm02-bob
#' ├── solutions
#' │   ├── asgm01
#' │   └── asgm02
#' └── templates
#'     └── blank
#'
#' @param dir Path to the course directory.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' start_course(".")
#' }
start_course = function(dir = ".") {

  subdirs = c("assignments", "solutions", "collected", "templates/blank")
  new_dirs = file.path(dir, subdirs)
  if(any(dir.exists(subdirs))) {
    stop("Cannot create directories.")
  }
  lapply(new_dirs, dir.create, recursive = TRUE)
  copy_inst_file("config.yml", "config.yml", dir)
  file.create(file.path(dir, "templates/blank/README.md"))
  message("Course directories created at ", dir, ".")
}

