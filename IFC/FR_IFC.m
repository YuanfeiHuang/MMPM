function im_quality = FR_IFC( im_reference, im_distorted )
%FR_VIF Summary of this function goes here
%   Detailed explanation goes here
p = size(im_reference, 3);
if p == 3
    im_reference = rgb2gray(im_reference);
    im_distorted = rgb2gray(im_distorted);
end
im_reference = double(im_reference);
im_distorted = double(im_distorted);

im_quality = ifcvec(im_reference,im_distorted);
