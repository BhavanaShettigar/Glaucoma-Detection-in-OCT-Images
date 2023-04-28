grayImage = imread('C:\Users\user\Documents\MATLAB\h_june_twelve\OUTPUT_CANNY\T1.jpg');
gray = rgb2gray(grayImage);
binaryImage =  imbinarize(gray);
figure, imshow(binaryImage), title('binary');
%a = [287.39  723.43];
%b = [1938.60 844.27];

x1 = 287;
y1 = 723;
x2 = 1938;
y2 = 844;

x = [x1 x2];
y = [y1 y2]; 
imshow(binaryImage)
hold on
plot(x,y,'red');

mid = [(x1+x2)/2 , (y1+y2)/2];
plot(mid(1),mid(2),'y+', 'MarkerSize', 10);

L = 30 ;
minv = -1/m;
line([mean(x) mean(x)+L],[mean(y) mean(y)+L*minv],'Color','g')
axis equal

 h = gca; % GCA = Get Current Axes
  h.Visible = 'on';


[x,y] = ginput(2);
plot(x,y);

 h = imdistline(gca,[x],[y]);
 %fprintf('%f' ,h);