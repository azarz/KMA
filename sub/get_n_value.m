function [X_r,Y_r] = get_n_value(X,Y,N)
% get N value among array X and Y with as much as possible of each unique
% value
val = unique(Y); temp = size(val); n_val = temp(1);
num_per_val = ceil(N/n_val);

X_r = []; Y_r = [];
dim_y = size(Y_r);
Xtemp = X'; Ytemp = Y; n_bis = N;

% disp('get_n_value');
while(dim_y(1) < N)
    [X1,Y1,Xtemp,Ytemp,~] = ppc(Xtemp,Ytemp,num_per_val,0);
    X_r = [X_r;X1]; Y_r = [Y_r;Y1];
    
    dim_y = size(Y_r); n_bis = N - dim_y(1);
    val = unique(Ytemp); temp = size(val); n_val = temp(1);
    
    num_per_val = ceil(n_bis/n_val);
    
%     disp(n_bis);
%     disp(dim_y);
%     disp(num_per_val);
%     disp('***');
%     disp(size(Ytemp));
%     disp('----');
end