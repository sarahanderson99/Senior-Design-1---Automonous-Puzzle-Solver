close all
clc
clear

% Setting up webcam properties
cam_list = webcamlist;
cam_name = cam_list{2};
cam = webcam(cam_name);
%% 
preview(cam)
%% 
closePreview(cam)
%% 
img = snapshot(cam);
figure()
imshow(img)
%% 
preview(cam)
%% 
closePreview(cam)
%% 
img2 = snapshot(cam);
figure()
imshow(img2)
%%
imwrite(img, 'markers_test.png')
imwrite(img2, 'gameboard_test.png')
