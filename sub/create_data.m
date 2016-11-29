function [toto] = create_data()
%Create test data for KMA

r = 0.15; % noise in the multidim data

exp = '1';
modif = createModif(exp);
modif.additDim = 1;

load ./data/ellipses2D.mat

%Add the third discriminant dimension
if modif.X1_3D
    X1 = [X1 linspace(0,1,length(X1))'];
end

if modif.X2_3D
    X2 = [X2 linspace(0,1,length(X2))'];
end
    
X1 = repmat(X1,1,modif.additDim);
X2 = repmat(X2,1,modif.additDim);

% for r = linspace(0,1,20)
%     X1pr = X1+rand(size(X1))*r;
%     X2pr = X2+rand(size(X2))*r;
% 
%     figure(1)
%     plot(X1pr(:,1),X1pr(:,2),'r.')
%     hold on
%     plot(X2pr(:,1),X2pr(:,2),'.')
%     hold off
%     title(num2str(r));
%     pause
% end

X1 = X1+rand(size(X1))*r;
X2 = X2+rand(size(X2))*r;

XT1 = X1(1:2:end,:)';   % 50%/50% split for training and testing
YT1 = Y1(1:2:end,:);
Xtemp1 = X1(2:2:end,:);
Ytemp1 = Y1(2:2:end,:);
T = length(XT1)/2;

XT2 = X2(1:2:end,:)';
YT2 = Y2(1:2:end,:);
Xtemp2 = X2(2:2:end,:);
Ytemp2 = Y2(2:2:end,:);

[X1,Y1,U1,Y1U,ids1] = ppc(Xtemp1,Ytemp1,N);
[X2,Y2,U2,Y2U,ids2] = ppc(Xtemp2,Ytemp2,N);

X1 = X1'; X2 = X2';
U1 = U1(1:2:end,:)';
U2 = U2(1:2:end,:)';

clear *temp*

Y1U = zeros(length(U1),1);
Y2U = zeros(length(U2),1);
ncl = numel(unique(Y1));

%% - Distortions (optionnal)
disp('Data distortion');

if modif.classes
   ii = find(Y2 == 1);
   jj = find(Y2 == 3); 
   Y2(ii,1) = 3; Y2(jj,1) = 1;
   
   ii = find(YT2 == 1);
   jj = find(YT2 == 3);
   YT2(ii,1) = 3; YT2(jj,1) = 1;
end

if modif.mirror
   X1(1,:) = X1(1,:)*-1;
   U1(1,:) = U1(1,:)*-1;
   XT1(1,:) = XT1(1,:)*-1;
end

if modif.square
    X1(1,:) = X1(1,:).^2; 
    U1(1,:) = U1(1,:).^2; 
    XT1(1,:) = XT1(1,:).^2; 
end

if modif.lines
    X1(1,:) = linspace(min(X1(1,:)),max(X1(1,:)),length(X1))+rand(1,length(X1))/10;
    X1(2,:) = linspace(min(X1(2,:)),max(X1(2,:)),length(X1))+rand(1,length(X1))/10;
    
    U1(1,:) = linspace(min(U1(1,:)),max(U1(1,:)),length(U1))+rand(1,length(U1))/10;
    U1(2,:) = linspace(min(U1(2,:)),max(U1(2,:)),length(U1))+rand(1,length(U1))/10;
    
    XT1(1,:) = linspace(min(XT1(1,:)),max(XT1(1,:)),length(XT1))+rand(1,length(XT1))/10;
    XT1(2,:) = linspace(min(XT1(2,:)),max(XT1(2,:)),length(XT1))+rand(1,length(XT1))/10;
end

if modif.additDimNoise
   X1 = [X1;rand(1,length(X1))/1];
   U1 = [U1;rand(1,length(U1))/1];
   XT1 = [XT1;rand(1,length(XT1))/1];
end