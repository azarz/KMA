
close all;
warning off;
addpath(genpath('../'));    % add sub-directory
clear;
clc;

for z=1:7
    
    Z = z*10;
    oa_img1_svm1 = []; oa_img1_svm2 = [];
    oa_img2_svm1 = []; oa_img2_svm2 = [];
    oa_img1_kma = []; oa_img2_kma = [];
    
    for rep=1:20
        
        disp('******************');
        disp('Z = '); disp(Z);
        disp('rep = '); disp(rep);
        
        %% - Create data
        disp('Creating data');

        options.kernelt = 'rbf';

        data{1,1}.name = 'data/exp_89_1000.mat'; data{1,1}.n = Z;
        data{1,2}.name = 'data/exp_66_1000.mat'; data{1,2}.n = Z;
        n_data = size(data);

        for i = 1:n_data(2)
            eval(sprintf(' load(data{1,i}.name); '));
            eval(sprintf(' unlabeled{1,i}.X = U''; test{1,i}.X = X(1:2:end,:); test{1,i}.Y = Y(1:2:end,:); '));

            eval(sprintf(' Xtemp%i = X(2:2:end,:); Ytemp%i = Y(2:2:end,:); ',i,i));
            eval(sprintf(' [X,Y,A,B,~] = ppc(Xtemp%i,Ytemp%i,data{1,i}.n); ',i,i));
            eval(sprintf(' labeled{1,i}.X = X''; labeled{1,i}.Y = Y; labeled{1,i}.X_all = Xtemp%i; labeled{1,i}.Y_all = Ytemp%i; ',i,i));
            eval(sprintf(' anonym{1,i}.X = A''; anonym{1,i}.Y = B; '));
        end

        %% - Find projections
        disp('Finding projection');
        [ALPHA,LAMBDA,options] = KMA(labeled,anonym,options);

        %% - Project test data
        disp('Projecting data');
        [Phi,ncl] = KMAproject(labeled,anonym,test,ALPHA,options);

        %% - Classify
        result = KMA_classify(data,labeled,test,anonym,Phi,ncl,options);
        
        oa_img1_svm1 = [oa_img1_svm1,result.img1_svm1.OA];
        oa_img1_svm2 = [oa_img1_svm2,result.img1_svm2.OA];
        oa_img2_svm1 = [oa_img2_svm1,result.img2_svm1.OA];
        oa_img2_svm2 = [oa_img2_svm2,result.img2_svm2.OA];
        oa_img1_kma = [oa_img1_kma,result.img1_kma.OA];
        oa_img2_kma = [oa_img2_kma,result.img1_kma.OA];
        
        eval(sprintf(' RESULT.Z%i.rep%i = result; ',Z,rep));
        
        clear options result
    end
    
    eval(sprintf(' RESULT.Z%i.mean_img1_svm1 = mean(oa_img1_svm1); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img1_svm1 = std(oa_img1_svm1); ',Z));
    eval(sprintf(' RESULT.Z%i.mean_img1_svm2 = mean(oa_img1_svm2); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img1_svm2 = std(oa_img1_svm2); ',Z));
    eval(sprintf(' RESULT.Z%i.mean_img2_svm1 = mean(oa_img2_svm1); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img2_svm1 = std(oa_img2_svm1); ',Z));
    eval(sprintf(' RESULT.Z%i.mean_img2_svm2 = mean(oa_img2_svm2); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img2_svm2 = std(oa_img2_svm2); ',Z));
    eval(sprintf(' RESULT.Z%i.mean_img1_kma = mean(oa_img1_kma); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img1_kma = std(oa_img1_kma); ',Z));
    eval(sprintf(' RESULT.Z%i.mean_img2_kma = mean(oa_img2_kma); ',Z));
    eval(sprintf(' RESULT.Z%i.std_img2_kma = std(oa_img2_kma); ',Z));
    
end

disp('KMA finished');