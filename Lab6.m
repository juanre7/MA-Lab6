%% Unified Image Pipeline: Color + Edges + Sectorization + Lab 6 Stages
% Requirements: Image Processing Toolbox
% Image file expected in the working folder:
%   'Mini_Jardin_Bosco.jpg'

close all; clear; clc;

% 1) Read color image and derive luminance
I_rgb  = im2double(imread('Mini_Jardin_Bosco.jpg'));  % RGB, [0,1]
I_gray = rgb2gray(I_rgb);                              % luminance

% 2) Edges on luminance for side-by-side view with the original color image
edges_luma = edge(I_gray, 'Canny', [0.1 0.25]);       % binary edges
edges_rgb  = repmat(edges_luma, [1 1 3]);             % 3-channel for montage

figure;
montage({I_rgb, edges_rgb}, 'Size', [1 2]);
title('Original RGB | Edges on luminance');

% 3) Threshold-based sectorization on grayscale, with colored labels
T = [0.08 0.50 0.70];                                  % thresholds in [0,1]
imgs = cell(1, numel(T) + 1);
imgs{1} = I_rgb;                                       % show original first

for k = 1:numel(T)
    BW = imbinarize(I_gray, T(k));
    L  = bwlabel(BW);
    imgs{k + 1} = im2double(label2rgb(L));            % colored label image
end

figure;
montage(imgs, 'Size', [1 numel(imgs)]);
title(sprintf('Original | Threshold = %.2f | Threshold = %.2f | Threshold = %.2f', T));

% 4) Lab 6 pipeline on luminance: denoise, enhance, edges, optional LP filter
% Denoise with median filter
I_filt = medfilt2(I_gray, [3 3]);

% Contrast enhancement
I_enh = imadjust(I_filt, [0.2 0.8], [0 1]);

% Edge extraction on the enhanced image
edges_enh = edge(I_enh, 'Canny', [0.1 0.25]);

% Optional low-pass filtering in the frequency domain
F = fftshift(fft2(I_enh));
[M, N] = size(F);
[u, v] = meshgrid(-N/2:N/2-1, -M/2:M/2-1);
H = double(sqrt(u.^2 + v.^2) < 60);                    % circular LP mask
I_lp = real(ifft2(ifftshift(F .* H)));

% Visualization of the Lab 6 stages
figure;
montage({I_gray, I_filt, I_enh, edges_enh, I_lp}, 'Size', [1 5]);
title('Original (Gray) | Denoised | Enhanced | Edges | Low-pass result');

%% 5) Notes
% - The first figure preserves your color plus edges comparison.
% - The second figure shows the threshold-based sectorization with label coloring.
% - The third figure reproduces the Lab 6 five-stage pipeline on luminance.
% - Adjust thresholds T, Canny parameters, and the LP radius in H as needed.
