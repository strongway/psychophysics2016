function anaVisualExps(name_of_exp, name_of_datafile)

try
    % load data
    dat = load(name_of_datafile);
    results = dat.results;
    
    % determine experiment and run corresponding analysis    
    switch name_of_exp
        case 'stroop'
            ana_stroop(results);            
        case 'simon'
            ana_simon(results);            
        case 'search'
            ana_search(results);
        case 'flash'
            ana_flash(results);
        case 'ablink'
            ana_ablink(results);            
        otherwise
            disp('Wrong experiment name, please specify another one...');
    end
    
catch ME    
    disp(ME.message);
    disp(ME.stack(1).line);
end

end
%% stroop
function ana_stroop(results)
% color, congruency, words, rt, acc
% columns: 1, 2, 3, 4, 5
    try
        disp('== Analyzing Stroop Effect ==');
        figure;
        subplot(3,1,[1 2]);
        title('RT depends on congruency');
        for ic = 1:3 % congrunent, incongruent,'neutral'
            idx = results(:,5)==1 & results(:,2) == ic;
            m(ic) = mean(results(idx,4));
            e(ic) = std(results(idx,4))/sqrt(sum(idx));
        end
%        idx = results.acc == 1;
%        [m e g]= grpstats(results.rt(idx), results.congruency(idx),...
%            {'mean','sem','gname'});
        errorbar(m,e);
        ylabel('RT in [s]');
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'congruent','incongruent','neutral'});  

        subplot(3,1,3);
        title('ACC depends on congruency');
%        [m e g]= grpstats(results.acc, results.congruency,...
%            {'mean','sem','gname'});
        m = []; e=[];
        for ic = 1:3 % congrunent, incongruent,'neutral'
            idx = results(:,2) == ic;
            m(ic) = mean(results(idx,5));
            e(ic) = std(results(idx,5))/sqrt(sum(idx));
        end
        bar(m);
        hold on;
        errorbar(m,e,'linestyle','none');
        ylabel('Accuracy')
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'congruent','incongruent','neutral'});
        axis([0 4 0 1.1]);

        disp('Done.');
    catch ME
        disp(ME.message);
    end
end
%% simon
function ana_simon(results)
% color, location, congruency, rt, acc
% 1, 2, 3, 4, 5
    try
        
        disp('== Analyzing Simon Effect ==');
        figure;
        subplot(3,1,[1 2]);
        title('RT depends on congruency');
        for ic = 1:3 % congrunent, incongruent,'neutral'
            idx = results(:,5)==1 & results(:,3) == ic;
            m(ic) = mean(results(idx,4));
            e(ic) = std(results(idx,4))/sqrt(sum(idx));
        end
%        idx = results.acc == 1;
%        [m e g]= grpstats(results.rt(idx), results.congruency(idx),...
%            {'mean','sem','gname'});
        errorbar(m,e);
        disp([m; e]);
        ylabel('RT in [s]');
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'congruent','incongruent','neutral'});  

        subplot(3,1,3);
        title('ACC depends on congruency');
        for ic = 1:3 % congrunent, incongruent,'neutral'
            idx =  results(:,3) == ic;
            m(ic) = mean(results(idx,5));
            e(ic) = std(results(idx,5))/sqrt(sum(idx));
        end
%        [m e g]= grpstats(results.acc, results.congruency,...
%            {'mean','sem','gname'});
        bar(m);
        hold on;
        errorbar(m,e,'linestyle','none');
        ylabel('Accuracy')
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'congruent','incongruent','neutral'});
        axis([0 4 0 1.1]);            
        disp('Done.');
    catch ME
        disp(ME.message);
    end
end
%% visual search
function ana_search(results)
% setsize, singleton, target_presence, rt, response, acc
% singleton: 1 color, 2 orientation

    try
        disp('== Analyzing Visual Seach Performance ==');
        idx_ct = results(:,2) == 1; %color target
        idx_ot = ~idx_ct; %orientation target
%        idx_ct = double(results.condition)== 1;
%        idx_ot = ~idx_ct;
        offs = .1;
        xp1 = [1 2 3]-offs;
        xp2 = [1 2 3]+offs;
            
        % analysis of color trials
        dt = results(idx_ct,:);

%[m e c g] = grpstats(dt.acc, {dt.target_presence, ...  
%            dt.setsize});            
        for it = 0:1 %target
            for is = 1:3 %setsize
                idx =  dt(:,3) == it & dt(:,1) == is & dt(:,6) == 1;
                m(it+1,is) = mean(dt(idx,4));
                e(it+1,is) = std(dt(idx,4))/sqrt(sum(idx));
            end
        end
%        subplot(3,2,5);
        figure;
        hold on;
        errorbar(xp1,m(1,:),e(1,:),'r');
        errorbar(xp2,m(2,:),e(2,:),'g');
        xlabel('Set size');
        ylabel('RT in [S]')
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'4','8','16'});
%        axis([0 4 0 1.1]);
% 
%         [m e] = grpstats(dt.rt(dt.acc==1), ...
%             {dt.target_presence(dt.acc==1), ...
%             dt.setsize(dt.acc==1)}, {'mean','sem'});            
%         subplot(3,2,[1 3]); hold on;
%         title('Color trials');
%         errorbar(xp1,m(1:3),e(1:3),'r');
%         errorbar(xp2,m(4:6),e(4:6),'g');
%         ylabel('RT in [s]')
%         set(gca,'xtick',1:3);
%         set(gca,'xticklabel',{'4','8','16'});
        legend('location','northwest','Absent', 'Present');

        % analysis of orientation trials
        dt = results(idx_ot,:);

 %       [m e] = grpstats(dt.acc, {dt.setsize, ...
 %           dt.target_presence}, {'mean','sem'});            
         for it = 0:1 %target
            for is = 1:3 %setsize
                idx =  dt(:,3) == it & dt(:,1) == is & dt(:,6) == 1;
                m(it+1,is) = mean(dt(idx,4));
                e(it+1,is) = std(dt(idx,4))/sqrt(sum(idx));
            end
         end
        figure; 
%       subplot(3,2,6); 
        hold on;
        errorbar(xp1,m(1,:),e(1,:),'r');
        errorbar(xp2,m(2,:),e(2,:),'g');
%        errorbar(xp1,m(1:3),e(1:3),'r');
%        errorbar(xp2,m(4:6),e(4:6),'g');
        ylabel('RT in [s]')
        set(gca,'xtick',1:3);
        set(gca,'xticklabel',{'4','8','16'});
%         axis([0 4 0 1.1]);
% 
%         [m e] = grpstats(dt.rt(dt.acc==1), ...
%             {dt.target_presence(dt.acc==1), ...
%             dt.setsize(dt.acc==1)}, {'mean','sem'});            
%         subplot(3,2,[2 4]); hold on;
%         title('Orientation trials');
%         errorbar(xp1,m(1:3),e(1:3),'r');
%         errorbar(xp2,m(4:6),e(4:6),'g');
%         xlabel('Set size');
%         ylabel('RT in [s]')
%         set(gca,'xtick',1:3);
         set(gca,'xticklabel',{'4','8','16'});            
         disp('Done.');
    catch ME
        disp(ME.message);
    end
end
%% flash-lag
function ana_flash(results)
    try
        disp('== Analyzing Flash Lag Effect ==');

        offset = double(results.offset);
        response = double(results.response);
        m = grpstats(response-1, offset);

        y1 = m;
        y2 = ones(length(y1),1);
        y = [y1 y2];

        % real offset from -80 to 40 
        x = -80:20:40;

        % fitting the curve vis glmfit
        b = glmfit(x, y, 'binomial','logit');
        threshold = -b(1) / b(2);

        xc = min(x)-5:.1:-min(x)+5;
        curve = glmval(b,xc,'logit');
        figure;
        hold on;
        plot(xc,curve,'color','b','linestyle','-');
        plot(x,y1,'bd');            

        ylabel('Response')
        set(gca,'ytick',[0 .5 1]);
        set(gca,'yticklabel',{'Flash leading','50%', 'Flash lagging'});

        xlabel('Actual position');
        set(gca,'xtick',[min(xc)+5 0 max(xc)-5]);
        set(gca,'xticklabel', {'Flash leading', ...
            'Phy. alignment', 'Flash lagging'}); 

        plot(0,0:.001:1,'r');
        h = plot(threshold,0:.01:.5,'k.-');
        legend(h(1),'Subjective alignment','location','northwest');
        legend('boxoff');
        axis([min(xc)-10 max(xc)+10 -.01 1.01]);
        
    catch ME
        disp(ME.message);
    end                
end
%% attentional blink
function ana_ablink(results)
% 'lag','acct1','acct2','post1','post2', 'tsta', 'rtt1', 'rtt2'}
    try
        disp('== Analyzing Attentional Blink Effect ==');
        
        figure;
        dta = results;
%        dtb = results(results.acct1 == 1,:);
        dtb = results(results(:,2)==1,:); %select correct trials
%         [m0 e0] = grpstats(dta.acct1,dta.lag);
%         [m1 e1] = grpstats(dta.acct2,dta.lag);
%        [m2 e2] = grpstats(dtb.acct2,dtb.lag);
        for il = 1:7
            idx = dtb(:,1) == il;
            m2(il) = mean(dtb(idx,3));
            e2(il) = std(dtb(idx,3))/sqrt(sum(idx));
        end
        hold on;
%         errorbar(1:7,m0,e0,'b-.');
        errorbar(1.1:7.1,m2,e2,'r');
        xlabel('T1-T2 lag');
        ylabel('Accuracy');
        axis([0 8 0 1.1]);        
        
    catch ME
        disp(ME.message);
    end
    
end