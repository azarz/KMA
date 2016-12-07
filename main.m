clear;
clc;
close all; 
warning off;
addpath(genpath('../'));    % add sub-directory functions

%% - Create data
disp('Creating data');

options.kernelt = 'rbf';
N = 30;

load data/exp_89_3.mat
Y1=Y;
XT1 = X(1:2:end,:);
YT1 = Y(1:2:end,:);
Xtemp1 = X(2:2:end,:);
Ytemp1 = Y(2:2:end,:);
[X,Y,U,~,~] = ppc(Xtemp1,Ytemp1,N);
labeled{1,1}.X = X'; labeled{1,1}.Y = Y;
test{1,1}.X = XT1; test{1,1}.Y = YT1;
unlabeled{1,1}.X = U';

load data/exp_66_3.mat
Y2=Y;
XT2 = X(1:2:end,:);
YT2 = Y(1:2:end,:);
Xtemp2 = X(2:2:end,:);
Ytemp2 = Y(2:2:end,:);
[X,Y,U,~,~] = ppc(Xtemp2,Ytemp2,N);
labeled{1,2}.X = X'; labeled{1,2}.Y = Y;
test{1,2}.X = XT2; test{1,2}.Y = YT2;
unlabeled{1,2}.X = U';

%% - Find projections
disp('Finding projection');

[ALPHA,LAMBDA,options] = KMA(labeled,unlabeled,options);

%% - Project test data
disp('Projecting data');
[Phi,ncl] = KMAproject(labeled,unlabeled,test,ALPHA,options);

%% - Classify

PhitoF = []; PhiTtoF = []; YF = [];

for i = 1:options.numDomains
    eval(sprintf(' Phi%itoF = Phi{1,%i}.train; ',i,i));
    eval(sprintf(' Phi%iTtoF = Phi{1,%i}.test; ',i,i));
  
    eval(sprintf(' [temp1,temp2] = get_n_value(Phi%itoF,Ytemp%i,ncl*N); ',i,i));
    eval(sprintf(' PhitoF = [PhitoF,temp1'']; YF = [YF;temp2]; '));
    eval(sprintf(' PhiTtoF = [PhiTtoF,Phi%iTtoF]; ',i));
end

% - Classify using a classic classifier
% for i = 1:options.numDomains
%     eval(sprintf(' Ypred = classify(Phi%itoF(:,1:ncl*N)'',PhitoF'',YF); ',i));
%     eval(sprintf(' results{1,%i}.assess = assessment(Y%i(1:ncl*N,1),Ypred,\''class\''); ',i,i));
%     
%     eval(sprintf(' Ypred = classify(Phi%iTtoF(:,:)'',PhitoF'',YF); ',i));
%     eval(sprintf(' results{1,%i}.assess_T = assessment(YT%i,Ypred,\''class\''); ',i,i));
%     
%     eval(sprintf(' Ypred = classify(labeled{1,%i}.X'',labeled{1,%i}.X'',labeled{1,%i}.Y); ',i,i,i));
%     eval(sprintf(' results{1,%i}.train_error = assessment(labeled{1,%i}.Y,Ypred,\''class\''); ',i,i));
% end

% - Classify using a multi-dimensionnal svm classifier

% A new svm model is created for each domain, and the img is then
% classified using this model (both training and testing)
for i = 1:options.numDomains
    eval(sprintf(' mdl = fitcecoc(PhitoF(:,(%i-1)*N*ncl+1:N*ncl*%i)'',YF((%i-1)*N*ncl+1:N*ncl*%i,:)); ',i,i,i,i));
    eval(sprintf(' [resub_pred,~] = resubPredict(mdl); '));
    eval(sprintf(' results.img%i_mdl%i.resub_assess = assessment(YF((%i-1)*N*ncl+1:N*ncl*%i,:),resub_pred,\''class\''); ',i,i,i,i));
    
    eval(sprintf(' pred = predict(mdl,Phi%iTtoF''); ',i));
    eval(sprintf(' results.img%i_mdl%i.assess = assessment(test{1,%i}.Y,pred,\''class\''); ',i,i,i));
    
%     eval(sprintf(' results.img%i_mdl%i.resub_pred = resub_pred; results.img%i_mdl%i.pred = pred; ',i,i,i,i));
end

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