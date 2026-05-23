# Classical Emulation of Quantum State Tomography and Bell Inequality Violations

This repository contains MATLAB scripts developed for the analysis of experiments in quantum state tomography and Bell inequality measurements using a pulsed laser optical setup.

The repository consists of three parts:
1. **Quantum State Tomography (QST):** Reconstructing the density matrix of the emulated states.
2. **Bell Inequality (CHSH) Violation:** Calculating the correlation coefficients (E) and the CHSH Bell parameter (S) across 16 independent measurement projections.
3. **Numerical simulations:** Modeling the optical setup in Python to evaluate state fidelity convergence and the theoretical CHSH threshold dependence.

### 1. `POINTFINDER.m` 
Before running the main analysis, the Region of Interest (ROI) for each detector must be defined.
* **What it does:** This interactive tool opens a specific frame from a video file and allows the user to manually draw a bounding box around the laser pulse. 
* **How to use it:** Run the script, draw a rectangle over the target pulse, and double-click to confirm. The script will output the exact MATLAB code (row and column coordinates) into the Command Window.
* **Next step:** Copy the generated coordinates and paste them into the ROI definition sections of the main analysis scripts.

### 2. `part1.m` (Density Matrix Reconstruction / QST)
This script performs full Quantum State Tomography on a single video file containing a specific target state.
* **What it does:** 1. Loads the video and extracts the analog intensity from four detectors simultaneously.
  2. Applies a dynamic intensity threshold (set to 60% of the peak) to digitize the continuous laser pulses into discrete "clicks."
  3. Identifies coincidence events across the detectors within a predefined frame window.
  4. Calculates the state amplitudes and reconstructs the 4x4 density matrix ($\rho$).
* **Output:** A detailed 3D bar plot of the reconstructed density matrix and a terminal output of the calculated amplitudes.

### 3. `step1_extract.m` (CHSH Data Extraction)
This is the first half of the CHSH Bell test workflow. It processes the raw video data and saves it, preventing the need to re-read heavy video files multiple times.
* **What it does:** Iterates over the 16 video files corresponding to the different polarization basis pairs required for the CHSH inequality. It integrates the pixel values within the predefined ROIs to extract the continuous optical power and performs baseline (dark current) subtraction.
* **Output:** Saves a structured `.mat` file (`CHSH_Raw_Intensities.mat`) containing the clean, continuous analog signals for Alice and Bob.

### 4. `step2_analyze.m` (Post-Selection & S Parameter)
This script performs the physical post-selection that enables the classical system to violate the Bell inequality.
* **What it does:** 1. Loads the `CHSH_Raw_Intensities.mat` file.
  2. Applies independent, manually calibrated intensity thresholds for Alice and Bob's channels.
  3. Identifies discrete events and counts coincidences within a strict timing window, effectively discarding unmatched statistical fluctuations (exploiting the fair-sampling loophole).
  4. Calculates the correlation parameter (E) for each basis pair and computes the final CHSH Bell parameter (S).
* **Output:** A comprehensive visual layout of 16 separate figures showing the continuous signals, the applied threshold lines, and markers indicating successful coincidences (green) versus unmatched events (red). It prints the final coincidence matrix and the S parameter to the console.


### 5. `PART1QTS.py` (Fidelity Convergence)
* **What it does:** Simulates the continuous-to-discrete pulse detection mechanism using Malus's law and natural Gaussian noise. It reconstructs the emulated density matrix and calculates the Fidelity parameter ($F$) compared to an ideal $|\Psi^+\rangle$ Bell state as a function of the pulse sequence length ($N$).
* **Output:** Generates a plot illustrating how the state fidelity converges toward 1.0 as the number of pulses increases, marking the specific $N$ values used in the physical lab setup.

### 6. `QTSPART2.py` (Numerical Bell Test)
* **What it does:** Models the exact experimental CHSH setup ($N=20$ pulses, 1% noise) across 150 different detection threshold values. It mathematically extracts coincidence counts and calculates the Bell parameter ($S$).
* **Output:** Generates a plot showing the $S$ parameter as a function of the detection threshold. It highlights the specific threshold windows where classical post-selection artificially inflates the correlation, successfully pushing the system above the classical bound ($S>2$).
