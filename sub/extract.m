function [X,Y,U] = extract(attr_file,label_file,print)
%Extract data from TIFF file
%
% Input:
%
% - attr_name: name of the file containig pixel attribule
%
% - label_name: name of the file containing labeled pixel
% 
%
%  Output:
%  
%  - X: attributes from labeled pixel
%  
%  - Y: attributes of labeled pixel
%  
%  - U: attributes from unlabeled pixel
%

if nargin < 3
    print = 0;
end

l1 = length(attr_file);
if ~strcmp(attr_file(l1-3:l1),'.tif')
    attr_file = [attr_file,'.tif'];
end

l2 = length(label_file);
if ~strcmp(label_file(l2-3:l2),'.tif')
    label_file = [label_file,'.tif'];
end

info = imfinfo(attr_file);
n = info.SamplesPerPixel;   % number of attributes
max = info.Width*info.Height;

X = zeros(max,n); id = 1;     %attributes, label, and unlabeled matrix
Y = zeros(max,1);
U = zeros(max,n); idu = 1;

if print ~= 0
    disp('Extracting data');
end
img = imread(attr_file);
label = imread(label_file);

if print ~= 0
    disp('Sorting data');
end
for i=1:info.Height
    for j=1:info.Width
        attr = img(i,j,:);
        if label(i,j) == 0
            U(idu,:) = attr;
            idu = idu+1;
        else
            X(id,:) = attr;
            Y(id,:) = label(i,j);
            id = id+1;
        end
    end
    
    if print ~= 0
        disp([num2str(i),'/',num2str(info.Height)]);
    end
    
end

X = X(1:id-1,:);
Y = Y(1:id-1,:);
U = U(1:idu-1,:);