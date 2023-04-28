 A= imread('trial.jpg');
   GrayImage = rgb2gray(A);
GLCM = graycomatrix(GrayImage,'Offset',[2 0]);
out = GLCM_Features(GLCM);