subs = list.files(pattern='*.csv')

read_data <- function(filename) {
  dat <- read.csv(filename, header = FALSE)
  names(dat) = c('base','comp','rt','resp')
  dat$sub = filename
  return(dat)
}

raw = do.call(rbind, lapply(subs, read_data))

raw$base = (raw$base-1)*60 + 70
raw$comp = ( (raw$comp - 3)*0.2 +1) * raw$base
  
library(dplyr)
library(ggplot2)
library(tidyr)
library(broom)

raw %>% group_by(sub, base, comp) %>%
  summarise(prop = mean(resp)) -> sub_resp
# reverse response for two subjects
sub_resp %>% filter(sub %in% c('frequency_oT.csv',
                               'frequency_Psl.csv')) %>%
  mutate(prop = 1-prop) -> adjust_subset
# combine reversed data to the original
sub_resp %>% filter(!(sub %in% c('frequency_oT.csv',
                               'frequency_Psl.csv'))) %>%
  rbind(., adjust_subset) -> sub_resp2


sub_resp2 %>% ggplot(aes(x=comp, y = prop, 
                        color = as.factor(base))) +
  geom_point()+ geom_line() + facet_wrap(~sub)

sub_resp2 %>% filter(!(sub %in% c('frequency_cd.csv',
          'frequency_Kate.csv','frequency_sano.csv'))) %>%
  ggplot(aes(x=comp, y = prop, 
             color = as.factor(base))) +
  geom_point()+ 
  geom_smooth(method = glm, method.args = 
                list(family= binomial(logit)), se = FALSE) + 
  facet_wrap(~sub)
  
sub_resp2 %>% filter(!(sub %in% c('frequency_cd.csv',
              'frequency_Kate.csv','frequency_sano.csv'))) %>%
  group_by(sub, base) %>%
  do(tidy( glm(cbind(prop, 1-prop) ~ comp, 
      family = binomial(logit), data = .) )) -> sub_est

sub_est %>% select(one_of( c('sub','base', 'term','estimate') )) %>%
  spread(term, estimate) %>% rename(b=comp, a = `(Intercept)`) %>%
  mutate(pse = -a/b, jnd = log(3)/b) -> psejnd

psejnd %>% group_by(base) %>%
  summarise(mpse = mean(pse), mjnd = mean(jnd),
    se_pse = sd(pse)/sqrt(10-1), se_jnd = sd(jnd)/3) -> mpsejnd

ggplot(mpsejnd, aes(x = as.factor(base), y = mpse)) +
  geom_bar(stat='identity') +
  geom_errorbar(aes(ymin=mpse - se_pse, 
                    ymax = mpse + se_pse)) +
  xlab('Base frequency (Hz)') +
  ylab('Mean PSE (Hz)') + theme_bw()

psejnd$wf = psejnd$jnd  / psejnd$pse

library(ez)

ezANOVA(psejnd, dv = wf,
        wid = sub,
        within = base)

