
make_rproj = function(path, rename = FALSE) {

  proj_name = basename(path)
  file_name = paste0(proj_name, ".Rproj")
  file_path = file.path(path, file_name)
  existing = list.files(path, pattern = "\\.Rproj$")

  if (length(existing) > 0 && !rename) {
    message("Path is already an RStudio project. ")
    return(file.path(path, existing[1]))
  } else if (length(existing) > 0 && rename) {
    file.rename(file.path(path, existing[1]), file_path)
  } else {
    copy_inst_file("template.Rproj", file_name, path)
  }
  return(file_path)
}
