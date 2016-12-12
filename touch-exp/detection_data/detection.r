subs = list.files(pattern='*.csv')

read_data <- function(filename) {
  dat <- read.csv(filename, header = FALSE)
  names(dat) = c('cond','freq','rt','resp')
  dat$cond = factor(dat$cond)
  dat$resp = factor(dat$resp, labels = c('constant','change'))
  dat$sub = filename
  return(dat)
}

raw = do.call(rbind, lapply(subs, read_data))

library(dplyr)
library(ggplot2)
library(tidyr)

raw %>% group_by(sub,freq, resp) %>% 
  summarise(n = n()) %>% 
  filter(resp == 'change') %>% 
  mutate(per = n/30, zscore = qnorm(per)) -> sig_dat

sig_dat %>% select(one_of(c('sub','freq','zscore'))) %>% 
  spread(freq, zscore) -> sig_detection

names(sig_detection) <- c('sub','fa','hit1','hit2')

sig_detection %>% mutate(d1 = hit1 - fa, d2 = hit2 - fa,
                  c1 = -(hit1+fa)/2, c2 = -(hit2+fa)/2) ->sd

sd %>% ggplot(aes(x=sub, y = d1, group =1)) + 
  geom_line() + geom_point() +
  geom_line(aes(y = d2, group = 2), color = 'red') +
  theme_bw()

sd %>% ggplot(aes(x=sub, y = c1, group =1)) + 
  geom_line() + geom_point() +
  geom_line(aes(y = c2, group = 2), color = 'red') +
  theme_bw()

