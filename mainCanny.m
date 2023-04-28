%% Clear commands

clc; %Clear command window
close all; %Close windows  

%% Specify image folder

ImageFolder = 'C:\Users\user\Documents\MATLAB\h_june_twelve\COMBINED'; %Path of input image 

%% Warn if folder doesn't exist

if ~isfolder(ImageFolder) %If image folder doesn't exist
  Warning = sprintf('Error: The following folder does not exist:\n%s', ImageFolder); %Warning message to be displayed
  uiwait(warndlg(Warning)); %Display warning dialouge box
  return;
end

%% Get list of files in the folder

Pattern = fullfile(ImageFolder, '*.jpg'); % builds a full file specification from the specified folder and file names i.e.,.jpg,.png
Files = dir(Pattern); %Dir lists the files in the current working directory

for k = 1 : length(Files) %Loop to total number of files in the folder 
  BaseFileName = Files(k).name; %File name
  FullFileName = fullfile(ImageFolder, BaseFileName); %Create full file path with file name
  fprintf(1, 'Reading %s\n', FullFileName); %Print statement

  %% Read input image
  
  OriginalImage = imread(FullFileName);
  %figure, imshow(OriginalImage), title('OriginalImage');

  %% RGB to grayscale conversion

  GrayImage = rgb2gray(OriginalImage);
  %figure,imshow(GrayImage), title('RGBToGrayscale');

  %% Noise Removal - Anisotropic diffusion
  
  DiffusedImage = uint8(anisotropicdiffusion(GrayImage,15,1/5,30));
  %figure,imshow(DiffusedImage), title('AnisotropicDiffusion');
  
  %% Contrast Enhancement - imadjust
  
  EnhanceImage=imadjust(DiffusedImage);
  %figure,imshow(EnhanceImage), title('ContrastEnhancement');
  
  %% Edge detetction - Canny edge detetction
  
  %CannyEdgeImage=edge(EnhanceImage,'canny',0.2);
  %figure,imshow(CannyEdgeImage),title('CannyEdgeDetectedImage');

  image = double (EnhanceImage);
  T_Low = 0.01; %Low threshold value            
  T_High = 0.07; %High threshold value
  %Gaussian Filter Coefficient
  B = [2, 4, 5, 4, 2; 4, 9, 12, 9, 4;5, 12, 15, 12, 5;4, 9, 12, 9, 4;2, 4, 5, 4, 2 ];
  B = 1/159.* B;
  %Convolution of image by Gaussian Coefficient
  A=conv2(image, B, 'same');
  %Filter for horizontal and vertical direction
  KGx = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
  KGy = [1, 2, 1; 0, 0, 0; -1, -2, -1];
  %Convolution of image by horizontal and vertical filter
  Filtered_X = conv2(A, KGx, 'same');
  Filtered_Y = conv2(A, KGy, 'same');
  %Calculate directions/orientations
  arah = atan2 (Filtered_Y, Filtered_X);
  arah = arah*180/pi;
  pan=size(A,1);
  leb=size(A,2);
  %Adjustment for negative directions, making all directions positive
  for i=1:pan
    for j=1:leb
        if (arah(i,j)<0) 
            arah(i,j)=360+arah(i,j);
        end
    end
  end
  arah2=zeros(pan, leb);
  %Adjusting directions to nearest 0, 45, 90, or 135 degree
  for i = 1  : pan
    for j = 1 : leb
        if ((arah(i, j) >= 0 ) && (arah(i, j) < 22.5) || (arah(i, j) >= 157.5) && (arah(i, j) < 202.5) || (arah(i, j) >= 337.5) && (arah(i, j) <= 360))
            arah2(i, j) = 0;
        elseif ((arah(i, j) >= 22.5) && (arah(i, j) < 67.5) || (arah(i, j) >= 202.5) && (arah(i, j) < 247.5))
            arah2(i, j) = 45;
        elseif ((arah(i, j) >= 67.5 && arah(i, j) < 112.5) || (arah(i, j) >= 247.5 && arah(i, j) < 292.5))
            arah2(i, j) = 90;
        elseif ((arah(i, j) >= 112.5 && arah(i, j) < 157.5) || (arah(i, j) >= 292.5 && arah(i, j) < 337.5))
            arah2(i, j) = 135;
        end
    end
  end
  %Calculate magnitude
  magnitude = (Filtered_X.^2) + (Filtered_Y.^2);
  magnitude2 = sqrt(magnitude);
  BW = zeros (pan, leb);
  %Non-Maximum Supression
  for i=2:pan-1
    for j=2:leb-1
        if (arah2(i,j)==0)
            BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i,j+1), magnitude2(i,j-1)]));
        elseif (arah2(i,j)==45)
            BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j-1), magnitude2(i-1,j+1)]));
        elseif (arah2(i,j)==90)
            BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j), magnitude2(i-1,j)]));
        elseif (arah2(i,j)==135)
            BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j+1), magnitude2(i-1,j-1)]));
        end
    end
  end
  BW = BW.*magnitude2;
  %figure, imshow(BW);
  %Hysteresis Thresholding
  T_Low = T_Low * max(max(BW));
  T_High = T_High * max(max(BW));
  T_res = zeros (pan, leb);
  for i = 1  : pan
    for j = 1 : leb
        if (BW(i, j) < T_Low)
            T_res(i, j) = 0;
        elseif (BW(i, j) > T_High)
            T_res(i, j) = 1;
        %Using 8-connected components
        elseif ( BW(i+1,j)>T_High || BW(i-1,j)>T_High || BW(i,j+1)>T_High || BW(i,j-1)>T_High || BW(i-1, j-1)>T_High || BW(i-1, j+1)>T_High || BW(i+1, j+1)>T_High || BW(i+1, j-1)>T_High)
            T_res(i,j) = 1;
        end
    end
  end
  CannyEdgeImage = uint8(T_res.*255);
  %figure, imshow(CannyEdgeImage), title('CannyEdgeDetectedImage');
 
  %% Edge detetction - Kirsch operator
  
%   x=double(edge_final);
%   g1=[5,5,5; -3,0,-3; -3,-3,-3];
%   g2=[5,5,-3; 5,0,-3; -3,-3,-3];
%   g3=[5,-3,-3; 5,0,-3; 5,-3,-3];
%   g4=[-3,-3,-3; 5,0,-3; 5,5,-3];
%   g5=[-3,-3,-3; -3,0,-3; 5,5,5];
%   g6=[-3,-3,-3; -3,0,5;-3,5,5];
%   g7=[-3,-3,5; -3,0,5;-3,-3,5];
%   g8=[-3,5,5; -3,0,5;-3,-3,-3];
%     
%   x1=imfilter(x,g1,'replicate');
%   x2=imfilter(x,g2,'replicate');
%   x3=imfilter(x,g3,'replicate');
%   x4=imfilter(x,g4,'replicate');
%   x5=imfilter(x,g5,'replicate');
%   x6=imfilter(x,g6,'replicate');
%   x7=imfilter(x,g7,'replicate');
%   x8=imfilter(x,g8,'replicate');
%   y1=max(x1,x2);
%   y2=max(y1,x3);
%   y3=max(y2,x4);
%   y4=max(y3,x5);
%   y5=max(y4,x6);
%   y6=max(y5,x7);
%   y7=max(y6,x8);
%   y=y7;
%   figure,imshow(y),title('Kirsch');
  
  %% Morphological operation - Dilation

  a=im2bw(CannyEdgeImage);
  b=getnhood(strel('line',9,90));
  [p q]=size(b);
  %figure, imshow(a), title('GrayscaleToBinary');
  [m n]=size(a);
  DilateImage= zeros(m,n);
  for i=1:m
      for j=1:n
          if (a(i,j)==1)
              for f=1:p
                  for l=1:q
                      if(b(f,l)==1)
                          c=i+f;
                          d=j+l;
                          DilateImage(c,d)=1;
                      end
                  end
              end
          end
      end
  end
%figure, imshow(DilateImage), title('Dilate');
%% Complement dilated image  
ComplementImage = imcomplement(DilateImage);
%figure, imshow(ComplementImage),title('ComplementedImage');

%% Color Fusing with Original Image
[x y z] = size(OriginalImage);
OverlayImage = imoverlay(OriginalImage,imresize(ComplementImage,[x y]),[0, 0, 0]);
%figure, imshow(OverlayImage), title('ColorFusedImage');

%% Save output images in folder specified for further processing
final = OverlayImage;
dest = 'C:\Users\user\Documents\MATLAB\h_june_twelve\OUTPUT_CANNY\';
%imwrite(final,[dest,num2str(k),'T.png']);
imwrite(final,strcat(dest,sprintf('T%d.jpg',k)));

end






