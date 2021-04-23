library(tidyverse)
library(readxl)
library(butteR)
library(srvyr)

# read data
dap <- read_csv("inputs/analysis_dap_MC_ev_MT.csv")

df_data <- read_xlsx("inputs/BRIDGE Endline Survey - GM2.xlsx")

# data cleaning for some numeric variables coming as character due to un cleaned data
df_data$crop_production_kgs %>% 
  sort()
df_data$crop_production_kgs <- as.numeric(df_data$crop_production_kgs)

#  select variables from dap that are in the dataset
variables_to_analyse <-  dap$variable[dap$variable %in% colnames(df_data)  ]

# convert df to survey using the srvyr package
df_svy <- as_survey(df_data)
df_svy

df_svy$variables

overall_analysis <- butteR::survey_collapse(df = df_svy, 
                                            vars_to_analyze = variables_to_analyse)
# disagregating by population status
by_population_status <- butteR::survey_collapse(df = df_svy, 
                                            vars_to_analyze = variables_to_analyse,
                                            disag = "participant_category"
                                              
                                            )
df_svy$variables

# combine analysis outputs
overall_analysis <- overall_analysis %>% 
  mutate(
    analysis_level = "overall"
  )

by_population_status <- by_population_status %>% 
  mutate(
    analysis_level = "population_status"
  )

combined_analsis <- bind_rows(by_population_status, overall_analysis)

# trick to combine disaggregation analysis faster
res <- list()

res$overall_analysis <- butteR::survey_collapse(df = df_svy, 
                                            vars_to_analyze = variables_to_analyse)
# disaggregating by population status
res$by_population_status <- butteR::survey_collapse(df = df_svy, 
                                                vars_to_analyze = variables_to_analyse,
                                                disag = "participant_category"
                                                
)

combined_analysis_with_list <- bind_rows(res)
