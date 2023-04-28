clc; 
clear; close all;
% Specify the folder where the files live.
myFolder = 'C:\Users\user\Documents\MATLAB\g_may_fourteen\OutputKirschCannyImageFolder';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.jpg'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  A= imread(fullFileName);
   GrayImage = rgb2gray(A);
GLCM = graycomatrix(GrayImage,'Offset',[2 0]);
out = GLCM_Features(GLCM);

Ex = [baseFileName out.contrast out.correlation out.energy out.entropy out.homogenity out.variance  out.sumaverage out.sumvariance out.sumentropy out.differencevariance out.differenceentropy out.inf1 out.inf2];
   % Display image.
  drawnow; % Force display to update immediately.
  worksheetName = 'Results';
cellReference = sprintf('A%d', k);
xlswrite('C:\Users\user\Documents\MATLAB\g_may_fourteen\OutputKirschCannyImageFolder\haralickkirschcanny1.xls', Ex, worksheetName, cellReference);
end  