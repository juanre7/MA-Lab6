# Unified Image Processing Pipeline

This repository documents a single MATLAB script that combines color edge visualization, threshold-based sectorization, and a classic grayscale enhancement pipeline with an optional frequency-domain low-pass filter. The goal is to show how pointwise operations, spatial filtering, gradient-based edge detection, labeling, and FFT-based filtering fit together in a coherent flow.

## 1) Pipeline Overview

1. Load RGB image and derive a luminance channel.
2. Compute Canny edges on luminance and visualize alongside the original RGB image.
3. Perform threshold-based sectorization on grayscale, label connected components, and render colored label maps.
4. Apply a grayscale enhancement pipeline: median denoising, contrast stretching, Canny edges on the enhanced image, and an optional ideal low-pass filter in the frequency domain.
5. Present three figures for quick inspection of outcomes.

<img width="850" height="920" alt="Figure_1" src="https://github.com/user-attachments/assets/869e5004-ab41-4343-b7ea-884a82b38ea7" />

## 2) Stage-by-stage DSP interpretation

### A. From RGB to luminance and edges on luminance

* **RGB to grayscale** maps a 3-channel signal to a single-channel luminance signal. This is a linear projection that reduces dimensionality to emphasize intensity structure.
* **Canny edge detection** is a sequence of DSP operations:

  * Gaussian smoothing acts as a low-pass filter to suppress high-frequency noise before differentiation.
  * Gradient estimation uses discrete derivative kernels, which are linear time-invariant operators approximating first-order spatial derivatives.
  * Non-maximum suppression is a non-linear thinning step that preserves local gradient maxima.
  * Hysteresis thresholding links strong and weak edges to improve edge continuity.

<img width="1694" height="920" alt="Figure_2" src="https://github.com/user-attachments/assets/ed89635b-c1ca-49cf-8940-95b2606982a5" />

### B. Threshold-based sectorization and labeling

* **Global thresholding** is a pointwise non-linear operation that quantizes pixel intensities into binary classes at chosen cut levels.
* **Connected-component labeling** interprets the binary image as a graph and assigns region identifiers, which can be viewed as a form of segmentation based on spatial connectivity rather than frequency content.
* **Label-to-RGB mapping** is a visualization step that applies a categorical colormap to integer labels, assisting qualitative analysis of region structure.

<img width="1864" height="813" alt="Figure_3" src="https://github.com/user-attachments/assets/c749fdd5-d1a8-48a9-bc6e-903b62d31787" />


### C. Grayscale enhancement pipeline with optional frequency-domain filtering

* **Median filter** is a non-linear spatial filter effective against impulse noise while preserving edges better than linear averaging.
* **Contrast stretching** is a pointwise intensity transform that remaps the dynamic range to improve visibility. It is not a convolution and does not alter spatial frequencies directly, but it increases local contrast that feeds subsequent detectors.
* **Canny edges on the enhanced image** repeat the gradient-based detection after noise suppression and dynamic range adjustment to improve edge salience.
* **Ideal low-pass filter in the frequency domain**:

  * Compute the 2D FFT, shift the zero frequency to the center, multiply by a circular mask, then inverse shift and inverse FFT.
  * This is exact convolution with a sinc-like kernel in the spatial domain. The hard cutoff introduces ringing due to the Gibbs phenomenon.
  * The mask radius controls the passband bandwidth, trading detail for smoothness.

## 3) Improvements and limitations

**What works well**

* The two edge views provide complementary insight: edges on raw luminance highlight original structure, edges on the enhanced image emphasize features after noise suppression and contrast scaling.
* Sectorization offers quick coarse segmentation that can be useful for counting, masking, or region-of-interest selection.
* The frequency-domain stage illustrates explicit control over the passband and visually links filter design to outcome.

**Known limitations**

* Global thresholds are data dependent. Illumination changes can break a fixed threshold set. Consider Otsu or entropy-based adaptive thresholds per image, or local/adaptive thresholding for uneven lighting.
* Median filtering is robust to impulsive noise but can blur fine textures. A bilateral or guided filter can preserve edges and contrast better at the expense of parameters and compute.
* Canny parameters require tuning. A single pair of hysteresis thresholds and a single smoothing scale might not suit all images. Multi-scale gradients or Laplacian-of-Gaussian at multiple sigmas can improve stability.
* The ideal low-pass is prone to ringing due to the sharp cutoff. A Butterworth or Gaussian low-pass reduces ringing with smoother roll-offs. Alternatively, stay in the spatial domain with separable Gaussian smoothing for efficient, well-behaved blur.
* Grayscale-only edge detection discards chromatic cues. Using gradients in CIELab, vector-valued edge detectors, or channel fusion can recover edges that are primarily chromatic.
* Label images can be dominated by small noisy components. Post-label morphology and size filtering can suppress tiny regions before visualization.

**Potential upgrades**

* Replace fixed thresholds with Otsu or Sauvola, optionally per tile for local adaptation.
* Swap ideal LP for Gaussian or Butterworth filters, or design a custom windowed low-pass in the spatial domain to control side lobes.
* Introduce unsharp masking after denoising for detail enhancement while monitoring noise amplification.
* Move to color-aware gradients or fuse luminance and chroma edges with non-maximum suppression on the combined magnitude.
* Add region statistics after labeling such as area, eccentricity, and mean color, then filter by criteria prior to rendering.

The script is structured so that each parameter has a clear DSP meaning. You can tune thresholds, filter sizes, and cutoff radii to match the spectral and spatial characteristics of your images while keeping a direct line of sight between theory and observed results.
