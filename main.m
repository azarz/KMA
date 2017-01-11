close all;
warning off;
addpath(genpath('../'));    % add sub-directory
clear;
clc;

% A faire
% Comparer KMA+SVM et SVM
% avec beaucoup de ppc sur img_1 et très peu sur img_2
% et montrer que KMA est mieux pour classifier img_2, grâce aux donnée sur img_1 (récente)

    %% - Create data
    disp('Creating data');

    options.kernelt = 'rbf';

    data{1,1}.name = 'data/exp_89_500.mat'; data{1,1}.n = 40;
    data{1,2}.name = 'data/exp_66_500.mat'; data{1,2}.n = 40;
%     data{1,3}.name = 'data/exp_66_500.mat'; data{1,3}.n = 30;
    n_data = size(data);

    for i = 1:n_data(2)
        eval(sprintf(' load(data{1,i}.name); '));
        eval(sprintf(' unlabeled{1,i}.X = U''; '));
        eval(sprintf(' test{1,i}.X = X(1:2:end,:); test{1,i}.Y = Y(1:2:end,:); '));
        
        eval(sprintf(' Xtemp%i = X(2:2:end,:); Ytemp%i = Y(2:2:end,:); ',i,i));
        eval(sprintf(' [X,Y,A,B,~] = ppc(Xtemp%i,Ytemp%i,data{1,i}.n); ',i,i));
        eval(sprintf(' labeled{1,i}.X = X''; labeled{1,i}.Y = Y; labeled{1,i}.X_all = Xtemp%i; labeled{1,i}.Y_all = Ytemp%i; ',i,i));
        eval(sprintf(' anonym{1,i}.X = A''; anonym{1,i}.Y = B; '));
    end

    %% Calculate the ratio of unlabeled data fraction, and the number of repetitions
    % find the image with most pixel
    sz = [];
    for i=1:n_data(2)
        sz = [sz;size(unlabeled{1,i}.X)];
    end
    mx = sum(sz);
    
    % find ratio of pixel for each img which has less pixel than mx
    size_X = size(labeled{1,1}.X);
    div = 1/n_data(2);
    total = 1;
    for i=1:n_data(2)
        sz = size(unlabeled{1,i}.X);
        temp = sz(2)/mx(2);
        ratio{1,i} = round(temp*size_X(2));
        total = total + (1-temp);
    end
    
    % find ratio of pixel for img with max pixel
%     temp = 0;
%     for i=1:n_data(2)
%         sz = size(unlabeled{1,i}.X);
%         if sz(2) == mx(2)
%             ratio{1,i} = total;
%         end
%         temp = temp + ratio{1,i};
%     end
%     
    if temp > size_X(2)     % be careful not to take too many pixels !
        ratio{1,1} = ratio {1,1} - (temp-200);
    end
    
    % find number of repetiton to project all data
    sz = size(unlabeled{1,1});
    a = floor(mx(2)/size_X(2)); b = mod(mx(2),size_X(2));
    rep = a;        % the number of repetition depends on the division of each fraction
    if b>0
        rep = rep+1;
    end
    disp(rep);
    
    clear U
     % Repetion for every fraction of unlabeled data
    for z=1:rep
        disp(z);
        disp('**********');
        % Build the structure that contains the fraction of unlabeled data
        for i = 1:n_data(2)
            if z == rep
                sz = size(unlabeled{1,i}.X);
                U{1,i}.X = unlabeled{1,i}.X(:,1+(z-1)*ratio{1,i}:sz(2));
                disp(1+(z-1)*ratio{1,i}); disp(sz(2));
                disp('a');
            else
                U{1,i}.X = unlabeled{1,i}.X(:,1+(z-1)*ratio{1,i}:z*ratio{1,i});
                disp(1+(z-1)*ratio{1,i}); disp(z*ratio{1,i});
            end
        end
    
        % - Find projections
        disp('Finding projection');
        [ALPHA,LAMBDA,options] = KMA(labeled,anonym,options);

        %% - Project test data
        disp('Projecting data');
        [Phi,ncl] = KMAproject(labeled,anonym,test,ALPHA,options);

        %% - Classify
        result = KMA_classify(data,labeled,test,anonym,Phi,ncl,options);
    end
        
disp('KMA finished');