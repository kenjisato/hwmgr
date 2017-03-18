
make_rproj = function(path, name, rename = FALSE) {

  dir_name = file.path(path, name)
  existing = list.files(dir_name, pattern = "\\.Rproj$")

  proj_basename = paste0(name, ".Rproj")

  if (length(existing) > 0 && !rename) {
    message("Path is already an RStudio project. ")
    return(file.path(dir_name, existing[1]))
  } else if (length(existing) > 0 && rename) {
    file.rename(file.path(dir_name, existing[1]), proj_basename)
  } else {
    copy_inst_file("template.Rproj", proj_basename, dir_name)
  }
  return(file.path(dir_name, proj_basename))
}
