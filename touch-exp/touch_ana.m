%% 
data = dataset({results, 'freq','comp','rt','resp'});

data.freq = data.freq*50 + 50;

data.cfreq = data.freq.* (data.comp - 3)*0.2 + data.freq;

%%
[m e c g] = grpstats(data.resp, {data.freq, data.comp});

rf = [-0.4; -.2; 0; 0.2; 0.4];

figure; 
plot(repmat(rf,1,3), reshape(m,5,3));

%%

figure; hold on;
markers = 'sdo';
colors = 'rgb';

for ifreq = 1:3
    cur_prop = m([1:5]+(ifreq-1)*5);
    counts = c([1:5]+(ifreq-1)*5);
    base = 50+ ifreq*50;
    x = base + base*rf;
    xc = min(x):max(x);
    y = cur_prop.*counts;
    b = glmfit(x,[y counts],'binomial','link','logit');   
    thresholds(ifreq) = -b(1)/b(2);
    jnds(ifreq) = log(3)/b(2);
    weber_fractions(ifreq) = jnds(ifreq)/base;
    
    yfit = glmval(b,xc,'logit');
    
    plot(x,cur_prop, [colors(ifreq), markers(ifreq)]);
    plot(xc,yfit,colors(ifreq));
    plot([thresholds(ifreq), thresholds(ifreq)], [0 0.5], colors(ifreq));
    
end
%%
subnames = {'alex81','b45','Elena54','Franzi76',...
    'isa93','ja23','Lisa24', 'vilim47'};
figure; 
for isub = 1:length(subnames)
    load(['tdur_', subnames{isub}  ]);
    data = dataset({results(31:end,:),'amp','dur','rt','resp'});

    [m e c g] = grpstats(data.resp,{data.amp, data.dur});
    dur = 0.3:0.1:0.9; 
    durc = 0.3:0.01:0.9;
    subplot(3,3,isub); % figure;
    hold on;
    colors = 'br';
    markers = 'do';
    for i=1:2
        range = [1:7] + (i-1)*7;
        b = glmfit(dur,[m(range).*c(range)   c(range)], ...
            'binomial','link','logit');   
        thresholds(isub, i) = -b(1)/b(2);
         yfit = glmval(b,durc,'logit');
        plot(dur, m(range), [colors(i), markers(i)]);
        plot(durc,yfit, colors(i));
    end
end

%%
mt = mean(thresholds);
me = std(thresholds)/sqrt(length(thresholds)-1);

figure; hold on;
errorbar(mt,me);
[h p] = ttest(thresholds(:,1), thresholds(:,2))
text(1.5,.6,num2str(p));











