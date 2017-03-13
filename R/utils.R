config_find = function(file) {
  if (!file.exists(file)) {
    stop(sprintf("Cannot find configuration file %s.", file))
  }
}

config_load = function(file = "config.yml") {
  config_find(file)
  config = yaml::yaml.load_file(file)
  return(invisible(config))
}

copy_inst_file = function(file_name, new_name, to_dir, package = "hwmgr") {
  file.copy(system.file("extdata", file_name, package = package),
            file.path(to_dir, new_name))
}

put_trailing_slash = function(s) {
  if (!endsWith(s, "/")) {
    s = paste0(s, "/")
  }
  s
}
