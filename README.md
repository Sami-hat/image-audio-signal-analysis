# Audio and Visual Signal Processing

## Overview
This project implements signal processing techniques in MATLAB for both audio noise removal and image object segmentation/classification.

## Project Structure

audio_analysis.m              # Audio processing script (Parts 1 & 2)
image_analysis.m              # Image processing script (Parts 3 & 4)
run_scripts.m                 # Main script to run all analyses
Data/
Audio/
  audio_in_noise1.wav
  audio_in_noise2.wav
  audio_in_noise3.wav
  noise_removed<fileNo>.wav    # Output files
  Plots/                       # Generated plots
Image/
  Easy.jpg
  Medium.jpg
  Hard.jpg
  Very Hard.jpg
  Extreme.jpg
  Plots/                       # Generated plots

## Running the Code

### Run All Scripts
To execute both audio and image processing:
```matlab
run_scripts.m
```

### Run Individual Components
- **Audio Processing Only**:  
  ```matlab
  audio_analysis.m
  ```
- **Image Processing Only**:  
  ```matlab
  image_analysis.m
  ```

## Outputs
- **Audio**: Filtered audio files saved as  
  ```
  Data/Audio/noise_removed<fileNo>.wav
  ```
- **Plots**: All visualizations saved under  
  ```
  Data/Audio/Plots/
  Data/Image/Plots/
  ```

---

## Requirements
- **MATLAB** (R2021a or later)  
- Input files placed in the specified `Data/` directory structure  
