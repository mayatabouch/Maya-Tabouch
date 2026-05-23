%% Quantum State Tomography: Density Matrix Reconstruction
% Based on emulated quantum states using a pulsed laser system.
% Detectors mapping: 1:HA, 2:VA, 3:HB, 4:VB

% 1. Setup and Video Initialization
%enter video path
videoPath = '';
v = VideoReader(videoPath);
v.CurrentTime = 0; 

% ROI definitions for Alice (A) and Bob (B) detectors - change to match the
% videos
rois{1}.rows = 474:496; rois{1}.cols = 385:408; % HA 
rois{2}.rows = 133:162; rois{2}.cols = 352:383; % VA
rois{3}.rows = 525:559; rois{3}.cols = 673:713; % HB
rois{4}.rows = 193:234; rois{4}.cols = 673:724; % VB

intensities = []; 
frameCount = 0;

% 2. Intensity Extraction
while hasFrame(v)
    frameCount = frameCount + 1;
    frame = readFrame(v);
    grayFrame = frame(:,:,1); % Using single channel for processing speed
    
    for d = 1:4
        roiData = grayFrame(rois{d}.rows, rois{d}.cols);
        intensities(d, frameCount) = sum(roiData(:));
    end
    
    if mod(frameCount, 200) == 0
        fprintf('Processing frame %d...\n', frameCount);
    end
end

% 3. Peak Detection and Bit Event Mapping
bit_events = zeros(4, frameCount); 
figure('Name', 'Signal Detection Verification');
for d = 1:4
    % Dynamic thresholding at 60% of peak intensity
    thresh = max(intensities(d,:))*0.6;
    
    % Find unique peaks to prevent double-counting a single pulse
    [pks, locs] = findpeaks(intensities(d,:), 'MinPeakHeight', thresh, 'MinPeakDistance', 3);
    bit_events(d, locs) = 1;
    
    subplot(4,1,d);
    plot(intensities(d,:)); hold on;
    if ~isempty(locs)
        plot(locs, pks, 'ro', 'MarkerSize', 4);
    end
    yline(thresh, '--k', 'Threshold');
    title(['Detector ', num2str(d), ' - Pulse Detection']);
    ylabel('Intensity [AU]');
end
xlabel('Frame Number');

% 4. Coincidence Analysis (Event-by-Event)
window = 4; % Coincidence window in frames
[rows, cols] = size(bit_events);
all_event_frames = find(sum(bit_events, 1) > 0);

% Identify unique quantum events within the timing window
unique_events = [];
if ~isempty(all_event_frames)
    unique_events = all_event_frames(1);
    for i = 2:length(all_event_frames)
        if all_event_frames(i) > unique_events(end) + window
            unique_events(end+1) = all_event_frames(i);
        end
    end
end

% Count simultaneous detections for Alice and Bob
counts = zeros(1, 4); % Basis: HH, HV, VH, VV
for f = unique_events
    win_range = max(1, f-window):min(cols, f+window);
    
    alice_H = any(bit_events(1, win_range));
    alice_V = any(bit_events(2, win_range));
    bob_H   = any(bit_events(3, win_range));
    bob_V   = any(bit_events(4, win_range));
    
    if alice_H && bob_H, counts(1) = counts(1) + 1; end
    if alice_H && bob_V, counts(2) = counts(2) + 1; end
    if alice_V && bob_H, counts(3) = counts(3) + 1; end
    if alice_V && bob_V, counts(4) = counts(4) + 1; end
end

% 5. Wavefunction and Density Matrix Reconstruction
N_total_events = sum(counts);

% Construct Wavefunction |Psi> assuming zero phase-locking (as per paper)
amplitudes = sqrt(counts / N_total_events);
psi = amplitudes'; 

% Calculate Density Matrix rho = |Psi><Psi|
rho = psi * psi'; 

% Output Results
labels = {'HH', 'HV', 'VH', 'VV'};
fprintf('\n--- Simultaneous Event Analysis ---\n');
fprintf('Total unique events identified: %d\n', N_total_events);
for i = 1:4
    fprintf('%s: %d events (Amplitude: %.3f)\n', labels{i}, counts(i), amplitudes(i));
end

%% 6. Visualization (Formatted according to Lab C standards)
labels_list = ["HH","HV","VH","VV"]; % Standard order for labeling

fig = figure('Name', 'Density Matrix Visualization');
G2_plot = bar3(rho); % Plotting the calculated density matrix

% Apply the interpolated color gradient based on height
for k = 1:length(G2_plot)
    zdata = G2_plot(k).ZData;
    G2_plot(k).CData = zdata;
    G2_plot(k).FaceColor = 'interp';
end

% Formatting according to the provided style
titles_size = 25;
set(gca, 'FontWeight', 'bold')
set(gca, 'FontName', 'Times New Roman')
set(gca, 'Fontsize', 15)

% Setting the axis labels
set(gca, 'XTickLabel', labels_list);
set(gca, 'YTickLabel', labels_list);

% Setting the title - change to match number of bits.
title_text = sprintf('HVVH 50 BIT');
title(title_text, 'FontName', 'Times New Roman', 'FontSize', titles_size);

% Adjusting the Z-axis ticks for better readability
z_max = max(rho(:));
set(gca, 'ZTick', round(linspace(0, z_max, 4), 2));

colormap default;

%% 7. Detailed Numerical Output - change to match number of bits.
fprintf('HHVV 50 BIT');
for i = 1:4
    for j = 1:4
        fprintf('rho(%s, %s) = %.4f\n', labels_list(i), labels_list(j), rho(i,j));
    end
end