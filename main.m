clear;
clc;
close all; 
warning off;
addpath(genpath('../'));    % add sub-directory functions

%% - Create data
disp('Creating data');

options.kernelt = 'rbf';
N = 20;

load data/test.mat
Y1=Y;
XT1 = X(1:2:end,:);
YT1 = Y(1:2:end,:);
Xtemp = X(2:2:end,:);
Ytemp = Y(2:2:end,:);
[X,Y,U,~,~] = ppc(Xtemp,Ytemp,N);
labeled{1,1}.X = X'; labeled{1,1}.Y = Y;
test{1,1}.X = XT1; test{1,1}.Y = YT1;
unlabeled{1,1}.X = U';

load data/test.mat
Y2=Y;
X = X +rand(size(X))*0.15;
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

for i = 1:options.numDomains
    eval(sprintf('Phi%itoF = Phi{1,%i}.train;',i,i));
    eval(sprintf('Phi%iTtoF = Phi{1,%i}.test;',i,i));
    
    eval(sprintf('r%i = []; rT%i = [];',i,i));
end
% Phi1toF = Phi{1,1}.train;
% Phi1TtoF = Phi{1,1}.test;
% Phi2toF = Phi{1,2}.train;
% Phi2TtoF = Phi{1,2}.test;

% r1 = []; r2 = [];
% rT1 = []; rT2 = [];

% classify - knnclassify - svmclassify

%fitcecoc
for NF = 1:options.nVect
    Ypred = classify(Phi1toF(1:NF,1:ncl*N)',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1(1:ncl*N,:);Y2(1:ncl*N,:)]);
    Reslatent1Kernel2 = assessment(Y1(1:ncl*N,1),Ypred,'class');
    
    Ypred = classify(Phi1TtoF(1:NF,:)',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1(1:ncl*N,:);Y2(1:ncl*N,:)]);
    Reslatent1Kernel2T = assessment(YT1,Ypred,'class');
    
    Ypred = classify(Phi2toF(1:NF,1:ncl*N)',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1(1:ncl*N,:);Y2(1:ncl*N,:)]);
    Reslatent2Kernel2 = assessment(Y2(1:ncl*N,1),Ypred,'class');
    
    Ypred = classify(Phi2TtoF(1:NF,:)',[Phi1toF(1:NF,1:ncl*N),Phi2toF(1:NF,1:ncl*N)]',[Y1(1:ncl*N,:);Y2(1:ncl*N,:)]);
    Reslatent2Kernel2T = assessment(YT2,Ypred,'class');
    
    r1 = [r1; Reslatent1Kernel2];
    rT1 = [rT1; Reslatent1Kernel2T];
    
    r2 = [r2; Reslatent2Kernel2];
    rT2 = [rT2; Reslatent2Kernel2T];
end

for i = 1:options.numDomains
    eval(sprintf('results.RBF{1,%i}.X = r%i;',i,i));
    eval(sprintf('results.RBF{1,%i}.XT = rT%i;',i,i));
end
% results.RBF{1,1}.X = r1;
% results.RBF{1,1}.XT = rT1;
% results.RBF{1,2}.X = r2;
% results.RBF{1,2}.XT = rT2;



%% - Plot

% figure(1)
% plot(1:options.nVect,1-rT1,'r-'),grid on
% 
% figure(2)
% plot(1:options.nVect,1-rT2,'r-'),grid on
% 
% figure(3),
% scatter(Phi1TtoF(1,:),Phi1TtoF(2,:),20,YT1,'f'), hold on, scatter(Phi2TtoF(1,:),Phi2TtoF(2,:),20,YT2),colormap(jet),hold off
% grid on
% axis([-2.5 2.5 -2.5 2.5])
%  
% figure(4),
% plot(Phi1TtoF(1,:),Phi1TtoF(2,:),'r.'), hold on, plot(Phi2TtoF(1,:),Phi2TtoF(2,:),'.'),colormap(jet),hold off
% grid on
% axis([-2.5 2.5 -2.5 2.5])
