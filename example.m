% Create the calibration images, more the better
% Use the 'PresentStimulus' function to bring up a calibration pattern on
% the screen with known size. 
[dX, dY] = PresentStimulus([10,10], 0);
% and make a recording of the stimulus using ATIS
% (press any key in Matlab to make the stimulus start flashing)

% Read the recordings from ATIS ".val" file and convert to an image using 
% the 'MakeImage' function. 

%% For ATIS
% This script requires some ATIS functions to be on 
% the Matlab Path. These functions can be obtained from
% http://www.garrickorchard.com/code/matlab-AER-functions 
 
filename = '0001.val'; %an example of a filename
[TD, EM] = ReadAER(filename);
%%if using EM events:
calibration_image = MakeImage(EM, [304,240], 1);
%%if using TD events:
% calibration_image = MakeImage(TD, [304,240], 0);

imshow(calibration_image); % optionally show the image

%% For DVS
% % This script requires some DVS functions to be on 
% % the Matlab Path. These functions can be obtained from
% % https://svn.code.sf.net/p/jaer/code/scripts/matlab
% [allAddr,allTs]=loadaerdat(filename);
% [TD.x,TD.y,TD.p]=extractRetinaEventsFromAddr(addr);
% TD.x = TD.x+1; % difference in convention between DVS and ATIS
% TD.y = TD.y+1; % difference in convention between DVS and ATIS
% TD.p(TD.p==-1) = 0;
% 
% image = MakeImage(TD, [128,128], 0);

%% save to a file
image_number = 0; %which of the images is this (multiple images are required for calibration)
calibration_images_directory = 'CalibrationImages'; %name a directory to store the calibration images in
if ~exist(calibration_images_directory, 'dir')
    mkdir(calibration_images_directory) %if the directory doesn't already exist, create it
end
imwrite(calibration_image,[calibration_images_directory, '\img', num2str(image_number), '.bmp'], 'bmp')

%% now run the Caltech Camera Calibration toolbox and use the generated
% images for calibration. The toolbox is available from:
% http://www.vision.caltech.edu/bouguetj/calib_doc/

caltech_calibration_toolbox_path = 'TOOLBOX_calib'; % the path to the toolbox
addpath(genpath([pwd, '\', caltech_calibration_toolbox_path])) %add the toolbox to your path
cd(calibration_images_directory) %change to the directory containing the calibration images
calib_gui %run the calibration toolbox