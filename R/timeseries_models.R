library(tidyquant)
library(timetk)
library(tidyverse)
# fpp3 seasonal fable.prophet
library(fpp3)
library(seasonal)
library(fable.prophet)
library(tsibble)
library(kableExtra)
library(ragg)
library(plotly)


#BIST Food Beverage (XGIDA)
df_XGIDA <- read_csv("https://raw.githubusercontent.com/mesdi/blog/main/bist_food.csv")

df_xgida <- 
  df_XGIDA %>% 
  janitor::clean_names() %>% 
  mutate(date = parse_date(date,"%m/%d/%Y")) %>% 
  select(date, "xgida" = price) %>% 
  slice(-1)

#Converting df_xgida to tsibble
df_xgida_tsbl <-
  df_xgida %>% 
  mutate(date = yearmonth(date)) %>% 
  as_tsibble()

#First Trust Indxx Global Agriculture ETF (FTAG)
df_ftag <- 
  tq_get("FTAG", from = "2000-01-01") %>% 
  tq_transmute(select = close, mutate_fun = to.monthly) %>%
  mutate(date = as.Date(date)) %>% 
  rename("ftag" = close)

#Converting df_ftag to tsibble
df_ftag_tsbl <-
  df_ftag %>% 
  mutate(date = yearmonth(date)) %>% 
  as_tsibble()


#Merging all the data
df_merged <- 
  df_ftag %>% 
  left_join(df_xgida) %>% 
  drop_na()


#The function of the table of accuracy ranking  of the bagged models
fn_acc <- function(var = ftag){
  #Decomposition for bootstrapping preprocess
  stl_train <- 
    df_train %>% 
    model(STL({{var}}))
  
  set.seed(12345)
  sim <- 
    stl_train %>% 
    fabletools::generate(new_data=df_train,
                         times=100,
                         bootstrap_block_size=24) %>% 
    select(-.model)
  
  fit<- 
    sim %>% 
    model(
      ETS = ETS(.sim),
      
      Prophet = prophet(.sim ~ season(period = 12, 
                                      order = 2,
                                      type = "multiplicative")),
      
      ARIMA = ARIMA(log(.sim), stepwise = FALSE, greedy = FALSE)
    ) 
  
  #Bagging
  fc <-
    fit %>% 
    forecast(h = 12)
  
  #Bagged forecasts
  bagged <- 
    fc %>%  
    group_by(.model) %>% 
    summarise(bagged_mean = mean(.mean))
  
  #Accuracy of bagging models 
  bagged %>% 
    pivot_wider(names_from = ".model",
                values_from = "bagged_mean") %>% 
    mutate(ARIMA_cor = cor(ARIMA, df_test %>% pull({{var}})),
           ETS_cor = cor(ETS, df_test %>% pull({{var}})),
           Prophet_cor = cor(Prophet, df_test %>% pull({{var}})),
           ARIMA_rmse = Metrics::rmse(df_test %>% pull({{var}}),ARIMA),
           ETS_rmse = Metrics::rmse(df_test %>% pull({{var}}),ETS),
           Prophet_rmse = Metrics::rmse(df_test %>% pull({{var}}),Prophet)) %>% 
    as_tibble() %>% 
    pivot_longer(cols= c(5:10),
                 names_to = "Models",
                 values_to = "Accuracy") %>% 
    separate(Models, into = c("Model","Method")) %>% 
    pivot_wider(names_from = Method, 
                values_from = Accuracy) %>% 
    mutate(cor = round(cor, 3),
           rmse = round(rmse, 2)) %>% 
    select(Model, Accuracy = cor, RMSE = rmse) %>% 
    unique() %>% 
    arrange(desc(Accuracy)) %>% 
    kbl() %>%
    kable_styling(full_width = F, 
                  position = "center") %>% 
    column_spec(column = 2:3, 
                color= "white", 
                background = spec_color(1:3, end = 0.7)) %>% 
    row_spec(0:3, align = "c") %>% 
    kable_minimal(html_font = "Bricolage Grotesque")
  
}



#Modeling the FTAG data

#Splitting the data
df_train <- 
  df_ftag_tsbl %>% 
  filter_index(. ~ "2022 Sep")

df_test <- 
  df_ftag_tsbl %>% 
  filter_index("2022 Oct" ~ .)

# slow
system.time(ftag_table <- fn_acc(ftag))

ftag_table