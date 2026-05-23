clear all
close all % סוגר חלונות קודמים כדי להתחיל נקי

filename = 'Simulation_angle_bar_data_base_HVVH_bit_num_50';
base = filename(32:35);
bit_num = filename(45:46);
title_figure = strcat('Simulation', {' '}, base, {' '}, bit_num, ' bits');

% --- הגדרת המטריצה המבוקשת ישירות בקוד ---
data = [0.000,  0.000,  0.000,  0.000;
        0.000,  0.579,  0.494,  0.000;
        0.000,  0.494,  0.421,  0.000;
        0.000,  0.000,  0.000,  0.000];

% אם בכל זאת תרצה בעתיד לקרוא מהקובץ, פשוט תוריד את ה-% מהשורה הבאה:
% data = readmatrix(strcat(filename,'.csv'));

Li = ["HH","HV","VH","VV"];
Ls = ["HH","HV","VH","VV"];

fig = figure;
G2_plot = bar3(data(1:4,1:4));

% צביעת העמודות לפי הגובה שלהן (אפקט ויזואלי יפה)
for k = 1:length(G2_plot)
    zdata = G2_plot(k).ZData;
    G2_plot(k).CData = zdata;
    G2_plot(k).FaceColor = 'interp';
end

titles_size = 25;
set(gca, 'FontWeight', 'bold')
set(gca, 'FontName', 'Times New Roman')
set(gca, 'FontSize', 15)

% הגדרת תוויות הצירים
set(gca, 'XTickLabel', Li);
set(gca, 'YTickLabel', Ls);

title(title_figure, 'FontName', 'Times New Roman', 'FontSize', titles_size);
colormap default;
               
% התאמת ציר ה-Z לערכים של המטריצה שלך (מקסימום 0.618)
zlim([0 0.7]); % נותן קצת מרווח מעל העמודה הגבוהה ביותר
zticks([0, 0.2, 0.4, 0.6]);

% שמירת הגרף
savefig(filename);
disp('--- Reconstructed Density Matrix at N = 50 ---');
disp(data);
disp('--------------------------------------------');