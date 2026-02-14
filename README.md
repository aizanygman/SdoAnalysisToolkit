# SDO Analysis Toolkit

A MATLAB-based research toolkit for analyzing spike-triggered state transitions in neuromuscular systems using state-dependent operators (SDO). This project investigates how neural spikes reshape motor dynamics through probabilistic transition modeling, background normalization, and bootstrap-based statistical validation.

---

## Overview

This repository implements computational methods to quantify how neural spike events influence muscle state transitions. Continuous motor signals (e.g., EMG) are discretized into states, and state-dependent operators are computed to model pre- to post-spike transition probabilities.

The framework supports:

- Spike-triggered SDO computation  
- Background-normalized transition modeling  
- Markov-based state transition analysis  
- Bootstrap resampling for statistical validation  
- Hierarchical data structuring for large-scale comparisons  

---

## Research Goals

- Quantify spike-induced changes in motor state dynamics  
- Analyze energy landscape modifications associated with neural control  
- Compare thousands of transition matrices across temporal parameter configurations  
- Provide statistically validated measures of spike-specific effects  

---

## Methodology

### 1. Signal Discretization
Continuous EMG signals are mapped into discrete amplitude states to construct a finite state space.

### 2. State-Dependent Operators (SDO)
Transition matrices are computed to model:

    P(x_post | x_pre, spike)

These matrices characterize how motor states evolve around neural spike events.

### 3. Background Normalization
Null transition models are generated to isolate spike-specific effects from baseline dynamics.

### 4. Bootstrap Validation
Bootstrap resampling (≥100 iterations per condition) is used to estimate variability and assess statistical significance.

### 5. Hierarchical Data Structure
Results are organized in a structured hierarchy:

    Frog → Neuron → Muscle → SDO → Features

This enables scalable cross-condition and cross-animal comparisons.

---

## Repository Structure

- `sdoMultiMat.m` – Core class for multi-parameter SDO computation  
- `sdo_testing.m` – Example workflow for hierarchical analysis  
- `sdoAnalysis_demo.mlx` – Demonstration script  
- `+pxTools/` – Discretization and utility functions  
- Supporting MATLAB scripts for simulation and visualization  

---

## Getting Started

1. Clone the repository:
git clone https://github.com/aizanygman/SdoAnalysisToolkit.git


2. Add the folder to your MATLAB path:
addpath(genpath('path/to/SdoAnalysisToolkit'));

3. Load your data (example):
load('spikeTimeCell.mat');
load('emgCell.mat');

4. Run analysis:
sdo_testing
