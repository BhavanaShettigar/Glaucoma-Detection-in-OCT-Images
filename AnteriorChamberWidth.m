clc; 
clear; close all;

r= 287;
c = 723;
r1 = 1938;
c1 = 844;
D = pdist2([r c],[r1 c1],'euclidean'); % euclidean distance
[r2,c2]=find(D==min(D(:)));
point_1=[r(r2) c(r2)];
point_2=[r1(c2) c1(c2)];
plot([point_1(2) point_2(2)],[point_1(1) point_2(1)],'g')
hold off
format shortg;
distance=sqrt( (point_1(1)-point_2(1)).^2 + (point_1(2)-point_2(2)).^2)