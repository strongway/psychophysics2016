subs = list.files(pattern='*.csv')

read_data <- function(filename) {
  dat <- read.csv(filename, header = FALSE)
  names(dat) = c('Intensity','Duration','rt','resp')
  dat$Intensity = factor(dat$Intensity, 
                         labels=c('Low','High'))
  dat$trial = 1:nrow(dat)
  dat$sub = filename
  return(dat)
}

raw = do.call(rbind, lapply(subs, read_data))

library(dplyr)
library(ggplot2)
library(tidyr)
library(broom)

raw %>% filter(trial>10) %>%
  group_by(sub, Intensity, Duration) %>%
  summarise(prop = mean(resp)) -> subdata

subdata %>% ggplot(aes(x=Duration, 
           y = prop, color = Intensity)) +
  geom_point() +
  geom_smooth(method = glm, method.args = 
      list(family= binomial(logit)), se = FALSE) +
  facet_wrap(~sub)

subdata %>% group_by(sub, Intensity) %>%
  do(tidy(glm( cbind(prop,1-prop) ~ Duration,
               family = binomial(logit), data = .))) %>%
  select(one_of( c('sub','Intensity', 'term','estimate') )) %>%
  spread(term, estimate) %>% 
  rename(b=Duration, a = `(Intercept)`) %>%
  mutate(pse = -a/b, jnd = log(3)/b) -> pse

pse %>% filter( sub != 'duration_zey.csv') %>%
  group_by(Intensity) %>%
  summarise(mpse = mean(pse), se = sd(pse)/sqrt(11)) %>%
  ggplot(aes(x = Intensity,y = mpse, 
             fill = Intensity, color = Intensity)) + 
  geom_bar(stat='identity') +
  geom_errorbar(aes(ymin=mpse-se, ymax = mpse+se)) +
  coord_cartesian(ylim=c(0.5,0.7)) +
  ylab('Mean PSE (s)')


