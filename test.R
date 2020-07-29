
# SETUP -------------------------------------------------------------------

use <- function(library, repo = getOption('repos')){ 
  if(!is.element(library, .packages(all.available = TRUE))) {install.packages(library)}
  library(library,character.only = TRUE)}

use('tidyverse')
use('data.table')
use('bizdays')
use('timeDate')


# DATA -----------------------------------------------------------

data <- read.csv('./dailyreturns.csv', sep =',', header = TRUE, encoding = 'utf-8') # Load default data from Copula project
data$Date <- lubridate::mdy(data$Date) # Convert dates to date objects
data <- data %>% dplyr::filter(Date <= '1/15/2001' %>% lubridate::mdy()) # Keep only first few days for simplicity

# Convert to Long-format
data <- melt(data %>% as.data.table(), 
             id.vars = 'Date', 
             variable.name = 'Ticker', 
             value.name = 'Return') %>% 
  as.data.frame()

data # Show what data looks like


#CALENDAR ------------------------------------------

load_rmetrics_calendars(2000:lubridate::year(Sys.Date()) +1) # Load standard trading calendars...
bizdays::create.calendar(name="Std_cal", weekdays=c('saturday', 'sunday')) # ... Or Create a custom one

# CHOOSE THE DEFAULT CALENDAR (UNCOMMENT YOUR CHOICE)

# bizdays.options$set(default.calendar = "Rmetrics/NYSE")
bizdays.options$set(default.calendar = "Std_cal")


# MATCHING ----------------------------------------------------------------

match.df <- data # Copy data into new df

# Match Previous business day returns (MSCI World)
match.df$Return_minus1 <- match(interaction(match.df$Date %>% bizdays::offset(., -1), match.df$Ticker), 
                                interaction(data$Date, data$Ticker)) %>%
  data$Return[.]

# Match Next business day returns (MSCI World)
match.df$Return_plus1 <- match(interaction(match.df$Date %>% bizdays::offset(., +1), match.df$Ticker), 
                                interaction(data$Date, data$Ticker)) %>%
  data$Return[.]

match.df # Show what data looks like

#* Note the difference between the calendars for Jan 15th:
#* This was Martin Luther King Day, and therefore not recognized as a trading day in the NYSE calendar!