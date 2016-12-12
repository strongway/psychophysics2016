
filename <- 'stroop_kris.csv'

read_stroop <- function(filename) {
     fullname = paste0('stroop_', filename, '.csv')
    dat = read.csv(fullname, header = FALSE)
    names(dat) = c('color','congruency','dummy','rt','acc')
    dat$color <- factor(dat$color, labels = c('red','blue','green') )
    dat$congruency <- factor(dat$congruency, labels = c('congruent', 
                                              'incongruent','neutral'))
    dat$sub = filename
    
    return(dat)
}

subs = c('Abhishek','Ann8147','Dav8044','Kat6323','kris',
         'Luc4923','Mrc9929','Nat8147','Psl8147','Sam8147','san8147')

sub2 <- list.files(pattern = '*.csv')
raw = do.call(rbind, lapply(subs, read_stroop))

library(dplyr)
library(ggplot2)

raw %>% filter(acc == 1) %>% group_by(sub, congruency) %>%
  summarise(mrt = mean(rt)) -> msubData

msubData %>% group_by(congruency) %>%
  summarise(mmrt = mean(mrt), se = sd(mrt)/sqrt(10)) %>%
  ggplot(aes(x=congruency,y = mmrt, color = congruency, fill = congruency)) + 
  geom_bar(stat='identity') + theme_bw() +
  geom_errorbar(aes(ymin=mmrt-se,ymax=mmrt+se)) +
  coord_cartesian(ylim = c(0.4,0.9)) +
  ylab('Mean RTs (s)')

library(ez)

results <- ezANOVA(msubData,dv = mrt, 
                   wid = sub,  within = congruency)
