clear;
clc;
close all;
addpath(genpath('../'));

disp('start');

[X,Y,U] = extract('1966_reduced_crop2','1966_vt2',1);

disp('finished');
