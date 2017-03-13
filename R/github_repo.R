# GitHub Repositories -----------------------------------------------------

#' API path and method to list repositories.
#'
#' @param ... Not used.
#' @param username A string for GitHub user account.
#' @param org A string for GitHub organization account.
#'
#' @return List consisting of path and HTTP method.
#' @export
#'
#' @examples
#' github_api_list(username = "kenjisato")
#'
#' @seealso \url{https://developer.github.com/v3/repos/#list-your-repositories}
#'     \url{https://developer.github.com/v3/repos/#list-user-repositories}
#'     \url{https://developer.github.com/v3/repos/#list-organization-repositories}
github_api_list = function(..., username = NULL, org = NULL) {

  if (is.null(username)) {
    path = if (is.null(org)) {
      "/user/repos"
    } else {
      paste0("/orgs/", org, "/repos")
    }
  } else {
    if (!is.null(org)) {
      warning("Both username and org are specified. Ignore org.")
    }
    path = paste0("/users/", username, "/repos")
  }

  return(list(path = path, method = "GET"))
}

#' Create a GitHub repository
#'
#' @param org A string. Return API to create an organization repository if specified.
#'
#' @return List consisting of path and HTTP method (POST).
#' @export
#'
#' @examples
#' github_api_create()
#' github_api_create(org = "myorg")
#'
#' @seealso \url{https://developer.github.com/v3/repos/#create}
github_api_create = function(org = NULL) {
  path = if (is.null(org)) {
    "/user/repos"
  } else {
    paste0("/orgs/", org, "/repos")
  }
  return(list(path = path, method = "POST"))
}


#' API path and method to get repository information
#'
#' @param owner GitHub login or organization name.
#' @param repo Repository name.
#'
#' @return List consisting of path and HTTP method (GET).
#' @export
#'
#' @examples
#' github_api_get(owner = "me", repo = "myrepo")
#'
#' @seealso \url{https://developer.github.com/v3/repos/#get}
github_api_get = function(owner, repo) {
  path = paste0("/repos/", owner, "/", repo)
  return(list(path = path, method = "GET"))
}

#' API path and method to edit repository information
#'
#' @param owner GitHub login or organization name.
#' @param repo Repository name.
#'
#' @return List consisting of path and HTTP method (GET).
#' @export
#'
#' @examples
#' github_api_edit("kenjisato", "my-great-repo")
#'
#' @seealso \url{https://developer.github.com/v3/repos/#edit}
github_api_edit = function(owner, repo) {
  path = paste0("/repos/", owner, "/", repo)
  return(list(path = path, method = "PATCH"))
}


#' API path and method to delete a repository
#'
#' @param owner GitHub login or organization name.
#' @param repo Repository name.
#'
#' @return List consisting of path and HTTP method (DELETE).
#' @export
#'
#' @examples
#' github_api_delete("kenjisato", "my-great-repo")
#'
#' @seealso \url{https://developer.github.com/v3/repos/#delete}
github_api_delete = function(owner, repo) {
  path = paste0("/repos/", owner, "/", repo)
  return(list(path = path, method = "DELETE"))
}


# GitHub API Content ------------------------------------------------------


body_list_mine = function(
  visibility = c("all", "public", "private"),
  affiliation = "owner,collaborator,organization_member",
  type = c("all", "owner", "public", "private", "member"),
  sort = c("full_name", "created", "updated", "pushed"),
  direction = c("asc", "desc")
) {
  visibility = match.arg(visibility)
  type = match.arg(type)
  sort = match.arg(sort)
  direction = match.arg(direction)

  list(visibility = visibility,
       affiliation = affiliation,
       type = type,
       sort = sort,
       direction = direction)
}


body_create = function(
  name,
  description = NULL,
  homepage = NULL,
  private = FALSE,
  has_issues = TRUE,
  has_wiki = TRUE,
  team_id = NULL,
  auto_init = FALSE,
  gitignore_template = NULL,
  license_template = NULL
) {
  # Configuration options for a new repository
  # https://developer.github.com/v3/repos/#create

  body = list(
    name = name, description = description, homepage = homepage,
    private = private, has_issues = has_issues, has_wiki = has_wiki,
    team_id = team_id, auto_init = auto_init,
    gitignore_template = gitignore_template,
    license_template = license_template)
}


