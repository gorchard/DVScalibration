function [dX, dY] = PresentStimulus(num_squares, num_flashes)
% [dX, dY] = PresentStimulus(num_squares, num_flashes)
% Creates and presents a checkerboard calibration pattern on the screen.
%
% TAKES IN:
%   'num_squares'
%       A scalar indicating the number of squares to show in each
%       direction. Defaults to 10 if no parameters are passed.
%
%   'num_flashes'
%       Dictates how many times the stimulus will be flashed on the screen.
%       A negative or zero value creates a static stimulus (if non-DVS
%       calibration is to be used). If this paramter is omitted,
%       'num_flashes = 0' is assumed (useful for ATIS or DAVIS calibration
%       using snapshot/APS functionality instead of DVS). 
%
%
% RETURNS:
% [dX, dY]
%       The horizontal (dX) and vertical (dY) size of the rectangles
%       displayed on the screen, in units of millimeters. This parameter is
%       required for calibration using the Caltech Camera Calibration
%       Toolbox available from:
%       http://www.vision.caltech.edu/bouguetj/calib_doc/index.html 
%
% EXAMPLE USE:
% PresentStimulus();
% [dY, dX] = PresentStimulus(10, 0); %display static image, identical to above command
% [dY, dX] = PresentStimulus([10,10], 10); %flash ten times
%
% written by Garrick Orchard - June 2015
% garrickorchard@gmail.com

close all;
figure(1)
%% check inputs
%if only one value was passed for num_squares, show the same number in
%each dimension
if ~exist('num_squares', 'var')
    num_squares = [10,10];
end

if length(num_squares)<2
    num_squares = [num_squares,num_squares];
end

% check if the 'num_flashes' variable was passed
if ~exist('num_flashes', 'var')
    num_flashes = 0;
end

%% Obtains the screen size information and use it to determine the rectangle size
[Screen_size_pixels, Screen_size_mm] = getScreenMeasurements();

%fixed parameters of the setup
figure_borderSize = 100; %leave space of 100 pixels on each side of the axes for the figure controls etc
% image_borderSize = 10; %within the image, create a border of size 10 pixels to ensure contrast with the outside rectangles

%How big is each rectangle in units of pixels?
squareSize_pixels = min(floor((Screen_size_pixels - 2*figure_borderSize)./(num_squares+2)));
squareSize_pixels = [squareSize_pixels, squareSize_pixels];
image_borderSize = squareSize_pixels(1);

%How big is each rectangle in units of millimeters?
squareSize_mm = Screen_size_mm.*squareSize_pixels./Screen_size_pixels;

%How big is the checkered part of the image
image_inner_dim = num_squares.*squareSize_pixels; % the dimenstion of the inside of the image (not including the border)

%Create a black image to fit both the checkerboard and the image border
imgTemplate = 0.5*ones(image_inner_dim+2*image_borderSize);

%% create the checkerboard image
img = imgTemplate;
for x = 1:num_squares(1)
    for y = (1+rem(x+1,2)):2:num_squares(2)
        xloc = image_borderSize + ((1+(x-1)*squareSize_pixels(1)):(x*squareSize_pixels(1)));
        yloc = image_borderSize + ((1+(y-1)*squareSize_pixels(2)):(y*squareSize_pixels(2)));
        img(xloc,yloc) = 1;
    end
    for y = (1+rem(x,2)):2:num_squares(2)
        xloc = image_borderSize + ((1+(x-1)*squareSize_pixels(1)):(x*squareSize_pixels(1)));
        yloc = image_borderSize + ((1+(y-1)*squareSize_pixels(2)):(y*squareSize_pixels(2)));
        img(xloc,yloc) = 0;
    end
end

%% display
imshow(img');

warning('Do not resize the checkerboard image window! It has been shown on the screen at a specific size which must be known for calibration')
disp('Checkerboard rectangle size is:')
disp(['Vertical: ', num2str(squareSize_mm(2)), 'mm'])
disp(['Horizontal: ', num2str(squareSize_mm(1)), 'mm'])

if num_flashes>1
    input('Press any button to begin flashing...\n');
    figure(1) %bring the figure to the front (if it is not already in front)
    pause(1) %small pause
    
    % flash 'num_flashes' times
    for i = 1:num_flashes
        imshow(imgTemplate')
        drawnow;
        imshow(img')
        drawnow;
    end
end

dX = squareSize_mm(1);
dY = squareSize_mm(2);