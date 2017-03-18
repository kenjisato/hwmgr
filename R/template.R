template_use_empty = function(target_dir, name) {
  # Empty template

  draft_dir = file.path(target_dir, name)
  dir.create(draft_dir, recursive = TRUE)
  file.create(file.path(draft_dir, "README.md"))

  draft_dir
}


template_use = function(template, target_dir, name, map = file.copy,
                        skip = c(".git", ".Rproj.user")) {

  if (!dir.exists(target_dir)) {
    stop("Target directory ", target, " does not exist.")
  }

  draft_dir = file.path(target_dir, name)

  if (!file.exists(template)) {
    warning("Template file/folder", template, " does not exist.\n",
            "Defaults to the empty template.")
    template_use_empty(draft_dir)
  } else {
    template_to_draft(template, target_dir, name, map, skip)
  }

  draft_dir
}


template_to_draft = function(template, target_dir, name, map, skip) {
  # recursively copy and map the template into draft_dir
  draft = file.path(target_dir, name)

  if (file.info(template)$isdir) {
    dir.create(draft, recursive = TRUE)
    contents = setdiff(dir(template), c(".", "..", skip))
    for (content in contents) {
      inner_template = file.path(template, content)
      template_to_draft(inner_template, draft, content, map, skip)
    }
  } else {
    map(template, draft)
  }
}

template_mapper = function(params) {
  map = function(file, output) {
    input = readr::read_file(file)

    match = stringr::str_match_all(input, "\\{\\{ *([^ ]+) *\\}\\}")
    match = unique(match[[1]])

    replacements = stringr::str_split(match[, 2], pattern = "\\.")

    names(replacements) = match[, 1]

    translated = input
    for (pattern in names(replacements)) {
      if (is.null(params[[replacements[[pattern]]]])) next

      translated =
        stringr::str_replace_all(
          translated,
          stringr::fixed(pattern),
          params[[replacements[[pattern]]]]
        )
    }

    readr::write_file(translated, output)
  }
  map
}
