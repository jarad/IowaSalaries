library(rvest)
library(dplyr)
library(doMC)
doMC::registerDoMC(cores=4)


# Look up the number of pages manually @
# http://db.desmoinesregister.com/state-salaries-for-iowa
n_pages <- 27283

base_page <- "http://db.desmoinesregister.com/state-salaries-for-iowa/page="

# pages <- data_frame(page = paste0(base_page, 1:n_pages))

IowaSalaries <- plyr::a_ply(1:n_pages, 1, function(x) {
  page <- paste0("page/",x,".csv")

  if (!file.exists(page)) {
    print(page)

    read_html(paste0(base_page, x)) %>%
      html_node("table") %>%
      html_table() %>%
      readr::write_csv(path=page)
  }

}, .progress = "none")


#
source("https://gist.githubusercontent.com/jarad/8f3b79b33489828ab8244e82a4a0c5b3/raw/494db9bffb10ed6d1928c1d13f6748991a9415ac/read_dir")

IowaSalaries <- read_dir('page',
                         pattern = "*.csv",
                         into=c("page","number","extension")) %>%

  mutate(july_salary = as.numeric(gsub("\\D+", "", `July Salary`)) / 100,
         fy_salary   = as.numeric(gsub("\\D+", "", `FY Salary`)) / 100) %>%

  select(Employee,
         Department,
         Position,
         County,
         Sex,
         FY,
         `Travel, etc`,
         july_salary,
         fy_salary)


devtools::use_data(IowaSalaries, overwrite = TRUE)
