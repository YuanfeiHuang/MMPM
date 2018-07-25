function [s]=cal_psnr(A,B)

e=A-B;
e = e(:);
me=mean(mean(e.^2));
RMSE = sqrt(me);  % Root Mean Squared Error
s=20*log10(255/RMSE);

return;