library(rix)

(path_default_nix <- ".") # tempdir())

# https://b-rodrigues.github.io/rix/articles/building-reproducible-development-environments-with-rix.html
# RStudio looks for R in predefined paths and cannot “see” the R provided by a Nix environment, it will instead use the version installed on your machine. This means that if you use RStudio to work interactively with R, you will need to install RStudio inside that environment. rix::rix() can generate a default.nix file that does that.


# /Users/johngavin/Library/R/arm64/4.3/library 835 packages
# /Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/library 29 package


#  all features of {rix} 
# https://b-rodrigues.github.io/rix/articles/building-reproducible-development-environments-with-rix.html#a-complete-example
rix(r_ver = "4.3.1",
    r_pkgs = c("dplyr", "janitor", "AER", # "AER@1.2-8",
               "targets", "tarchetypes", "rmarkdown"
               ),
    system_pkgs = c("quarto"),
    git_pkgs = list(
      list(package_name = "housing",
           repo_url = "https://github.com/rap4all/housing/",
           branch_name = "fusen",
           commit = "1c860959310b80e67c41f7bbdc3e84cef00df18e")
      # list(package_name = "fusen",
      #      repo_url = "https://github.com/ThinkR-open/fusen",
      #      branch_name = "main",
      #      commit = "d617172447d2947efb20ad6a4463742b8a5d79dc"),
    ),
    ide = c("rstudio", "other", "code")[1],
    project_path = path_default_nix,
    shell_hook = "",
    print = FALSE,
    overwrite = TRUE)
file.edit("./default.nix")
nix_build(project_path = ".", exec_mode = c("blocking", "non-blocking"))

"
# https://nixos.wiki/wiki/Cleaning_the_nix_store
nix-store --gc
nix-collect-garbage --delete-old # nix-collect-garbage --help
sudo nix-store --verify --check-contents --repair
nix-store --delete /nix/store/[what you want to delete]

nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\w+-system|\{memory|/proc)'

export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
nix-build --impure
nix-shell
rstudio
" -> tmp ; rm(tmp)


# basics
# https://b-rodrigues.github.io/rix/articles/building-an-environment-for-literate-programming.html
rix(r_ver = "4.3.1",
    r_pkgs = c("quarto", "MASS"),
    system_pkgs = "quarto",
    tex_pkgs = c(
      "amsmath",
      "environ",
      "fontawesome5",
      "orcidlink",
      "pdfcol",
      "tcolorbox",
      "tikzfill"
    ),
    ide = "other",
    shell_hook = "",
    project_path = path_default_nix,
    overwrite = TRUE,
    print = F)




# ----
rix(r_ver = "latest",
    r_pkgs = c("dplyr", "ggplot2"),
    system_pkgs = NULL,
    git_pkgs = NULL,
    ide = "code",
    project_path = path_default_nix,
    overwrite = TRUE)
