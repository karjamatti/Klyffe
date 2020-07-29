
# SETUP -------------------------------------------------------------------

use <- function(library, repo = getOption('repos')){ 
  if(!is.element(library, .packages(all.available = TRUE))) {install.packages(library)}
  library(library,character.only = TRUE)}

use('tidyverse')
use('bizdays')


# Data Creation -----------------------------------------------------------

data <- read.csv('./dailyreturns.csv', sep =',', header = TRUE, encoding = 'utf-8') # Load default data from Copula project
data$Date <- lubridate::mdy(data$Date) # Convert dates to date objects
data <- data %>% dplyr::filter(Date <= '1/15/2001' %>% lubridate::mdy()) # Keep only first few days for simplicity
data # Show what data looks like

# Create Standard Calendar object ------------------------------------------

bizdays::create.calendar(name="Std_cal", weekdays=c('saturday', 'sunday'))

# Matching ----------------------------------------------------------------

match.df <- data.frame('Date' = data$Date) # Create empty df with just dates

# Match same day returns (MSCI World index as an example)
match.df$Return <- match(match.df$Date, data$Date) %>% 
  data$MSCI.World[.] 

# Match Previous business day returns (MSCI World)
match.df$Return_minus1 <- match(match.df$Date %>% bizdays::offset(., -1, "Std_cal"), data$Date) %>% 
  data$MSCI.World[.]

# Match Next business day returns (MSCI World)
match.df$Return_plus1 <- match(match.df$Date %>% bizdays::offset(., +1, "Std_cal"), data$Date) %>% 
  data$MSCI.World[.]

match.df # Show what data looks like
