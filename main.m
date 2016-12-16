clear;
clc;
close all; 
warning off;
addpath(genpath('../'));    % add sub-directory

%% - Create data
disp('Creating data');

options.kernelt = 'rbf';

data{1,1}.name = 'data/exp_66_1000.mat'; data{1,1}.n = 55;
data{1,2}.name = 'data/exp_89_500.mat'; data{1,2}.n = 40;
n_data = size(data);

for i = 1:n_data(2)
    eval(sprintf(' load(data{1,i}.name); '));
    eval(sprintf(' test{1,i}.X = X(1:2:end,:); test{1,i}.Y = Y(1:2:end,:); '));
    
    eval(sprintf(' Xtemp%i = X(2:2:end,:); Ytemp%i = Y(2:2:end,:); ',i,i));
    eval(sprintf(' [X,Y,U,~,~] = ppc(Xtemp%i,Ytemp%i,data{1,i}.n); ',i,i));
    eval(sprintf(' labeled{1,i}.X = X''; labeled{1,i}.Y = Y; unlabeled{1,i}.X = U''; '));
end

% N = 10;
% load data/exp_89_500.mat
% test{1,1}.X = X(1:2:end,:); test{1,1}.Y = Y(1:2:end,:);
% Xtemp1 = X(2:2:end,:); Ytemp1 = Y(2:2:end,:);
% [X,Y,U,~,~] = ppc(Xtemp1,Ytemp1,N);
% labeled{1,1}.X = X'; labeled{1,1}.Y = Y;
% unlabeled{1,1}.X = U';


%% - Find projections
disp('Finding projection');

[ALPHA,LAMBDA,options] = KMA(labeled,unlabeled,options);

%% - Project test data
disp('Projecting data');
[Phi,ncl] = KMAproject(labeled,unlabeled,test,ALPHA,options);

%% - Classify

PhitoF = []; PhiTtoF = []; YF = [];

for i = 1:options.numDomains
    eval(sprintf(' Phi%itoF = Phi{1,i}.train; ',i));
    eval(sprintf(' Phi%iTtoF = Phi{1,i}.test; ',i));
    
    eval(sprintf(' N = ncl*data{1,i}.n; '));
    eval(sprintf(' max_size = size(Ytemp%i); ',i));
    if N > max_size(1)
        N = max_size(1);
    end
  
    eval(sprintf(' [temp1,temp2] = get_n_value(Phi%itoF,Ytemp%i,N); ',i,i));
    eval(sprintf(' PhitoF = [PhitoF,temp1'']; YF = [YF;temp2]; '));
    eval(sprintf(' PhiTtoF = [PhiTtoF,Phi%iTtoF]; ',i));
end

% - Classify using a multi-dimensionnal svm classifier

% A new svm model is created for each domain, and the img is then
% classified using this model (both training and testing)
% for i = 1:options.numDomains
%     eval(sprintf(' mdl = fitcecoc(PhitoF(:,(%i-1)*N*ncl+1:N*ncl*%i)'',YF((%i-1)*N*ncl+1:N*ncl*%i,:)); ',i,i,i,i));
%     eval(sprintf(' [resub_pred,~] = resubPredict(mdl); '));
%     eval(sprintf(' results.img%i_mdl%i.resub_assess = assessment(YF((%i-1)*N*ncl+1:N*ncl*%i,:),resub_pred,\''class\''); ',i,i,i,i));
%     
%     eval(sprintf(' pred = predict(mdl,Phi%iTtoF''); ',i));
%     eval(sprintf(' results.img%i_mdl%i.assess = assessment(test{1,%i}.Y,pred,\''class\''); ',i,i,i));
% end

% A general svm model is calculated, and all images are classififed using
% this model (both training and testing)
mdl = fitcecoc(PhitoF',YF); 
[resub_pred,~] = resubPredict(mdl);
results.all.resub_assess = assessment(YF,resub_pred,'class');

pred = predict(mdl,PhiTtoF');
results.all.assess = assessment([test{1,1}.Y;test{1,2}.Y],pred,'class');

results.all.resub_pred = resub_pred; results.all.pred = pred;
results.all.mdl = mdl;

%Each img is classified using the general svm model above
for i = 1:options.numDomains
    eval(sprintf(' pred = predict(mdl,Phi%iTtoF''); ',i));
    eval(sprintf(' results.img%i_all.assess = assessment(test{1,%i}.Y,pred,\''class\''); ',i,i));
    
%     eval(sprintf(' results.img%i_all.pred = pred; ',i,i));
end

disp('KMA finished');