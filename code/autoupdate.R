setwd("~/covid19")

while (TRUE) {

  if (format(Sys.time(), "%M") %in% c(0, 30)) {

    system("git fetch")

    source("code/main.R")

    system("git add .; git commit -m 'Automatic update'")
    system("git push")

  }

}
