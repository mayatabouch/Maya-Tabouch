%% Pulse Detection Calibration: ROI Selection Tool
% Use this script to manually define the detection area for each detector.
% Coordinates extracted here should be copied into the main tomography script.

% 1. Initialize Video Reader
% enter video path
videoPath = '';
v = VideoReader(videoPath);

% 2. Read a specific frame containing a visible pulse
% Change the frame number (e.g., 1327) to one where the laser is clearly visible
frame_number = 1327; 
img = read(v, frame_number);

% 3. Display frame and initialize interactive selection
fig = figure('Name', 'ROI Selection Tool');
imshow(img);
title('Draw a rectangle around the laser pulse and double-click inside');

% 4. Interactive ROI selection
% Draw the rectangle, resize/move as needed, then double-click to confirm.
h = drawrectangle('Label', 'Target Pulse', 'Color', 'r');

% 5. Wait for user confirmation (double-click)
wait(h); 

% 6. Extract coordinates and format for main script
% Position format: [x_min, y_min, width, height]
position = h.Position; 
x_min = round(position(1));
y_min = round(position(2));
width = round(position(3));
height = round(position(4));

x_max = x_min + width;
y_max = y_min + height;

% Output formatted coordinates to Command Window
fprintf('\n--- ROI Coordinates Extracted ---\n');
fprintf('Copy the following line directly into your main script:\n\n');
fprintf('rois{d}.rows = %d:%d; rois{d}.cols = %d:%d; %% Replace "d" with the correct detector number (1-4)\n', y_min, y_max, x_min, x_max);
fprintf('\n---------------------------------\n');

% Cleanup
close(fig);