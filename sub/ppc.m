% ppc: data splitting with a per-class criterion
%
% [X_train Y_train X_test Y_test indices] = ppc(X,Y,ppc)
%
% This function splits the data in X according to the labels in Y and
% returns train and test data, along with the indices in the original data
% vector.
%
% Inputs:       - X: data vector
%               - Y: labels vector
%               - ppc: rule for splitting
%                       o if ppc < 1, it is a percentage per class
%                       o otherwise, # of points per class
%               - randstate: random numbers generator
%
% Outputs:      - X_train, X_test: data vectors in training and test
%               - Y_train, Y_test: label vectors in training and test
%               - indices: indices in the original vectors X and Y.
%
% Devis Tuia and Jordi Mu?oz, 2010

function [X_train,Y_train,X_test,Y_test,indices,pos] = ppc(X,Y,ppc, print)

if nargin < 4
    print = 1;
end

% s = rng;    %Get random state
% rng(randstate);     %Random value based on integer

flip = 0;
class_list = unique(Y(:,1));   %store each label value

if size(Y,1) < size(Y,2)    %Check if vector must be transposed
    flip = 1;
end

if flip
    Y = Y';
    X = X';
end

X_train = []; Y_train = []; X_test = []; Y_test = []; pos = [];
indices = zeros(size(Y,1),1);   %zero column vector

if ppc >= 1     %start spliting with #ppc
    for i = 1:size(class_list,1)
        class_id = find(Y(:,1) == class_list(i));    %find all similar label i
        perm_table = randperm(size(class_id,1))';
               
        ppc2 = ppc;
        if size(class_id,1) <= ppc    %if given ppc is too low
            ppc2 = size(class_id,1) - floor(size(class_id,1)/5);
            if print ~= 0
                fprintf('Taking 80%% of the %i available pixels for class %i : %i\n',size(class_id,1),i,ppc2);
            end
        end
        
        indices(class_id(perm_table(1:ppc2))) = 1;     %split indices, based on ppc
        indices(class_id(perm_table(ppc2+1:end))) = 2;
        
        X_train = [X_train;X(class_id(perm_table(1:ppc2)),:)];
        Y_train = [Y_train;Y(class_id(perm_table(1:ppc2)),:)];
        X_test = [X_test;X(class_id(perm_table(ppc2+1:end)),:)];
        Y_test = [Y_test;Y(class_id(perm_table(ppc2+1:end)),:)];
        
        pos = [pos; class_id(perm_table)];
    end
else
    for i = 1:numel(class_list);
        class_id = find(Y == class_list(i));
        perm_table = randperm(size(class_id,1))';
        ppc2 = max( fix(ppc*size(class_id,1)) ,5); % fix a minimal number of pixels (5)
        
        indices(class_id(perm_table(1:ppc2))) = 1;
        indices(class_id(perm_table(ppc2+1:end))) = 2;
        
        X_train = [X_train;X(class_id(perm_table(1:ppc2)),:)];
        Y_train = [Y_train;Y(class_id(perm_table(1:ppc2)),:)];
        X_test = [X_test;X(class_id(perm_table(ppc2+1:end)),:)];
        Y_test = [Y_test;Y(class_id(perm_table(ppc2+1:end)),:)];
        
        pos = [pos; class_id(perm_table)];
    end
end

if flip     %if initial vector where flipped, flip result back
    X_train = X_train';
    X_test = X_test';
    Y_train = Y_train';
    Y_test = Y_test';
end

% rand('state',s);
% rng(s);
