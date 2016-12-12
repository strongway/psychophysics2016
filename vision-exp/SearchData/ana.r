subs = list.files(pattern='*.txt')

read_search <- function(filename) {
  dat <- read.csv(filename, header = FALSE)
  names(dat) = c('target','setSize','block','resp','rt')
  dat$sub = filename
  return(dat)
}

raw = do.call(rbind, lapply(subs, read_search))
raw$acc <- raw$target == raw$resp
raw$target <- factor(raw$target, labels = c('present','absent'))
raw$setSize <- raw$setSize*4+4 # 8, 12, 16 items
raw$block <- factor(raw$block, labels = c('dynamic','static'))
raw$sub <- factor(raw$sub)

library(dplyr)
library(ggplot2)
library(ez)

raw %>% group_by(sub, setSize, target, block) %>%
  summarise(merror = 1 - mean(acc)) -> msuberrors

msuberrors %>% group_by(setSize, target, block) %>%
  summarise(errors = mean(merror)) %>%
  ggplot(aes(x = setSize, y = errors, 
             color = block, shape = target )) +
  geom_point() + geom_line() 

raw %>% filter(acc == TRUE) %>% 
  group_by(sub, setSize, target, block) %>%
  summarise(mrt = mean(rt)) -> msubrts

msubrts %>% group_by(setSize, target, block) %>%
  summarise(mmrt = mean(mrt)) %>%
  ggplot(aes(x = setSize, y = mmrt, 
             color = block, shape = target )) +
  geom_point(size=3) + geom_line() 

ezANOVA(msubrts,
        dv = mrt,
        within = .(setSize, target, block),
        wid = sub)


ezANOVA(msubrts %>% filter(target == 'present'),
        dv = mrt,
        within = .(setSize, block),
        wid = sub)
