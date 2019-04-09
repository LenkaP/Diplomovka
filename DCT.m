clc;
clear all;

img = imread('lena.bmp');
figure,imshow(img);
title('Original mage');
% figure,imagesc(img);
colorbar

% I = im2double(img);
% figure, imshow(I);
% title('Double');

YCBCR = rgb2ycbcr(I);
figure,imshow(YCBCR);
title('Image in YCbCr Color Space');

%dvojrozmerný DCT 8x8

T = dctmtx(8);
dct = @(block_struct)T .* block_struct.data .* T';
B = blockproc(YCBCR,[8 8],dct);
mask = [1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
B2 = blockproc(B,[8 8],@(block_struct) mask .* block_struct.data);

%inverzného DCT
invdct = @(block_struct) T' .* block_struct.data .* T;
I2 = blockproc(B2,[8 8],invdct);


figure,imshow(I2);
title('DCT image');

%Quantizacia

q_mtx =     [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];

 c = @(block_struct) (block_struct.data) ./ q_mtx;        
 B4 = blockproc(B,[8 8],c);
 
 B5 = blockproc(B4,[8 8],@(block_struct) q_mtx .* block_struct.data);
%Performing Inverse DCT on Blocks of 8 by 8
invdct = @(block_struct) T' .* block_struct.data .* T;
% B3 = ceil(B3);