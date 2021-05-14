clc;
clear all;
I = imread('Test.JPG');
ti=size(I);
colorbar
figure,imshow(I);
title('Original image');
xlabel(['Rozmer''image : ',num2str(ti(2)),'x',num2str(ti(1))])
ImageSize = 8*prod(size(I))

Y = rgb2ycbcr(I);
figure,imshow(Y);
title('YCBCR image');

lb = {'Y', 'Cb', 'Cr'};

for channel = 1:3
    subplot(1,3,channel)
    Y_C = Y;
    Y_C(:,:,setdiff(1:3,channel)) = intmax(class(Y_C))/2;
    imshow(ycbcr2rgb(Y_C))
    title([lb{channel} ' component'],'fontsize',16)
end

subplot(1,2,1)
figure,imshow( I )
title('Original')
subplot(1,2,2)
Y_d = Y;
Y_d(:,:,2) = 10*round(Y_d(:,:,2)/10);
Y_d(:,:,3) = 10*round(Y_d(:,:,3)/10);
imshow(ycbcr2rgb(Y_d))
title('Downsampled image')


I=rgb2gray(I);
I = imresize(I, [512 512]);
figure,imshow(I);
title('Gray/resize original');

I1 = I;
disp(size(I));
[row coln] = size(I);
I = double(I);
%---------------------------------------------------------
% Subtracting each image pixel value by 128 
%--------------------------------------------------------
I = I - (128*ones(512));
quality = input('What quality of compression you require - ');
%----------------------------------------------------------
% Quality Matrix Formulation
%----------------------------------------------------------
Q50 = [ 16 11 10 16 24 40 51 61;
     12 12 14 19 26 58 60 55;
     14 13 16 24 40 57 69 56;
     14 17 22 29 51 87 80 62; 
     18 22 37 56 68 109 103 77;
     24 35 55 64 81 104 113 92;
     49 64 78 87 103 121 120 101;
     72 92 95 98 112 100 103 99];
 
 
 if quality > 50
     QX = round(Q50.*(ones(8)*((100-quality)/50)));
     QX = uint8(QX);
 elseif quality < 50
     QX = round(Q50.*(ones(8)*(50/quality)));
     QX = uint8(QX);
 elseif quality == 50
     QX = Q50;
 end
 
%----------------------------------------------------------
% Formulation of forward DCT Matrix and inverse DCT matrix
%----------------------------------------------
DCT_matrix8 = dct(eye(8));
iDCT_matrix8 = DCT_matrix8';   %inv(DCT_matrix8);
%----------------------------------------------------------
% Jpeg Compression
%----------------------------------------------------------
dct_restored = zeros(row,coln);
QX = double(QX);
%----------------------------------------------------------
% Jpeg Encoding
%----------------------------------------------------------
%----------------------------------------------------------
% Forward Discret Cosine Transform
%----------------------------------------------------------
for i1=[1:8:row]
    for i2=[1:8:coln]
        zBLOCK=I(i1:i1+7,i2:i2+7);
        win1=DCT_matrix8*zBLOCK*iDCT_matrix8;
        dct_domain(i1:i1+7,i2:i2+7)=win1;
    end
end
%-----------------------------------------------------------
% Quantization of the DCT coefficients
%-----------------------------------------------------------
for i1=[1:8:row]
    for i2=[1:8:coln]
        win1 = dct_domain(i1:i1+7,i2:i2+7);
        win2=round(win1./QX);
        dct_quantized(i1:i1+7,i2:i2+7)=win2;
    end
end
%-----------------------------------------------------------
% Jpeg Decoding 
%-----------------------------------------------------------
% Dequantization of DCT Coefficients
%-----------------------------------------------------------
for i1=[1:8:row]
    for i2=[1:8:coln]
        win2 = dct_quantized(i1:i1+7,i2:i2+7);
        win3 = win2.*QX;
        dct_dequantized(i1:i1+7,i2:i2+7) = win3;
    end
end
%-----------------------------------------------------------
% Inverse DISCRETE COSINE TRANSFORM
%-----------------------------------------------------------
for i1=[1:8:row]
    for i2=[1:8:coln]
        win3 = dct_dequantized(i1:i1+7,i2:i2+7);
        win4=iDCT_matrix8*win3*DCT_matrix8;
        dct_restored(i1:i1+7,i2:i2+7)=win4;
    end
end
I2=dct_restored;
% ---------------------------------------------------------
% Conversion of Image Matrix to Intensity image
%----------------------------------------------------------
K=mat2gray(I2);
%info = imfinfo(K);
%disp(K);
%K = imresize(K, [512 512]);
%----------------------------------------------------------
%Display of Results
%----------------------------------------------------------
%figure(1);imshow(I1);title('original image');
figure(2);imshow(K);title('restored image from dct');
%store cerated image
imwrite(K, '/Users/lenkapetnuchova/Desktop/DP/jpegprotected/JPEG/afterJPEG.jpeg');


% Convert image to greyscale
input = imread('afterJPEG.jpeg');
  
% Resize the image to required size
input=imresize(input, [512 512]);

% Message to be embedded
message='FEIFORTHEWIN';
  
% Length of the message where each character is 8 bits
len = length(message) * 8;
  
% Get all the ASCII values of the characters of the message
ascii_value = uint8(message);
  
% Convert the decimal values to binary
bin_message = transpose(dec2bin(ascii_value, 8));
  
% Get all the binary digits in separate row
bin_message = bin_message(:);
  
% Length of the binary message
N = length(bin_message);
disp('LENGTH OF MESSAGE IN BITS');
disp(N);

% Converting the char array to numeric array
bin_num_message=str2num(bin_message);
  
% Initialize output as input
output = input;
  
% Get height and width for traversing through the image
height = size(input, 1);
width = size(input, 2);
  
% Counter for number of embedded bits
embed_counter = 1;

lsb_counter = 0;

% Calculate number of LSB which can be changed in image
for i = 1 : height
    for j = 1 : width
       LSB = mod(double(input(i, j)), 2); 
       if(LSB == 1)
           lsb_counter = lsb_counter+1;
       end
    end
end
disp('MAX NUMBER OF LSB BITS THAT CAN BE EMBEDED INTO IMAGE')
disp(lsb_counter)
    

% Traverse through the image if its possible and message is shorter than
% number of LSB
if(lsb_counter >= N)
    for i = 1 : height
        for j = 1 : width

            % If more bits are remaining to embed
            if(embed_counter <= len)
                
                % Finding the Least Significant Bit of the current pixel
                %LSB = mod(double(K(i, j)), 2);
                %disp(LSB)  

                % Find whether the bit is same or needs to change
                %temp = double(xor(LSB, bin_num_message(embed_counter)));
                %disp(temp)    

                % Updating the output to K + temp
                %output(i, j) = K(i, j)+temp;

                output(i, j) = input(i, j) - mod(double(input(i, j)), 2) + bin_num_message(embed_counter);

                % Increment the embed counter
                embed_counter = embed_counter+1;
            end

        end

    end
elseif(lsb_counter < N)
   disp('MESSAGE TOO LONG');
end

% Write both the input and output images to local storage
% Mention the path to a folder here.
imwrite(input, '/Users/lenkapetnuchova/Desktop/DP/jpegprotected/JPEG/originalImage.png');
imwrite(output, '/Users/lenkapetnuchova/Desktop/DP/jpegprotected/JPEG/stegoEncryptedImage.png');

%Export to .xls
filename = '\Users\lenkapetnuchova\Desktop\DP\jpegprotected\JPEG\output_crypted_img.xlsx';
  
xlswrite(filename, output);