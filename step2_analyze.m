%% PART 2: Fast Analysis with 16 SEPARATE FIGURES
% This script applies detection thresholds to Alice and Bob's signals, 
% identifies coincidence events, and calculates the CHSH Bell parameter (S).

load('CHSH_Raw_Intensities.mat'); 

% --- Manual Thresholds & Timing Parameters ---
thresh_Alice = 63000;  
thresh_Bob   = 11700;  
window = 6;            
pulse_dead_time = 8;  

N_matrix = zeros(4, 4);

% 1. Coincidence Extraction
for i = 1:4
    for j = 1:4
        alice_signal = intensitiesData{i,j}.Alice;
        bob_signal = intensitiesData{i,j}.Bob;
        numFrames = length(alice_signal);
        
        events = zeros(2, numFrames);
        
        % Peak detection for Alice with warning suppression
        if max(alice_signal) > thresh_Alice
            warning('off', 'signal:findpeaks:largeMinPeakHeight');
            [~, locs] = findpeaks(alice_signal, 'MinPeakHeight', thresh_Alice, 'MinPeakDistance', pulse_dead_time);
            warning('on', 'signal:findpeaks:largeMinPeakHeight');
            if ~isempty(locs), events(1, locs) = 1; end
        end
        
        % Peak detection for Bob with warning suppression
        if max(bob_signal) > thresh_Bob
            warning('off', 'signal:findpeaks:largeMinPeakHeight');
            [~, locs] = findpeaks(bob_signal, 'MinPeakHeight', thresh_Bob, 'MinPeakDistance', pulse_dead_time);
            warning('on', 'signal:findpeaks:largeMinPeakHeight');
            if ~isempty(locs), events(2, locs) = 1; end
        end
        
        % Coincidence counting with timing window
        coincidences = 0;
        active_frames = find(sum(events, 1) > 0);
        last_counted_frame = -max(window, pulse_dead_time); 
        
        for f = active_frames
            if f < last_counted_frame + pulse_dead_time
                continue; 
            end
            win = max(1, f-window):min(numFrames, f+window);
            if any(events(1, win)) && any(events(2, win))
                coincidences = coincidences + 1;
                last_counted_frame = f; 
            end
        end
        N_matrix(i,j) = coincidences;
    end
end

% 2. Calculate CHSH Parameter S
calcE = @(n11, n22, n12, n21) (n11 + n22 - n12 - n21) / max(1, (n11 + n22 + n12 + n21));

E1 = calcE(N_matrix(2,2), N_matrix(4,4), N_matrix(2,4), N_matrix(4,2)); 
E2 = calcE(N_matrix(2,3), N_matrix(4,1), N_matrix(2,1), N_matrix(4,3)); 
E3 = calcE(N_matrix(3,2), N_matrix(1,4), N_matrix(3,4), N_matrix(1,2)); 
E4 = calcE(N_matrix(3,3), N_matrix(1,1), N_matrix(3,1), N_matrix(1,3)); 
S = E1 - E2 + E3 + E4;

% Results Output
fprintf('\n--- CHSH FINAL RESULTS ---\n');
fprintf('Threshold Alice: %.1f | Threshold Bob: %.1f\n', thresh_Alice, thresh_Bob);
disp('Coincidence Matrix (N):'); disp(N_matrix);
fprintf('Final Bell Parameter S = %.4f\n', S);

% 3. Visualization
alice_angles = {'-45°', '0°', '45°', '90°'};
bob_angles = {'-22.5°', '22.5°', '67.5°', '112.5°'};
signal_color = [0, 0.2, 0.6];

for i = 1:4
    for j = 1:4
        alice_sig = intensitiesData{i,j}.Alice;
        bob_sig = intensitiesData{i,j}.Bob;
        numF = length(alice_sig);
        
        % Detect peaks for visual plotting with suppression
        warning('off', 'signal:findpeaks:largeMinPeakHeight');
        [~, locsA] = findpeaks(alice_sig, 'MinPeakHeight', thresh_Alice, 'MinPeakDistance', pulse_dead_time);
        [~, locsB] = findpeaks(bob_sig, 'MinPeakHeight', thresh_Bob, 'MinPeakDistance', pulse_dead_time);
        warning('on', 'signal:findpeaks:largeMinPeakHeight');
        
        eventsA = ismember(1:numF, locsA); eventsB = ismember(1:numF, locsB);
        
        figure('Name', sprintf('Alpha=%s, Beta=%s', alice_angles{i}, bob_angles{j}), 'Color', 'w');
        sgtitle(sprintf('\\alpha=%s, \\beta=%s (N=%d)', alice_angles{i}, bob_angles{j}, N_matrix(i,j)));
        
        subplot(2, 1, 1); plot(alice_sig, 'Color', signal_color); hold on;
        yline(thresh_Alice, '--k');
        for ap = locsA
            win = max(1, ap-window):min(numF, ap+window);
            plot(ap, alice_sig(ap), 'o', 'MarkerFaceColor', iif(any(eventsB(win)),'g','r'));
        end
        title('Alice Channel'); axis tight;
        
        subplot(2, 1, 2); plot(bob_sig, 'Color', signal_color); hold on;
        yline(thresh_Bob, '--k');
        for bp = locsB
            win = max(1, bp-window):min(numF, bp+window);
            plot(bp, bob_sig(bp), 'o', 'MarkerFaceColor', iif(any(eventsA(win)),'g','r'));
        end
        title('Bob Channel'); axis tight;
    end
end

function out = iif(cond, t, f); if cond, out=t; else, out=f; end; end