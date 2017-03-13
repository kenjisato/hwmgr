#' Set up a course directory.
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
#' ├── coding
#' └── paper-writing
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

  subdirs = c("assignments", "solutions", "collected", "templates")
  new_dirs = file.path(dir, subdirs)
  if(any(dir.exists(dir))) {
    stop("Cannot create directories.")
  }
  lapply(new_dirs, dir.create, recursive = TRUE)

  file.copy(system.file("extdata", "config.yml", package = "hwmgr"),
            file.path(dir, "config.yml"))

  message("Course directories created at ", dir, ".")
}

