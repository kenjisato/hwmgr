
make_rproj = function(path, rename = FALSE) {
  proj_name = basename(path)
  if (length(existing <- list.files(path, pattern = "\\.Rproj$")) > 0) {
    if (rename) {
      file.rename(file.path(path, existing[1]),
                  file.path(path, paste0(proj_name, ".Rproj")))
    } else {
      message("Path is already an RStudio project. ")
    }
  } else {
    copy_inst_file("template.Rproj", paste0(proj_name, ".Rproj"), path)
  }
}
