function [X_r,Y_r] = get_n_value(X,Y,N)
% get N value among array X and Y with as much as possible of each unique value
dim = size(X);
val = unique(Y); temp = size(val); n_val = temp(1);
num_per_val = mean(N/n_val);

X_r = []; Y_r = [];
dim_y = size(Y);
X1 = X'; Y1 = Y; n_bis = N;

while(dim_y(1) > N)
    disp(size(X1));disp(size(Y1));
    [X_r,Y_r,X2,Y2,~] = ppc(X1,Y1,num_per_val);
    disp(size(Y_r));
    dim_y = size(Y_r); n_bis = n_bis - dim_y(1);
    %nouvelle ligne (recalcul de n_val après l'itération)
    val = unique(Y2); temp = size(val); n_val = temp(1);
    %
    num_per_val = n_bis/n_val;
    [X3,Y3,X1,Y1,~] = ppc(X2,Y2,num_per_val);
    
    X_r = [X_r;X3]; Y_r = [Y_r;Y3];
    
%     dim_y = size(Y_r); n_bis = n_bis - dim_y(1);
%     num_per_val = n_bis/n_val;
    
end