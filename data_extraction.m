% 
% This method is used to extract data from images,
% and store them as variable to later save them as .mat files
% 

clear; clc; close all;
addpath(genpath('../'));

disp('start');

[X,Y,U] = extract('1966_reduced_crop2','1966_vt2',1);

[X,Y,~,~,~] = ppc(X,Y,2000);
s = size(U); n = floor(0.01*s(1));

U = U(1:n,:);

disp('finished');