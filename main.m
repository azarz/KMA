clear;
clc;
close all; 
warning off;
addpath(genpath('../'));    % add sub-directory functions

%% - Create data
disp('Creating data');

options.kernelt = 'rbf';
N = 30;

load data/test_66.mat
Y1=Y;
XT1 = X(1:2:end,:);
YT1 = Y(1:2:end,:);
Xtemp = X(2:2:end,:);
Ytemp = Y(2:2:end,:);
[X,Y,U,~,~] = ppc(Xtemp,Ytemp,N);
labeled{1,1}.X = X'; labeled{1,1}.Y = Y;
test{1,1}.X = XT1; test{1,1}.Y = YT1;
unlabeled{1,1}.X = U';

load data/test_89.mat
Y2=Y;
X = X +rand(size(X))*0.2;
XT2 = X(1:2:end,:);
YT2 = Y(1:2:end,:);
Xtemp = X(2:2:end,:);
Ytemp = Y(2:2:end,:);
[X,Y,U,~,~] = ppc(Xtemp,Ytemp,N);
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

PhitoF = []; YF = [];

for i = 1:options.numDomains
    eval(sprintf(' Phi%itoF = Phi{1,%i}.train; ',i,i));
    eval(sprintf(' Phi%iTtoF = Phi{1,%i}.test; ',i,i));
    
    
    eval(sprintf(' [temp1,temp2] = get_n_value(Phi%itoF,Y%i,ncl*N); ',i,i));
    eval(sprintf(' PhitoF = [PhitoF,temp1]; YF = [YF;temp2]; '));
    
%     eval(sprintf(' PhitoF = [PhitoF,Phi%itoF(:,1:ncl*N))]; ',i));
%     eval(sprintf(' YF = [YF;Y%i(1:ncl*N,:)]; ',i));     % YF = [YF;Y%i(1:ncl*N,:)];
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
% for i = 1:options.numDomains
%     eval(sprintf(' mdl = fitcecoc(Phi%itoF(:,1:ncl*N)'',Y%i(1:ncl*N,:)); ',i,i));
%     eval(sprintf(' [pred,score] = resubPredict(mdl); '));
%     eval(sprintf(' results{2,%i}.pred = pred; results{2,%i}.score = score; results{2,%i}.mdl = mdl; ',i,i,i));
%     eval(sprintf(' results{2,%i}.assess = assessment(labeled{1,%i}.Y,pred,\''class\''); ',i,i));
% end

mdl = fitcecoc(PhitoF',YF);
[pred,score] = resubPredict(mdl);
results{3,1}.pred = pred; results{3,1}.score = score; results{3,1}.mdl = mdl;
results{3,1}.assess = assessment(YF,pred,'class');

disp('KMA finished');
