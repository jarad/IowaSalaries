library(rvest)
library(dplyr)
library(doMC)
doMC::registerDoMC(cores=4)


# Look up the number of pages manually @
# http://db.desmoinesregister.com/state-salaries-for-iowa
n_pages <- 27283

base_page <- "http://db.desmoinesregister.com/state-salaries-for-iowa/page="

pages <- data_frame(page = paste0(base_page, 1:n_pages))

IowaSalaries <- plyr::ddply(pages, "page", function(x) {
  read_html(x$page) %>%
    html_node("table") %>%
    html_table()
}, .parallel = TRUE, .progress = "tk") %>%

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
