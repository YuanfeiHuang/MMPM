% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function [features] = extract(conf, X, scale, filters)
% Turn the image into the features with defined scale and filter
% input:
%   configuration file: conf
%   input image: X
%   defined factor to scale up: scale
%   defined filter to use for convolution: filters
% output:
%   the features of the given image

% Compute one grid for all filters
% grid = sampling_grid(size(X), conf.window, conf.overlap, [0 0], scale);
grid = sampling_grid(size(X), conf.window, conf.overlap, conf.border, scale);
feature_size = prod(conf.window) * numel(filters);

% Current image features extraction [feature x index]
if isempty(filters)     % usually for high resolution image features extraction
    f = X(grid);
    features = reshape(f, [size(f, 1) * size(f, 2) size(f, 3)]);
else                    % usually for low resolution image features extraction
    features = zeros([feature_size size(grid, 3)], 'single');
    for i = 1:numel(filters)
        f = conv2(X, filters{i}, 'same');
        f = f(grid);
        f = reshape(f, [size(f, 1) * size(f, 2) size(f, 3)]);
        features((1:size(f, 1)) + (i-1)*size(f, 1), :) = f;
    end
end