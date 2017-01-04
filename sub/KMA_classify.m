function [results] = KMA_classify(data,labeled,test,anonym,Phi,ncl,options)
% Classify the result of a KEMA projection, using a multi-dimensionnal svm classifier
% 
% Inputs:
%
% - data : used to get data{1,i}.n
% - labeled: the list of labeled data
% - test : the structure of data kept aside for testing
% - Phi : the KEMA projection
% - ncl : number of class
% - options : used to get options.numDomains

PhitoF = []; PhiTtoF = []; YF = [];
X = []; Y = [];

for i = 1:options.numDomains
    eval(sprintf(' Phi%itoF = Phi{1,i}.train; ',i));
    eval(sprintf(' Phi%iTtoF = Phi{1,i}.test; ',i));

    eval(sprintf(' N = ncl*data{1,i}.n; '));
    eval(sprintf(' max_size = size(labeled{1,i}.Y_all); '));
    if N > max_size(1)
        N = max_size(1);
    end

    eval(sprintf(' [temp1,temp2] = get_n_value(Phi%itoF,labeled{1,i}.Y_all,N); ',i));
    eval(sprintf(' PhitoF = [PhitoF,temp1'']; YF = [YF;temp2]; '));
    eval(sprintf(' PhiTtoF = [PhiTtoF,Phi%iTtoF]; ',i));
    
    eval(sprintf(' X = [X,labeled{1,i}.X]; Y = [Y;labeled{1,i}.Y]; '));
end

%% A new svm model is created for each domain,
%and the img is then classified using this model (both training and testing)

% for i = 1:options.numDomains
%     eval(sprintf(' mdl = fitcecoc(PhitoF(:,(%i-1)*N*ncl+1:N*ncl*%i)'',YF((%i-1)*N*ncl+1:N*ncl*%i,:)); ',i,i,i,i));
%     eval(sprintf(' [resub_pred,~] = resubPredict(mdl); '));
%     eval(sprintf(' results.img%i_mdl%i.resub_assess = assessment(YF((%i-1)*N*ncl+1:N*ncl*%i,:),resub_pred,\''class\''); ',i,i,i,i));
%     
%     eval(sprintf(' pred = predict(mdl,Phi%iTtoF''); ',i));
%     eval(sprintf(' results.img%i_mdl%i.assess = assessment(test{1,%i}.Y,pred,\''class\''); ',i,i,i));
% end


%% A general svm model is calculated for every domain,
% and all images are classififed using this model (both training and testing)

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
    eval(sprintf(' results.img%i_kma = assessment(test{1,%i}.Y,pred,\''class\''); ',i,i));
%     eval(sprintf(' results.img%i_kma.pred = pred; ',i,i));
end


for i=1:options.numDomains
    eval(sprintf(' mdl = fitcecoc(labeled{1,i}.X'',labeled{1,i}.Y); '));
    for j=1:options.numDomains
        eval(sprintf(' pred = predict(mdl,anonym{1,j}.X''); '));
        eval(sprintf(' results.img%i_svm%i = assessment(anonym{1,j}.Y,pred,\''class\''); ',j,i));
    end
end
