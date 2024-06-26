# Set the working directory and verify it
setwd('C:\\Users\\HP\\Downloads')
getwd()

# Function to install and load libraries
install_and_load <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

# Load required libraries
libraries <- c("dplyr", "readr", "readxl", "tidyr", "ggplot2", "BSDA")
lapply(libraries, install_and_load)

# Reading the file into R
data <- read.csv("NSSO68.csv")

# Filtering for HP
df <- data %>%
  filter(state_1 == "HP")

#checking the filter
unique(df$state_1)

# Display dataset info
cat("Dataset Information:\n")
print(names(df))
print(head(df))
print(dim(df))

# Finding missing values
missing_info <- colSums(is.na(df))
cat("Missing Values Information:\n")
print(missing_info)

# Subsetting the data for variable of interest
hpnew <- df %>%
  select(state_1, District, Region, Sector, State_Region, Meals_At_Home, ricepds_v, Wheatpds_q, chicken_q, pulsep_q, wheatos_q, No_of_Meals_per_day)
unique(apnew$Meals_At_Home)
#chcek for missing values in the subset
cat("Missing values in subset:\n")
print(colSums(is.na(hpnew)))

# Impute missing values with mean for specific columns
impute_with_mean <- function(column) {
  if (any(is.na(column))) {
    column[is.na(column)] <- mean(column, na.rm = TRUE)
  }
  return(column)
}
hpnew$Meals_At_Home <- impute_with_mean(apnew$Meals_At_Home)
hpnew$Days_Stayed_away <- impute_with_mean(apnew$Days_Stayed_away)
hpnew$Meals_School <- impute_with_mean(apnew$Meals_School)
hpnew$Meals_Employer <- impute_with_mean(apnew$Meals_Employer)
hpnew$Meals_Others <- impute_with_mean(apnew$Meals_Others)
hpnew$Meals_Payment <- impute_with_mean(apnew$Meals_Payment)
hpnew$Source_Code <- impute_with_mean(apnew$Source_Code)
hpnew$soyabean_q <- impute_with_mean(apnew$soyabean_q)

# Finding outliers and removing them
remove_outliers <- function(df, column_name) {
  Q1 <- quantile(df[[column_name]], 0.25)
  Q3 <- quantile(df[[column_name]], 0.75)
  IQR <- Q3 - Q1
  lower_threshold <- Q1 - (1.5 * IQR)
  upper_threshold <- Q3 + (1.5 * IQR)
  df <- subset(df, df[[column_name]] >= lower_threshold & df[[column_name]] <= upper_threshold)
  return(df)
}

names(hpnew)
#Remove outliers in the dataset
outlier_columns <- c("ricepds_v", "chicken_q","Meals_At_Home","Wheatpds_q","pulsep_q","wheatos_q","No_of_Meals_per_day")
for (col in outlier_columns) {
  hpnew <- remove_outliers(apnew, col)
}

# Summarize consumption
apnew$total_consumption <- rowSums(apnew[, c("ricepds_v", "Wheatpds_q", "chicken_q", "pulsep_q", "wheatos_q")], na.rm = TRUE)

# Summarize and display top consuming districts and regions
summarize_consumption <- function(group_col) {
  summary <- apnew %>%
    group_by(across(all_of(group_col))) %>%
    summarise(total = sum(total_consumption)) %>%
    arrange(desc(total))
  return(summary)
}

district_summary <- summarize_consumption("District")
region_summary <- summarize_consumption("Region")

cat("Top Consuming Districts:\n")
print(head(district_summary, 4))
cat("Region Consumption Summary:\n")
print(region_summary)

# Rename districts and sectors
district_mapping <- c("2" = "Kangra", "5" = "Mandi", "11" = "Shimla", "6" = "Hamirpur")
sector_mapping <- c("2" = "URBAN", "1" = "RURAL")

apnew$District <- as.character(apnew$District)
apnew$Sector <- as.character(apnew$Sector)
apnew$District <- ifelse(apnew$District %in% names(district_mapping), district_mapping[apnew$District], apnew$District)
apnew$Sector <- ifelse(apnew$Sector %in% names(sector_mapping), sector_mapping[apnew$Sector], apnew$Sector)

fix(apnew)
# Test for differences in mean consumption between urban and rural
rural <- apnew %>%
  filter(Sector == "RURAL") %>%
  select(total_consumption)

urban <- apnew %>%
  filter(Sector == "URBAN") %>%
  select(total_consumption)

mean_rural <- mean(rural$total_consumption)
mean_urban <- mean(urban$total_consumption)

# Perform z-test
z_test_result <- z.test(rural, urban, alternative = "two.sided", mu = 0, sigma.x = 2.56, sigma.y = 2.34, conf.level = 0.95)
summary(z_test_result)

z_test_result$statistic
z_test_result$p.value

# Generate output based on p-value
if (z_test_result$p.value < 0.05) {
  cat(glue::glue("P value is < 0.05 i.e. {round(z_test_result$p.value,5)}, Therefore we reject the null hypothesis.\n"))
  cat(glue::glue("There is a difference between mean consumptions of urban and rural.\n"))
  cat(glue::glue("The mean consumption in Rural areas is {mean_rural} and in Urban areas its {mean_urban}\n"))
} else {
  cat(glue::glue("P value is >= 0.05 i.e. {round(z_test_result$p.value,5)}, Therefore we fail to reject the null hypothesis.\n"))
  cat(glue::glue("There is no significant difference between mean consumptions of urban and rural.\n"))
  cat(glue::glue("The mean consumption in Rural area is {mean_rural} and in Urban area its {mean_urban}\n"))
}

