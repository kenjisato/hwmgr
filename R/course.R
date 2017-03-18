#' Set up a course directory.
#' @param config_name Output file name.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' start_course()
#' }
start_course = function(config_name = "config.yml") {

  course_info = ask_about_course()

  structure_info = ask_about_structure()
  setup_structure(structure_info)
  message("Course directories created in ", structure_info$root, ".")

  write_as_yaml(course_info, structure_info, config_name)
  messge("Course information is saved in ", config_name, ".")

  invisible()
}


ask_about_course = function(read_from = NULL) {

  course_info = list(
    lecturer = list(
      name = readlineD("Lecturer name"),
      github = readlineD("Lecturer github account"),
      email = readlineD("Lecturer email")
    ),
    course = list(
      title = readlineD("Course title"),
      github = readlineD("Course github account"),
      homepage = readlineD("Course homepage URL"),
      slack = readlineD("Slack Team")
    )
  )
  course_info
}

ask_about_structure = function() {
  root = readlineD("Directory for the course", ".")

  structure_info = list(
    root = root,
    assignments = readlineD("Directory for assignments",
                            file.path(root, "assignments")),
    solutions = readlineD("Directory for suggested solutions",
                          file.path(root, "solutions")),
    collected = readlineD("Directory for solutions of students",
                          file.path(root, "collected"))
  )

  templates = readlineD("Directory for templates",
                        file.path(root, "templates"))
  structure_info$templates = find_templates(templates)

  structure_info
}


find_templates = function(template_root) {
  files = file.path(template_root, dir(template_root))
  is_directory = unlist(lapply(files, function(x) file.info(x)$isdir))
  directories = files[is_directory]

  templates = list()
  for (dir in directories) {
    templates[basename(dir)] = dir
  }

  if (length(templates) == 0) {
    return(template_root)
  }
  templates
}


write_as_yaml = function(course_info, structure_info, name = "config.yml") {
  root = structure_info$root
  data = c(course_info, list(structure = structure_info))
  readr::write_file(yaml::as.yaml(data), file.path(root, name))
}

setup_structure = function(structure_info) {
  dirs = c(
    structure_info$root,
    structure_info$assignments,
    structure_info$solutions,
    structure_info$collected
  )
  if (is.atomic(structure_info$templates) &&
      length(structure_info$templates) == 1) {
    dirs = c(dirs, structure_info$templates)
  }

  for (dir in dirs) dir.create(dir)

}


