function im_loc = loc_show(im, bbox, color, locate)

%% 图像局部放大并显示矩形框
% Zebin Chen
% ZB302 ZHBIT
% March 20，2017
%

%% 在图像中局部显示矩形框
% X    = 120; %矩形框左上角的横坐标   
% Y    = 60; %矩形框左上角的纵坐标
% dX   = 30;    
% dY   = 30;  
% bbox = [X, Y, dX, dY];
im_1 = insertShape(im, 'Rectangle', bbox, 'LineWidth', 2, ...
    'Color', color);

%% 裁剪和局部并插值放大
scale     = 4;
im_crop   = imcrop(im, bbox); 
im_crop_b = imresize(im_crop, scale, 'bicubic'); 

%% 局部显示
[row_1, col_1, ~]                         = size(im);
[row_2, col_2, ~]                         = size(im_crop_b);
im_loc                                  = im_1;
if locate == 'l'
    im_loc(row_1-row_2+1:row_1, 1:col_2, :) = im_crop_b;
    bbox  = [1,row_1-row_2+1,col_2,row_2];
elseif locate == 'r'
    im_loc(row_1-row_2+1:row_1, col_1-col_2+1:col_1, :) = im_crop_b;
    bbox  = [col_1-col_2+1,row_1-row_2+1,col_2,row_2];
end
im_loc  = insertShape(im_loc, 'Rectangle', bbox, 'LineWidth', 2, ...
    'Color', color);







