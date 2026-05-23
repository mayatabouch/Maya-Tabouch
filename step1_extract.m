%% PART 1: Extract and Save Intensities (Run ONLY Once)
% This script opens the CHSH videos, extracts raw analog counts for Alice and Bob,
% performs baseline subtraction, and saves them to disk for later analysis.

% 1. Define Video Paths
% Enter the path to the folder containing your videos (e.g., 'C:\MyVideos\')
videoFolder = ''; 

% Using fullfile for safe cross-platform path building
fileNames = {
    fullfile(videoFolder, 'alpha-45beta-22.5.mp4'), fullfile(videoFolder, 'alpha-45beta22.5.mp4'), fullfile(videoFolder, 'alpha-45beta67.5.mp4'), fullfile(videoFolder, 'alpha-45beta112.5.mp4');
    fullfile(videoFolder, 'alpha0beta-22.5.mp4'),   fullfile(videoFolder, 'alpha0beta22.5.mp4'),   fullfile(videoFolder, 'alpha0beta67.5.mp4'),   fullfile(videoFolder, 'alpha0beta112.5.mp4');
    fullfile(videoFolder, 'alpha45beta-22.5.mp4'),  fullfile(videoFolder, 'alpha45beta22.5.mp4'),  fullfile(videoFolder, 'alpha45beta67.5.mp4'),  fullfile(videoFolder, 'alpha45beta112.5.mp4');
    fullfile(videoFolder, 'alpha90beta-22.5.mp4'),  fullfile(videoFolder, 'alpha90beta22.5.mp4'),  fullfile(videoFolder, 'alpha90beta67.5.mp4'),  fullfile(videoFolder, 'alpha90beta112.5.mp4')
};

% 2. ROI Definitions
% Note: Only the active ROIs are kept here for clarity. 
% Use the 'ROI Selection Tool' script if coordinates need to be updated.
all_rois = cell(4, 4);

% Video (1,1): Alice -45, Bob -22.5
all_rois{1,1}{1}.rows = 108:136; all_rois{1,1}{1}.cols = 674:709; % Alice H
all_rois{1,1}{2}.rows = 446:513; all_rois{1,1}{2}.cols = 682:752; % Bob H
% Video (1,2): Alice -45, Bob 22.5
all_rois{1,2}{1}.rows = 118:163; all_rois{1,2}{1}.cols = 647:716; 
all_rois{1,2}{2}.rows = 488:525; all_rois{1,2}{2}.cols = 685:726;
% Video (1,3): Alice -45, Bob 67.5
all_rois{1,3}{1}.rows = 110:136; all_rois{1,3}{1}.cols = 673:705; 
all_rois{1,3}{2}.rows = 458:479; all_rois{1,3}{2}.cols = 712:730; 
% Video (1,4): Alice -45, Bob 112.5
all_rois{1,4}{1}.rows = 110:133; all_rois{1,4}{1}.cols = 674:708; 
all_rois{1,4}{2}.rows = 487:518; all_rois{1,4}{2}.cols = 693:724;

% Video (2,1): Alice 0, Bob -22.5
all_rois{2,1}{1}.rows = 108:136; all_rois{2,1}{1}.cols = 674:709; 
all_rois{2,1}{2}.rows = 463:492; all_rois{2,1}{2}.cols = 714:729; 
% Video (2,2): Alice 0, Bob 22.5
all_rois{2,2}{1}.rows = 110:136; all_rois{2,2}{1}.cols = 657:686; 
all_rois{2,2}{2}.rows = 459:534; all_rois{2,2}{2}.cols = 690:758;
% Video (2,3): Alice 0, Bob 67.5
all_rois{2,3}{1}.rows = 104:136; all_rois{2,3}{1}.cols = 650:688; 
all_rois{2,3}{2}.rows = 459:534; all_rois{2,3}{2}.cols = 690:758;
% Video (2,4): Alice 0, Bob 112.5
all_rois{2,4}{1}.rows = 104:162; all_rois{2,4}{1}.cols = 650:716; 
all_rois{2,4}{2}.rows = 452:534; all_rois{2,4}{2}.cols = 690:758;

% Video (3,1): Alice 45, Bob -22.5
all_rois{3,1}{1}.rows = 104:136; all_rois{3,1}{1}.cols = 650:688; 
all_rois{3,1}{2}.rows = 465:492; all_rois{3,1}{2}.cols = 713:728; 
% Video (3,2): Alice 45, Bob 22.5
all_rois{3,2}{1}.rows = 104:136; all_rois{3,2}{1}.cols = 651:686; 
all_rois{3,2}{2}.rows = 458:533; all_rois{3,2}{2}.cols = 701:754;
% Video (3,3): Alice 45, Bob 67.5
all_rois{3,3}{1}.rows = 104:136; all_rois{3,3}{1}.cols = 650:688; 
all_rois{3,3}{2}.rows = 458:533; all_rois{3,3}{2}.cols = 701:754;
% Video (3,4): Alice 45, Bob 112.5
all_rois{3,4}{1}.rows = 104:136; all_rois{3,4}{1}.cols = 650:688; 
all_rois{3,4}{2}.rows = 458:533; all_rois{3,4}{2}.cols = 701:754;

% Video (4,1): Alice 90, Bob -22.5
all_rois{4,1}{1}.rows = 104:136; all_rois{4,1}{1}.cols = 650:688; 
all_rois{4,1}{2}.rows = 458:533; all_rois{4,1}{2}.cols = 701:754; 
% Video (4,2): Alice 90, Bob 22.5
all_rois{4,2}{1}.rows = 104:136; all_rois{4,2}{1}.cols = 650:688; 
all_rois{4,2}{2}.rows = 458:533; all_rois{4,2}{2}.cols = 701:754;
% Video (4,3): Alice 90, Bob 67.5
all_rois{4,3}{1}.rows = 104:136; all_rois{4,3}{1}.cols = 650:688; 
all_rois{4,3}{2}.rows = 458:533; all_rois{4,3}{2}.cols = 701:754;
% Video (4,4): Alice 90, Bob 112.5
all_rois{4,4}{1}.rows = 104:136; all_rois{4,4}{1}.cols = 650:688; 
all_rois{4,4}{2}.rows = 458:533; all_rois{4,4}{2}.cols = 701:754;


% 3. Extract and Process Intensities
intensitiesData = cell(4,4); % Preallocate for stability

for i = 1:4
    for j = 1:4
        fprintf('Extracting Video %d/16 (A:%d, B:%d)...\n', (i-1)*4 + j, i, j);
        v = VideoReader(fileNames{i,j});
        
        numFrames = v.NumFrames;
        if numFrames == 0, numFrames = floor(v.Duration * v.FrameRate); end
        
        rawData = zeros(2, numFrames);
        frameCount = 0;
        
        while hasFrame(v) && frameCount < numFrames
            frameCount = frameCount + 1;
            frame = readFrame(v);
            grayFrame = double(frame(:,:,1)); % Converted to double to prevent uint8 overflow during sum
            
            roiA = grayFrame(all_rois{i,j}{1}.rows, all_rois{i,j}{1}.cols);
            roiB = grayFrame(all_rois{i,j}{2}.rows, all_rois{i,j}{2}.cols);
            
            rawData(1, frameCount) = sum(roiA(:));
            rawData(2, frameCount) = sum(roiB(:));
        end
        
        % Baseline Subtraction (Subtracting minimum). 
        % Using 1:frameCount to prevent trailing zeros if video ended early.
        intensitiesData{i,j}.Alice = rawData(1, 1:frameCount) - min(rawData(1, 1:frameCount));
        intensitiesData{i,j}.Bob   = rawData(2, 1:frameCount) - min(rawData(2, 1:frameCount));
    end
end

% Save results to workspace directory
save('CHSH_Raw_Intensities.mat', 'intensitiesData');
fprintf('Done! All data saved to CHSH_Raw_Intensities.mat\n');