function TactileExps(name_of_demo)
% 
% Usage:
%   [results ] = TactileExps([name_of_demo]);
%
% Available modules are now:
% 'freqency'      :   Frequency discrimination
% 'duration'       :  filled vs unfilled Duration experiment
% v. 0.2 06.12.2016 remove psychPortAudio, using Snd for compatibility
% issue
% add signal detection task: frequency variation detection

try% Determine what experiment to run
    switch nargin 
        case 0
            name_of_demo = 'detection';
            parameters = [];
        case 1
            parameters = [];
    end
    
    if isempty(parameters)
    end
    
    % Get Device and Subject information
    subname = input('Name (Abbr.): ','s');
    filename = [name_of_demo,'_', subname];
%    expinfo = run_getinfo(name_of_demo);    
    KbName('UnifyKeyNames');

    InitializePsychSound;
    
    WaitSecs(0.5);
    switch name_of_demo
        case 'frequency'
            results = run_freq;            
        case 'duration'
            results = run_dur;
        case 'detection'
            results = run_detection;
        otherwise
            results = run_detection;
    end
    
    % Save data;
    csvwrite([filename,'.csv'], results);
    %save(filename, 'results');
    disp(' ');
    disp(['Data saved : ' filename]);
    ShowCursor;
    % Ending experiment
    msg = 'Experiment ends! Thank you!';
    disp(msg);
    WaitSecs(3);
        
catch ME
    disp(ME.message);
end

function results = run_dur
% duration bisection: high vs. low intensity
try

    reverseStr = '';
    matrix = genTrials(10, [2 7]); % 7 levels
    matrix(:,2) = 0.3 + (matrix(:,2)-1)*0.1; % 0.3 - 0.9
    str_key = [KbName('LeftArrow'),  KbName('RightArrow')];

    numtrials = length(matrix);

    % disp instruction
    msg = sprintf(['------------ Duration Comparison ------------------\n',...
        '\n\n         Instruction       \n\n',...
        'Please attach the tactor to your index finger.\n ' ...
           'On each trial you will receive a vibration. \n' ...
           'you task is to judge the duration of the vibration is short or long.\n' ...
           'If you think the duration is SHORT,  ' ...
           'Please press Left key. \nOtherwise, please press the Right key.\n' ...
           ' Short (<-)     (->) Long \n',...
           '\nPress any key to continue...\n',...
           '------------------------------\n']);   
    disp(msg);
    KbWait(-1);

    for itrl=1:numtrials

       msg = sprintf('Trial: %d  [of %d]', itrl, length(matrix)); 
       fprintf([reverseStr, msg]);
       reverseStr = repmat(sprintf('\b'), 1, length(msg));

        % duration
        base_freq = 150; % Base frequency
        intensity = 6;
        high_low = matrix(itrl,1); 
        dur = matrix(itrl,2);
		vib = MakeBeep(base_freq, dur, 96000)*intensity;
        if high_low == 1 % low
            vib = vib/3; % half amplitude, -9.5 db
        end
        vibro = repmat(vib,2,1);

        %PsychPortAudio('FillBuffer', pHandle, vibro);
        %PsychPortAudio('Start', pHandle, 1, 0, 0);
        Snd('Play',vibro,96000);
        WaitSecs(dur); % possible duration
        
        Snd('Close');
        %PsychPortAudio('Stop', pHandle);
        
        t_onset = GetSecs;

        % get response
        [t_offset keycode] = KbWait(-1);        
        matrix(itrl,3) = t_offset - t_onset;
        keypressed = find(keycode == 1);
        if keypressed(1) == str_key(1) 
            % response lower
            matrix(itrl,4) = 0;
        else
            matrix(itrl,4) = 1;
            if keypressed(1) == KbName('ESCAPE')
                break;
            end
        end

        WaitSecs(1);

    end
     results = matrix;
     %    results = dataset({matrix,'levels', 'duration', ...
    %         'reaction time', 'response'});
    %PsychPortAudio('Close', pHandle);
catch ME
    disp(ME.message);
end 


function results = run_detection
% detect frequency variation
try
    %pHandle = PsychPortAudio('Open', [],[],2,96000,2);

    reverseStr = '';
    matrix = genTrials(30, 3); % # levels of variations
    str_key = [KbName('LeftArrow'),  KbName('RightArrow')];

    numtrials = length(matrix);

    % disp instruction
    msg = sprintf(['------------ Frequency change detection ------------------\n',...
        '\n\n         Instruction       \n\n',...
        'Please attach the tactor to your index finger.\n ' ...
           'On each trial you will receive a vibration. \n' ...
           'you task is to judge if the viration frequency is constant or not.\n' ...
           'If you think the frequency is CONSTANT,  ' ...
           'Please press Left key. \nOtherwise, please press the Right key.\n' ...
           ' Constant (<-)     (->) Change \n',...
           '\nPress any key to continue...\n',...
           '------------------------------\n']);   
    disp(msg);
    KbWait(-1);

    for itrl=1:numtrials

       msg = sprintf('Trial: %d  [of %d]', itrl, length(matrix)); 
       fprintf([reverseStr, msg]);
       reverseStr = repmat(sprintf('\b'), 1, length(msg));

        % duration
        base_freq = 100; % Base frequency
        intensity = 3;
        cond = matrix(itrl,1);
		vib = MakeBeep(base_freq, 0.2, 96000)*intensity;
        var_freq = base_freq * (1 + (cond-1)*0.05);
        vib_var = MakeBeep(var_freq, 0.2, 96000)*intensity;
        matrix(itrl, 2) = var_freq;
        vib3 = [vib, vib_var, vib];
        envelope = sin(2*pi*[1:length(vib3)]/9600/2)/5+0.8; 
        % envelope 0.8-1 with 5 Hz.  
        %vib3 = vib3 .*envelope;
        vibro = repmat(vib3,2,1);
        

        %PsychPortAudio('FillBuffer', pHandle, vibro);
        %PsychPortAudio('Start', pHandle, 1, 0, 0);
        Snd('Play',vibro,96000);
        WaitSecs(0.3); % possible duration
        
        Snd('Close');
        %PsychPortAudio('Stop', pHandle);
        
        t_onset = GetSecs;

        % get response
        [t_offset keycode] = KbWait(-1);        
        matrix(itrl,3) = t_offset - t_onset;
        keypressed = find(keycode == 1);
        if keypressed(1) == str_key(1) 
            % response lower
            matrix(itrl,4) = 0;
        else
            matrix(itrl,4) = 1;
            if keypressed(1) == KbName('ESCAPE')
                break;
            end
        end

        WaitSecs(1);

    end
     results = matrix;
catch ME
    disp(ME.message);
end 

function results = run_freq
% tactile frequency discimination experiment
try
    reverseStr = '';
 
    matrix = genTrials(6, [2 5 2]); % 2 freqs, 5 levels, 2 intensity
    numtrials = length(matrix);
    % conver to frequencies
    freqs = [70 130];
    
    str_key = [KbName('LeftArrow'),  KbName('RightArrow')];

    %pHandle = PsychPortAudio('Open', [],[],2,96000,2);

    % disp instruction
    msg = sprintf(['------------ Duration Comparison ------------------\n',...
        '\n\n         Instruction       \n\n',...
        'Please attach the tactor to your index finger. \n' ...
           'On each trial, you will receive vibrations twice. Your task is \n ' ...
           'to discriminate which one has higher frequency.\n' ...
           'Please note that the intensity will be varied across different trials, \nindependent from the frequency. \n' ...
           'If you think the first one has higher frequency than the second one,\n ' ...
           'Please press Left arrow key. Otherwise, please press the Right arrow key.\n\n' ,...
           'First higher (<-)   Second higher (->)',...
           '\nPress any key to continue...\n',...
           '------------------------------\n']);   
    disp(msg); 
    WaitSecs(1);
    KbWait(-1);

    for itrl=1:numtrials
        WaitSecs(0.5);
        msg = sprintf('Trial: %d  [of %d]', itrl, length(matrix)); 
       fprintf([reverseStr, msg]);
       reverseStr = repmat(sprintf('\b'), 1, length(msg));
        %1.present base frequency for 200 ms
        intensity = 5;
        base_freq = freqs(matrix(itrl,1)); 
        comp_freq = base_freq + base_freq * 0.2 * (matrix(itrl,2)-3); % one step 20% 
        
        base_t = MakeBeep(base_freq, 0.3, 96000)*intensity;
        comp_t = MakeBeep(comp_freq, 0.3, 96000)*intensity;
        
        % randomize intensity of the comparison stimuli
        comp_t = comp_t./matrix(itrl,3); % half the amplitude in half trials 
        
        vibro = [zeros(1,9600), base_t, zeros(1, round(24000 + 48000*rand)), comp_t];
        vibro = repmat(vibro,2,1);
        %PsychPortAudio('FillBuffer', pHandle, vibro);
        %PsychPortAudio('Start', pHandle, 1, 0, 0);
        Snd('Play',vibro,96000);

        WaitSecs(length(vibro)/96000); % possible duration
        %PsychPortAudio('Stop', pHandle);
        Snd('Close');
        t_onset = GetSecs;

        % get response
        [t_offset keycode] = KbWait(-1);        
        matrix(itrl,3) = t_offset - t_onset;
        keypressed = find(keycode == 1);
        if keypressed(1) == str_key(1) 
            % response lower
            matrix(itrl,4) = 0;
        else
            matrix(itrl,4) = 1;
            if keypressed(1) == KbName('ESCAPE')
                break;
            end
        end
        
        WaitSecs(1);

    end
    results = matrix;
%    results = dataset({matrix,'levels', 'frequency', ...
%         'reaction time', 'response'});
    
    % Close the audio device:
    %PsychPortAudio('Close', pHandle);

catch ME
    disp(ME.message);
end    





