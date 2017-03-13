# Extends devtools's github_* HTTP verbs.

github_GET = devtools:::github_GET
github_POST = devtools:::github_POST

#
github_DELETE = function(path, ..., pat = devtools::github_pat(),
                         host = "https://api.github.com") {
  url = httr::parse_url(host)
  url$path = paste(url$path, path, sep = "/")
  url$path = gsub("^/", "", url$path)

  res = httr::DELETE(url, devtools:::github_auth(pat), ...)
  if (httr::status_code(res) == 204) {
    message("Successfully deleted ", path, "\n")
  } else {
    message("Sorry, something went wrong....")
  }
}
github_PATCH = function(path, ..., pat = devtools::github_pat(),
                        host = "https://api.github.com") {
  url = httr::parse_url(host)
  url$path = paste(url$path, path, sep = "/")
  url$path = gsub("^/", "", url$path)
  res = httr::PATCH(url, devtools:::github_auth(pat), ...)
  devtools:::github_response(res)
}

github_request = function(req, ...) {
  switch(req$method,
         GET = github_GET(req$path, ...),
         POST = github_POST(req$path, ...),
         PATCH = github_PATCH(req$path, ...),
         DELETE = github_DELETE(req$path, ...),
         stop("Unsupported HTTP method.")
  )
}
