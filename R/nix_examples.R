library(rix)

(path_default_nix <- ".") # tempdir())

# how all features of {rix} can work together
# https://b-rodrigues.github.io/rix/articles/building-reproducible-development-environments-with-rix.html#a-complete-example
rix(r_ver = "4.2.1",
    r_pkgs = c("dplyr", "janitor", "AER@1.2-8"),
    system_pkgs = c("quarto"),
    git_pkgs = list(
      list(package_name = "housing",
           repo_url = "https://github.com/rap4all/housing/",
           branch_name = "fusen",
           commit = "1c860959310b80e67c41f7bbdc3e84cef00df18e"),
      list(package_name = "fusen",
           repo_url = "https://github.com/ThinkR-open/fusen",
           branch_name = "main",
           commit = "d617172447d2947efb20ad6a4463742b8a5d79dc")
    ),
    ide = "rstudio",
    project_path = path_default_nix,
    overwrite = TRUE)
file.edit("./default.nix")
nix-build


rix(r_ver = "latest",
    r_pkgs = c("dplyr", "ggplot2"),
    system_pkgs = NULL,
    git_pkgs = NULL,
    ide = "code",
    project_path = path_default_nix,
    overwrite = TRUE)
