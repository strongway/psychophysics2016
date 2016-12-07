function results = VisualExps(name_of_demo)
% functions for runing demos of classical experiments in cognitive
% psychology
% Usage:
%   [results ] = VisualExps([name_of_demo]);
%
% Available modules are now:
% 'stroop'      :   Stroop Effect
% 'simon'       :   Simon Effect
% 'search'      :   Visual Search
% 'flash'       :   Flash-lag Effect
% 'ablink'      :   Attentional Blink

try% Determine what experiment to run
    switch nargin 
        case 0
            name_of_demo = '';
            parameters = [];
        case 1
            parameters = [];
    end
    
    if isempty(parameters)
    end
    
    % Get Device and Subject information
    expinfo = run_getinfo(name_of_demo);    
    HideCursor;
    KbName('UnifyKeyNames');
    % Open window
    Screen('Preference', 'SkipSyncTests', 1); % for TFT monitor
    screens=Screen('Screens');
    screenNumber=max(screens);
    [expinfo.windowPtr expinfo.windowRect] = ...
        Screen('Openwindow', screenNumber, 0);
    expinfo.flipintv = Screen(expinfo.windowPtr,'GetFlipInterval');
    Screen('TextFont',expinfo.windowPtr,'Arial');
    Screen('TextSize',expinfo.windowPtr,18);
    Screen('TextColor',expinfo.windowPtr,128);
            
    switch name_of_demo
        case 'simon'
            results = run_simon(expinfo);            
        case 'search'
            results = run_search(expinfo);
        case 'flash'
            results = run_flash(expinfo);
        case 'ablink'
            results = run_ablink(expinfo);
        otherwise
            results = run_stroop(expinfo);
    end
    
    % Save data;
    status = run_save(expinfo, results);
    if status
        disp(['Data saved : ' expinfo.filename]);
    end
    
    % Ending experiment
    msg = 'Experiment ends! Thank you!';
    run_disp(expinfo.windowPtr, msg);
    WaitSecs(3);
    Screen('Closeall');
    ShowCursor;
    
catch ME
    Screen('Closeall');
    disp(ME.message);
    ShowCursor;
end

%% Get devices and subject info:
function expinfo = run_getinfo(name_of_demo)
% function for setting device and subject info
try
    param = { 'Subject Name',...
                    'Age (#)',...
                    'Gender (F or M?)',...
                    'Handedness  (L or R)',...
                    'MonitorSize (inch)',...
                    'Viewing Distance (cm)'};
    defau = {'sub', '', '', 'R', '21', '70'};
    promp = inputdlg(param, 'Subject Info', 1, defau);
    
    expinfo.subname = promp{1};
    expinfo.subage = promp{2};
    expinfo.subgender = promp{3};
    expinfo.subhand = promp{4};
    expinfo.monitor = str2num(promp{5});
    expinfo.visdis = str2double(promp{6});
%    expinfo.refresh = str2double(promp{6});
    
    switch name_of_demo
        case 'simon'
            tmp = 'simon_';
        case 'search'
            tmp = 'search_';
        case 'flash'
            tmp = 'flash_';
        case 'ablink'
            tmp = 'blink_';
        otherwise
            tmp = 'stroop_';
    end
    namerand = num2str(rand);
    subname = [expinfo.subname(1:3) namerand(3:6)];
    expinfo.filename = [tmp subname '.mat'];
    
catch ME
    disp(ME.message);
end

function status = run_save(expinfo, results)
% function for saving data
try    
    save(expinfo.filename, 'results');
    status = 1;
catch ME
    status = 0;
    disp(ME.message);
end

function run_disp(windowPtr, msg)
% function for displaying message on Psych-window
try    
	Screen('TextSize',windowPtr,24);
    DrawFormattedText(windowPtr, msg,'center','center',128,80,[],[],1.5);
    Screen(windowPtr,'Flip');
catch ME
    disp(ME.message);
end

%% Demo modules

%% Stroop Effect
function results = run_stroop(expinfo)
try
    
    
    color_all = {[255 0 0], [0 0 255], [0 255 0]};    
    str_color = {'RED', 'BLUE', 'GREEN', 'WHITE', 'YELLOW', 'BLACK', ...
                'ORANGE', 'PURPLE', 'BROWN', 'PINK','RED', 'BLUE',...
                'GREEN', 'WHITE'};  
    str_neut1 = {'WHEN', 'YOUR', 'SAID', 'EACH', 'SOME', ...
                 'CAN', 'USE', 'SHE', 'HOW', 'OUT', ...
                 'OTHER', 'THERE', 'WHICH', 'ABOUT', 'WOULD'...
                 'NUMBER', 'PEOPLE', 'FOLLOW', 'BEFORE', 'REALLY'}; 
    str_neut2 = str_neut1;         
    num_lett = 2+ceil(3*rand(20,1));
    for i = 1:20
        str_cur = 64 + ceil(26*rand(1,num_lett(i)));
        str_neut2{i} = char(str_cur);
    end
    str_nocol = [str_neut1 str_neut2];
    str_key = [KbName('LeftArrow'), KbName('DownArrow'), KbName('RightArrow')];

    matrix = genTrials(15, [3 3]);
    % column 1 : color -> red blue green 
    % column 2 : congruency: 1 congrunt 2 incon 3 neutral
    
    idx = matrix(:,2) == 1; % congruent trials
    matrix(idx,3) = matrix(idx,1);
    idx = matrix(:,2) == 3; % neutral
    matrix(idx,3) = ceil(40*rand(sum(idx),1));
    idx = matrix(:,2) == 2; % incon
    matrix(idx,3) = matrix(idx,1) + ceil(9*rand(sum(idx),1));
    
    % pre allocation
    num_trl = size(matrix,1);    
    t_sta = zeros(num_trl,1);
    t_end = zeros(num_trl,1);
    t_acc = zeros(num_trl,1);
    t_rand = 1+rand(num_trl,1)/2;
        
    % disp instruction
    windowPtr = expinfo.windowPtr;
    msg = ['In this experiment, you are going to make key press ' ...
           'response to the COLOR of the strings you see on the ' ...
           'center of the screen. In each trial, a string consisted ' ...
           'of letters will be presented on the screen in one of ' ...
           'the 3 possible colors: RED BLUE GREEN. Once ' ...
           'you see the string, please discriminate the color using' ...
           'corresponding Left, Down and right Arrow keys (<-,V,->) as quickly as ' ...
           'possible.' ...
            '\n\n RED <--      Blue |         -->GREEN' ...
            '\n   v   '];   
    run_disp(windowPtr, msg); 
    WaitSecs(3);
    KbWait;

    % trial sequence
    for itrl = 1:num_trl
        if mod(itrl,30) == 0
            %block break;
            msg = ['That was block No. ' num2str(itrl/30) '. \nPlease take a break.' ...
                'When you are ready, press any key to continue.'];
            run_disp(windowPtr, msg); 
            
            KbWait;
        end
        cur_color = color_all{matrix(itrl,1)};
        cur_congr = matrix(itrl,2);        
        cur_str = matrix(itrl,3);
        WaitSecs(t_rand(itrl));
        
        Screen('TextSize',windowPtr,30);

        % display word
        Screen(windowPtr, 'FillRect');
        if cur_congr < 3
            DrawFormattedText(windowPtr, str_color{cur_str}, ...
                'center','center',cur_color);
        else
            DrawFormattedText(windowPtr, str_nocol{cur_str}, ...
                'center','center',cur_color);
        end
        t_sta(itrl) = Screen(windowPtr, 'Flip');        
        
        % get response
        [t_end(itrl) keycode] = KbWait;        
        keypressed = find(keycode == 1);
        if keypressed(1) == str_key(matrix(itrl,1))
            t_acc(itrl) = 1;
        else
            t_acc(itrl) = 0;
            if keypressed(1) == KbName('ESCAPE')
                break;
            end
        end
        Screen(windowPtr, 'FillRect');
        Screen(windowPtr, 'Flip');
    end    
    
    results = [matrix t_end-t_sta t_acc];
    %no statistical toolbox
%     results = dataset({result, 'color', 'congruency', 'word', 'rt', 'acc'});        
%     
%     % nomination    
%     results.color = nominal(results.color,...
%         {'red', 'blue', 'green'});
%     results.congruency = nominal(results.congruency, ...
%         {'congruent', 'incongruent', 'neutral'});    
    
    disp('stroop exp ends');
catch ME
    disp(ME.message);
end    
    
%% Simon Effect
function results = run_simon(expinfo)
try
    
    cx = expinfo.windowRect(3)/2;
    cy = expinfo.windowRect(4)/2;    
    offset = 2*cx/6;
    size_patch = [0 0 80 80];
    t_present = .05;
    str_key = [KbName('LeftArrow'), KbName('RightArrow')];
    
    % all possible location
    posi_all = zeros(4,3);    
    posi_all(:,1) = CenterRectOnPoint(size_patch, cx-offset, cy);
    posi_all(:,2) = CenterRectOnPoint(size_patch, cx+offset, cy);
    posi_all(:,3) = CenterRectOnPoint(size_patch, cx, cy);
    
    % all possible color
    color_all = {[255 0 0], [0 255 0]};
    
    % matrix: col1: color col2: position
    matrix = genTrials(20, [2 3]);     
    idx = matrix(:,2) == 3;
    matrix(idx,3) = 3;
    idx = matrix(:,2) ~= 3;
    matrix(idx,3) = (matrix(idx,1)~=matrix(idx,2))+1;
    % col3: spatial congruency 
    % 1:congruent 2:incongruenct 3:neutral  
    
    % pre allocation
    num_trl = size(matrix,1);    
    t_sta = zeros(num_trl,1);
    t_end = zeros(num_trl,1);
    t_acc = zeros(num_trl,1);
    t_rand = 1+rand(num_trl,1)/2;
    
    % disp instruction
    windowPtr = expinfo.windowPtr;
    msg =  ['In this experiment, you are going to make key press ' ...
        'response to the COLOR of the visual stimuli you see on the '...
        'screen. The visual stimuli will be a flash patch either in RED '...
        'GREEN. \n Please use your Left index finger for the Left arrow key ' ... 
        'and Right index finger for the Right arrow key',...
        'Left and right arrow keys correspond to RED and GREEN colors. ' ...
        'Please indicate the color as quickly as possible'...
        '\n\n RED <--            -->GREEN'];    
    run_disp(windowPtr, msg);
    WaitSecs(5);
    KbWait;
    
    for itrl = 1:num_trl
        if mod(itrl,30) == 0
            %block break;
            msg = ['That was block No. ' num2str(itrl/30) '. \nPlease take a break.' ...
                'When you are ready, press any key to continue.'];
            run_disp(windowPtr, msg); 
            
            KbWait;
            WaitSecs(2);
        end
        cur_color = color_all{matrix(itrl,1)};
        cur_posi = matrix(itrl,2);
        
        WaitSecs(t_rand(itrl));
        
        Screen(windowPtr,'FillRect');
        Screen(windowPtr,'FillRect', cur_color, posi_all(:,cur_posi));
        t_sta(itrl) = Screen(windowPtr,'Flip');
        Screen(windowPtr,'Flip', t_sta(itrl)+t_present);
        
        % get response
        [t_end(itrl) keycode] = KbWait;        
        keypressed = find(keycode == 1);
        if keypressed(1) == str_key(matrix(itrl,1))
            t_acc(itrl) = 1;
        else
            t_acc(itrl) = 0;
            if keypressed(1) == KbName('ESCAPE')
                break;
            end
        end
    end
        
    results = [matrix t_end-t_sta t_acc];
%     results = dataset({result, 'color', 'location', 'congruency', 'rt', 'acc'});
%     
%     results.color = nominal(results.color,...
%         {'red', 'green'});
%     results.congruency = nominal(results.congruency, ...
%         {'congruent', 'incongruent', 'neutral'});
%     results.location = nominal(results.location, ...
%         {'left', 'right', 'middle'});
    
    
catch ME
    disp(ME.message);
end
    
%% Demo modules: Visual Search
function results = run_search(expinfo)
    try

        msg =  ['In this experiment, you are going to search '...
            'for an pop-out target among various distracters.' ...
            'You have to tell if the such target exists on the '...
            'display by pressing either LEFT ARROW (PRESENT) or RIGHT ARROW (ABSENT) key.'];

        cx = expinfo.windowRect(3)/2;
        cy = expinfo.windowRect(4)/2;
        windowPtr = expinfo.windowPtr;

        str_key = [KbName('LeftArrow'), KbName('RightArrow')];
        setsize = [4 8 16];

        % generate stimuli
        bars = zeros(64,64,3);
        for i = 25:40
            bars(:,i,:) = 1;
        end

        matrix = genTrials(10,3,2,2);
        num_trl = size(matrix,1);    
        matrix(:,3) = mod(randperm(num_trl),2);

        % generate locations to use
        max_setsize = max(setsize);
        m_size = 5*5;
        locs = zeros(num_trl, m_size);
        for itrl = 1:num_trl
            locs(itrl,:) = randperm(m_size);
        end

        % generate locations
        loc_all = zeros(4,m_size);
        w_cell = cx/8;
        h_cell = cy/8;
        b_rect = [0 0 cy/25 cy/25];
        lx = cx +  w_cell *linspace(-2,2,sqrt(m_size));
        ly = cy + h_cell *linspace(-2,2,sqrt(m_size));    
        for i = 1:length(lx)
            for j = 1:length(ly)
                loc_all(:,(i-1)*sqrt(m_size)+j) = CenterRectOnPoint(b_rect, lx(i), ly(j));
            end
        end

        loc_jitter = zeros(4,max_setsize,num_trl);
        loc_jitter(1,:,:) = rand(max_setsize,num_trl)*cx/15;
        loc_jitter(2,:,:) = rand(max_setsize,num_trl)*cy/20;
        loc_jitter(3,:,:) = loc_jitter(1,:,:);
        loc_jitter(4,:,:) = loc_jitter(2,:,:);    

        % disp instruction
        run_disp(windowPtr, msg);

        bar_green = bars;
        bar_green(:,:,2) = bar_green(:,:,2)*255;
        bar_red = bars;
        bar_red(:,:,1) = bar_red(:,:,1)*255;

        tex_bar(1) = Screen(windowPtr,'MakeTexture',bar_red);
        tex_bar(2) = Screen(windowPtr,'MakeTexture',bar_green);

        % preallocation
        t_vonset = zeros(num_trl,1);
        t_end = t_vonset;
        t_resp = t_vonset;
        t_acc = t_vonset;
        t_rand = 1+rand(num_trl,1)/2;

        for itrl = 1:num_trl
            if mod(itrl,30) == 0
                %block break;
                msg = ['That was block No. ' num2str(itrl/30) '. \nPlease take a break.' ...
                    'When you are ready, press any key to continue.'];
                run_disp(windowPtr, msg); 

                KbWait;
            end

            
            WaitSecs(t_rand(itrl));

            % draw a fixation
            Screen('TextSize',windowPtr,40);
            Screen(windowPtr, 'FillRect',0);
            Screen(windowPtr, 'DrawText', '+', cx,cy,128);
            Screen(windowPtr, 'Flip');        
            WaitSecs(0.5+0.3*rand);
            % determine conditions
            cur_setsize = setsize(matrix(itrl,1));
            bar_rect_b = loc_all(:,locs(itrl,1:cur_setsize));
            bar_rect_j = loc_jitter(:,1:cur_setsize,itrl);
            bar_rect = bar_rect_b + bar_rect_j;

            t_ab = matrix(itrl,3); % 0 target absent 1 present
            cond = matrix(itrl,2); % 1 color 2 ori

            Screen(windowPtr, 'FillRect',0);
            if t_ab        
                for item = 1:cur_setsize-1
                    Screen(windowPtr, 'DrawTexture', tex_bar(2),...
                        [],bar_rect(:,item),30);
                end
                if cond == 1
                    Screen(windowPtr, 'DrawTexture', tex_bar(1),...
                        [],bar_rect(:,cur_setsize),30);
                else
                    Screen(windowPtr, 'DrawTexture', tex_bar(2),...
                        [],bar_rect(:,cur_setsize));
                end        
            else
                for item = 1:cur_setsize
                    Screen(windowPtr, 'DrawTexture', tex_bar(2),...
                        [],bar_rect(:,item),30);
                end
            end
            t_vonset(itrl) = Screen(windowPtr,'Flip');

            % get response
            [t_end(itrl) keycode] = KbWait;        
            keypressed = find(keycode == 1);
            if keypressed(1) == str_key(1)
%            if strcmp(KbName(keypressed(1)), str_key{1})
                t_resp(itrl) = 1;
            else
                t_resp(itrl) = 0;
            end
            if keypressed(1) == KbName('ESCAPE')
                break;
            end

            t_acc(itrl) = t_resp(itrl) == t_ab;

            if strcmp(KbName(keypressed(1)), 'Escape')
                break;
            end     

            while KbCheck; end
            Screen(windowPtr, 'Flip');        
        end    

        results = [matrix t_end-t_vonset t_resp t_acc];
%         results = dataset({result,'setsize', 'condition', ...
%             'target_presence', 'rt', 'response', 'acc'});
%         
%         % nomination
%         results.target_presence = nominal(results.target_presence,...
%             {'absent','present'});
%         results.response = nominal(results.response,...
%             {'absent','present'});
%         results.condition = nominal(results.condition,...
%             {'color','orientation'});
%         results.setsize = 2.^(results.setsize+1);
        
    catch ME
        disp(ME.message);
    end


%% Flash-lag Effect
function results = run_flash(expinfo)
try
     
    cx = expinfo.windowRect(3)/2;
    cy = expinfo.windowRect(4)/2;
    speed_mov = 1/expinfo.flipintv/15;
    
    size_bar = [0 0 2 40];
    size_prb = [0 0 2 40];
    size_step = 20;
    size_range = round(cx*2/3);
    
    str_key = [KbName('LeftArrow'), KbName('RightArrow')];
    color_all = {[255 255 255], [0 0 0]};
        
    matrix = genTrials(10, [7 2]);    
    num_trl = size(matrix,1);   
    p_sta = size_range + round(cx/8*rand(num_trl,1));
%    p_fla = cx + round(cx/4*(rand(num_trl,1)-.5));    
    p_fla = size_range/3 + round(cx/4*(rand(num_trl,1)-.5)); 
    t_resp = zeros(num_trl,1);
    t_rt = t_resp;
    t_rand = 1+rand(num_trl,1)/2;
    
    windowPtr = expinfo.windowPtr;
    msg = ['In this experiment, you are going to see two bars aligned ' ...
        'vertically, moving horizontally either from the left to right ' ...
        'or vice versa. During their movement, a third bar will flash '...
        'briefly in between the two moving bars and immediately ' ...
        'disappear. Your task is to judgment, when the flash bar ' ...
        'appears, whether it is to the left or to the right of the moving bars.' ...
        'Please use Left (<-) and Right (->) arrow keys correspondly.' ];
    run_disp(windowPtr, msg);
    KbWait;

    for itrl = 1:num_trl
        if mod(itrl,28) == 0
            %block break;
            msg = ['That was block No. ' num2str(itrl/28) '. \nPlease take a break.' ...
                'When you are ready, press any key to continue.'];
            run_disp(windowPtr, msg); 

            KbWait;
        end
        t_sta = GetSecs;
        WaitSecs(t_rand(itrl));
        
        % set initial parameters:
        bflag = 0;
%        cur_fp = p_fla(itrl);
        cur_direction = (matrix(itrl,2)-1.5)/.5;
        cur_offset = size_step * (matrix(itrl,1)-5)*cur_direction;
        
        if cur_direction == 1
            cur_sta = cx + p_sta(itrl);
            cur_step = -speed_mov;
            cur_fp = cx + p_fla(itrl);
            cur_end = cur_sta-size_range;
        else
            cur_sta = cx - p_sta(itrl);
            cur_step = speed_mov;
            cur_fp = cx - p_fla(itrl);
            cur_end = cur_sta+size_range;
        end
        
        Screen('TextSize',windowPtr,40);
        for p = cur_sta:cur_step:cur_end
            % draw a fixation
%            Screen(windowPtr, 'DrawText', '+', cx,cy,128);
            Screen(windowPtr,'FillOval',128,CenterRectOnPoint([0 0 5 5],cx,cy));
            cur_x = p;
            cur_p1 = CenterRectOnPoint(size_bar, cur_x, cy-70);
            cur_p2 = CenterRectOnPoint(size_bar, cur_x, cy+70);
            
            Screen(windowPtr,'FillRect',color_all{1}, cur_p1);
            Screen(windowPtr,'FillRect',color_all{1}, cur_p2);
            
            if ~bflag
                if cur_direction == 1 && cur_x <= cur_fp
                    cur_fr = CenterRectOnPoint(size_prb, ...
                        cur_x + cur_offset, cy);
                    Screen(windowPtr, 'FillRect', color_all{1}, cur_fr);
                    bflag = 1;
                elseif cur_direction ==-1 && cur_x >= cur_fp
                    cur_fr = CenterRectOnPoint(size_prb, ...
                    cur_x + cur_offset, cy);
                    Screen(windowPtr, 'FillRect', color_all{1}, cur_fr);
                    bflag = 1;
                end
            end
            Screen(windowPtr,'Flip');
        end
    
        % get response
        Screen(windowPtr,'FillRect');
        Screen(windowPtr,'Flip');
        
        [keytime keycode] = KbWait;
        keypressed = find(keycode == 1);
        if keypressed(1) == KbName('ESCAPE')
            break;
        else
            t_resp(itrl) = keypressed(1) == str_key(2);
        end
        t_rt(itrl) = keytime - t_sta;
        
    end    
    
    t_resp = t_resp+1;
    leadlag = t_resp == matrix(:,2);
    % if 1: moving bar leading
    % if 0: moving bar lagging
    
    results = [matrix(:,1)-4 t_rt leadlag];
%     results = dataset({result, 'offset', 'rt', 'response'});    
%     % response 1: lead
%     % response 0: lag
%     
%     % nomination
%     results.response = nominal(results.response,...
%         {'lag','lead'}); 
%     results.offset = nominal(results.offset,...
%         {'lag3', 'lag2', 'lag1', 'align', 'lead1', 'lead2', 'lead3'});
catch ME
    disp(ME.message);
end
%% Attentional Blink
function results = run_ablink(expinfo)
try
    
    cx = expinfo.windowRect(3)/2;
    cy = expinfo.windowRect(4)/2;
    
    matrix = genTrials(15, 7);    
    num_trl = size(matrix,1);
    color_all = {[200 200 200], [255 0 0]};

    str_letter = char(65:90); % AB...Z
    str_number = char(49:57); % 1, 2, ..9
    t_rand = 1+rand(num_trl,1)/2;

    num_item = 22;
    item_use = zeros(num_trl,num_item);
    for itrl = 1:num_trl
        str_tmp = randperm(26);
        item_use(itrl,:) = str_tmp(1:num_item);
    end    
    num_use = ceil(rand(num_trl,1)*9);

    num_pre = 6;
    pos_lag = matrix(:,1);
    pos_init = ceil(rand(num_trl,1)*4)+num_pre;
    pos_tar = pos_init + pos_lag;

    rect_fix = CenterRectOnPoint([0 0 10 10], cx, cy);
    
    str_all = cell(num_item+1, num_trl);
    color_idx = ones(num_item+1,num_trl);
    for itrl = 1:num_trl        
        for pre_item = 1: pos_tar(itrl)-1
            str_all{pre_item, itrl} = str_letter(item_use(itrl,pre_item));
        end
        str_all{pos_tar(itrl), itrl} = str_number(num_use(itrl));
        for post_item = pos_tar(itrl)+1: num_item+1
            str_all{post_item, itrl} = str_letter(item_use(itrl, post_item-1));
        end
        
        color_idx(pos_init(itrl),itrl) =2;

    end
    
    windowPtr = expinfo.windowPtr; 
    msg = ['In this experiment, a series of characters will be presented rapidly '...
        'on the center of the screen one after another in each trial. ' ...
        'In each series, there is one character presented in RED, while '...
        'others are all in WHITE. This character is called target 1. ' ...
        'Also, in each series, there is one and only one number, which '...
        'will always be presented after the RED character, and is called '...
        'target 2. Your taget is to identify target 1 and 2 in each series '...
        'after presentation. When the question appears, you should press correspondent '...
        'keys to indicate the two targets (One Letter and One Digit) you have just seen.'];    
    run_disp(windowPtr, msg);
    KbWait;
    
    resp_t1 = zeros(num_trl, 1);
    resp_t2 = resp_t1;
    rt = zeros(num_trl, 3);

    for itrl = 1:num_trl
        
        if mod(itrl,28) == 0
            %block break;
            msg = ['That was block No. ' num2str(itrl/28) '. \nPlease take a break.' ...
                'When you are ready, press any key to continue.'];
            run_disp(windowPtr, msg); 

            KbWait;
        end
        
        rt(itrl,1) = GetSecs;
        cur_t1 = str_all{pos_init(itrl),itrl};
        cur_t2 = str_all{pos_tar(itrl),itrl};
   
        WaitSecs(t_rand(itrl));
        Screen(windowPtr,'FillRect');
        Screen(windowPtr,'FillOval', color_all{1}, rect_fix);

        tfix = Screen(windowPtr, 'Flip');
        tblank = Screen(windowPtr, 'Flip', tfix+.18);

        Screen('TextSize',windowPtr,100);
        for item = 1: 23
            DrawFormattedText(windowPtr,str_all{item, itrl}, ...
                'center', 'center', color_all{color_idx(item,itrl)});
            titem = Screen(windowPtr,'Flip', tblank + 2*expinfo.flipintv);
            tblank = Screen(windowPtr,'Flip', titem + 4*expinfo.flipintv);        
        end
        
        Screen(windowPtr, 'Flip', tblank+1);
        DrawFormattedText(windowPtr, 'What is T1?',...
            'center','center',[200 200 200]);
        Screen(windowPtr, 'Flip');
        [keytime keycode] = KbWait;
        rt(itrl,2) = keytime;
        keypressed = find(keycode == 1);
        switch keypressed(1)
            case KbName('ESCAPE');
                resp_t1(itrl) = 0;
                break;
            case KbName(cur_t1);
                resp_t1(itrl) = 1;
            otherwise
                resp_t1(itrl) = 0;
        end
        while KbCheck; end;
        
        DrawFormattedText(windowPtr, 'What is T2?',...
            'center','center',[200 200 200]);
        Screen(windowPtr, 'Flip');        
        [keytime keycode] = KbWait;
        rt(itrl,3) = keytime;
        keypressed = find(keycode == 1);
        resp = KbName(keypressed(1));
        switch resp(1);
            case 'ESCAPE'
                resp_t2(itrl) = 0;
                break;
            case cur_t2
                resp_t2(itrl) = 1;                
            otherwise
                resp_t2(itrl) = 0;
        end
        while KbCheck; end;
        Screen(windowPtr, 'Flip');
    end
    
    results = [matrix resp_t1 resp_t2 pos_init pos_tar rt];
%    results = dataset({result,'lag','acct1','acct2','post1','post2', 'tsta', 'rtt1', 'rtt2'});
    
catch ME
    disp(ME.message);
end