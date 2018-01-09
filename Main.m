%% Main script
close all
clear all
clc

% Setup VLFeat library
run('vlfeat-0.9.20/toolbox/vl_setup');
%==========================================================================
% Set file path
Data_path = 'project1_test_final_updated/';
% Data_path = 'project1_files/images';
Image_separator = '_';
%==========================================================================
data_path=dir(Data_path);
file_num = length(data_path)-2;
img_info=cell(file_num,2); % {name, image index}
images=cell(file_num,1);

img_type_num = 1;
a_name = data_path(img_type_num+2).name;
img_info{img_type_num,1} = a_name(1:find(a_name==Image_separator)-1);
img_info{img_type_num,2} = 1;

for i = 2:file_num 
    a_name=data_path(i+2).name;
    a_name=a_name(1:find(a_name=='_')-1);
    type_ind = 0;
    for j = 1:img_type_num
        if strcmpi(a_name,img_info{j,1})
            type_ind = j;
        end
    end
    if type_ind > 0 % Existing type of image
        img_info{j,2} = [img_info{j,2}, i];
    elseif type_ind == 0 % New type of image is found
        img_type_num = img_type_num + 1;
        img_info{img_type_num,1} = a_name;
        img_info{img_type_num,2} = i;
    end
end
for j = 1:img_type_num
    fprintf('Image (Type %d): [%s] contains %d images\n',j,...
    img_info{j,1}, length(img_info{j,2}));
end
%==========================================================================
% Configuration
match_thresh = 2000;
slct_num = 40; % selected feature number
%==========================================================================
% for type_j = 1:img_type_num
for type_j = 3
%--------------------------------------------------------------------------
tic
num_of_img = length(img_info{type_j,2});
images = cell(num_of_img, 1);
for import_k = 1:num_of_img
    file_name=[Data_path, data_path(img_info{type_j,2}(import_k)+2).name];
    images{import_k} = imread(file_name);
end

pair_info = zeros(num_of_img-1,3); % '[i, j, score]'
for i = 1:num_of_img-1
    pair_score = zeros(num_of_img-i,1);
    for j = 1:num_of_img-i
        [~,~, scores] = featureExtraction( images{i}, images{i+j}, 0 );
        fprintf('Match score of image %d and %d: %.1f\n', i, i+j, scores);
        pair_score(j)= scores;
    end
    % Find the best match:
    [pair_info(i,3), score_ind] = min(pair_score);
    pair_info(i, 1:2) = [i, i+score_ind];
end
fprintf('Time to pair images = %.2f sec\n', toc);

for pair_ind = 1:num_of_img-1 % image pair index
    i = max(pair_info(pair_ind, 1:2));
    j = min(pair_info(pair_ind, 1:2));
    % Feature extraction
    [xy1, xy2,~] = featureExtraction(images{i}, images{j}, 1);            
    [ xy1_homo, xy2_homo ] = slctFeature( xy1, xy2, slct_num );
    plotFeature( images{i}, images{j}, xy1_homo, xy2_homo );
    
    % RANSAC
    tic
    seed_size = 5;
    thresh = 400;
    loop_num = 10;
    [ xy1_homo, xy2_homo, is_valid  ] = ransac( xy1_homo, xy2_homo,...
        seed_size, thresh, loop_num );
    if is_valid
fprintf('Time of RANSAC = %.2f sec\n - With %d feature points selected\n',...
        toc, size(xy1_homo, 2));
    
    H = estimateHomography( xy1_homo, xy2_homo);
    plotFeature( images{i}, images{j}, xy1_homo, xy2_homo );
    
    % Stitch images together
    tic;
    stitch_img = stitchImage( images{i}, images{j}, H, 1 );
    fprintf('Time to stitch image %d and %d = %.2f sec\n', i, j, toc);

    images{i} = stitch_img;
    images{j} = stitch_img;
    else
        fprintf('Failed to stitch image %d and %d\n', i, j);
    end
end


%Amend image
tic
amend_img = amend( stitch_img );
figure('Position', [1400,150,600,400])
imshow(amend_img)
title('Amended stitch image')
fprintf('Time to amend image = %.2f sec\n', toc);
end