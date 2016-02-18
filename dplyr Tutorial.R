#load package
library(dplyr)
library(hflights)

#explore data
data(hflights)
head(hflights)

#convert to local data frame
#local DF is simply a wrapper for a DF that print nicely
flights<-tbl_df(hflights)

flights

#convert data to a normal data frame to see all the column
data.frame(head(flights))

#=================================================
## filter: keep rows matching criteria
#Base R approach to filtering forces you to repeat the data frame's name
#dplyr approach is simpler to write and read

#base R appprocah to view all January 1
flights[flights$Month==1 & flights$DayofMonth==1, ]

#filter(data, conditions)
filter(flights, Month==1, DayofMonth==1)

# use pipe as OR cnodition
filter(flights, UniqueCarrier=="AA"| UniqueCarrier=="UA")

 
#=======================================================
#select: pick columns by name

#base R approcah to select the column
flights[,c("DepTime","ArrTime","FlightNum")]

#dplyr approach
select(flights,DepTime,ArrTime,FlightNum)

#Start_with / End_with / Match with the column name
select(flights, Year:DayofMonth,contains("Taxi"),contains("Delay"))

#==============================================================
## 'chaining' or 'piprlining'
#usual way to perform multiple operations in one line is by nesting
#can write commands in a natural order by using '%>%' (aka then)

#nesting method to select UniqueCarrier and DepDelay
#and filter delay >60 sec
filter(select(flights,UniqueCarrier,DepDelay),DepDelay>60)

##Chaining method
flights %>%
  select(UniqueCarrier,DepDelay) %>%
  filter(DepDelay>60)

#create two vectors and calculate Euclidian distance between them
x1<-1:5; x2<-2:6
sqrt(sum((x1-x2)^2))

#chain method
(x1-x2)^2 %>% sum() %>% sqrt()  


#=================================================================
## arrange: Reorder rows

# base R approach to select uniqueCarrier and DepDelay columns
# and sort by DepDelay
flights[order(flights$DepDelay),c("UniqueCarrier","DepDelay")]

#dplyr Approach
flights %>%
  select(UniqueCarrier,DepDelay) %>%
  arrange(DepDelay)

# dplyr Approach use "desc" for descending
flights %>%
  select(UniqueCarrier,DepDelay) %>%
  arrange(desc(DepDelay))

flights %>%
  select(UniqueCarrier,DepDelay) %>%
  arrange(DepDelay) %>%
  arrange(UniqueCarrier)

#==================================================================
## mutate: Add new variables
#Create new variables that are functions of existing variables

#base R appproach to create a new variables Speed(in mph)
flights$speed<-flights$Distance / flights$AirTime*60
flights[,c("Distance","AirTime","speed")]

#dplyr approach (print the new variable but DOES NOT store it)
flights %>%
  select(Distance,AirTime) %>%
  mutate(speed=Distance/AirTime*60)
 
#dplyr store the nw variable
flights <- flights%>% 
  mutate(speed = Distance/AirTime*60)


#==============================================================
## summarise: Reduce variables to values
# primarily useful with data that has been grouped by one or more variables

# 'group_by' creates the groups that will be operated on
# 'summarise' uses the provided aggregation function to summarise each group

# base R approach to calculate the average arrival delay to each destination
head(with(flights,tapply(ArrDelay,Dest,mean,na.rm=TRUE)))
head(aggregate(ArrDelay ~ Dest,flights,mean))

# dplyr approach: create a table grouped by DEst, and then summarise each group
#   by taking the mean of ArrDelay
flights %>%
  group_by(Dest) %>%
  summarise(avg_delay=mean(ArrDelay,na.rm=TRUE))

flights %>%
  summarise(avg_delay=mean(ArrDelay,na.rm=TRUE))

mean(flights$ArrDelay,na.rm = T)

## 'summarise_each allows you to apply the same summary function to 
    # multiple  columns at once

# note: 'mutate_each' also avialable

# for each carrier, calculate the percentage of flights Cancelled or diverted

flights %>%
  group_by(UniqueCarrier) %>%
  summarise_each(funs(mean),Cancelled,Diverted)
  
# for each carrier, calculate the minimum 
  # and maximum arribal and departure delays

flights %>%
  group_by(UniqueCarrier) %>%
  summarise_each(funs(min(.,na.rm=TRUE),max(.,na.rm=TRUE)), 
                 matches("Delay"))

# Helper function 'n()' counts the total number of flights 
  # and sort in descending order
flights %>%
  group_by(Month,DayofMonth) %>%
  summarise(flights_count=n()) %>%
  arrange(desc(flights_count))

# rewrite more cimply with the 'tally' function
flights %>%
  group_by(Month,DayofMonth) %>%
  tally(sort=TRUE)

# for each destination, count the total number of flights
  # and the number of distinct planes that flew there
flights %>%
  group_by(Dest) %>%
  summarise(flights_count = n(), plane_count=n_distinct(TailNum))

## Grouping can sometimes be useful without summarising

# for each destincation, show the nyumber of cancelled 
  # and not cancelled flights
flights %>%
  group_by(Dest) %>%
  select(Cancelled) %>%
  table() %>%
  head()

## Window Functions

# **Aggregation function(like 'mean') takes n inputs and returns 1 valule
# [window function] (http://cran.r-project.org/web/packages/dplyr/vignettes/window-function.html)
  # takes n inputs and returns n values

# **Includes ranking and ordering functions (like'min_rank'), offset
  # function('lead' and 'lag'), and cumulative aggregates(like 'cummean')

# for each carrier, calculate which two days of the year they had their longest departure delays

# note: smallest (not largest) value is ranked as 1, 
  # so you have to use 'desc' to rank by largest value
flights %>%
  group_by(UniqueCarrier) %>%
  select(Month,DayofMonth,DepDelay) %>%
  filter(min_rank(desc(DepDelay))<=2) %>%
  arrange(UniqueCarrier, desc(DepDelay))

# rewrite more simply with the 'top_n' function
flights %>%
  group_by(UniqueCarrier) %>%
  select(Month,DayofMonth, DepDelay) %>%
  top_n(2) %>%
  arrange(UniqueCarrier,desc(DepDelay))

# for each month, calculate the numner of flights and the change from the previous month
flights %>%
  group_by(Month) %>%
  summarise(flights_count = n()) %>%
  mutate(change=flights_count - lag(flights_count)) # lag : early value

# rewrite more simply with the 'tally' function
flights %>%
  group_by(Month) %>%
  tally() %>%
  mutate(change = n -lag(n))

## other useful Convenience Functions

# randomly sample a fixed number of rows, without replacement
flights %>% sample_n(5)

# randomly sample a fraction of rows, with replacement
flights %>% sample_frac(0.25,replace=TRUE)

# base R approach to view the structure of an object
str(flights)

# dplyr approach: better formatting, and adapts to your screen width
glimpse(flights)


## Connecting to Databases

# connext to an SQLite databases containing the hflights data
my_db<-src_sqlite("my_db.slite3")

# connect to the "hflights" table in taht database
flights_tbl<-tbl(my_db,"hflights")

# example query with our data frame
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay))

# identicalquery using the database
flights_tbl %>%
  select(UniqueCarrier,DepDelay) %>%
  arrange(desc(DepDelay))

# you can write the SQL commands yourself
## dplyr can tell you the SQL commands
flights_tbl %>%
  select(UniqueCarrier,DepDelay) %>%
  arrange(desc(DepDelay)) %>%
  explain()
  
