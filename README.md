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


3. Add the folder to your MATLAB path:
    addpath(genpath('path/to/SdoAnalysisToolkit'));

4. Load your data (example):
    load('spikeTimeCell.mat');
    load('emgCell.mat');

5. Run analysis:
    sdo_testing


This structure supports systematic comparisons across:

- Temporal parameter configurations  
- Neurons and muscles  
- Experimental conditions  
- Animals  

---
## Data Requirements

The analysis expects:

- xtData: Continuous signals (e.g., EMG envelope)
- ppData: Spike timestamp data

Data can be loaded from .mat files and structured into xtDataCell and ppDataCell objects before analysis.

---
# Example Workflow
    % Load data
    load('xtData.mat');
    load('ppData.mat');

    % Run analysis
    sdo_testing

The script performs:
- Parameter sweep over temporal shifts and durations
- SDO computation per condition
- Background normalization
- Bootstrap resampling
- Hierarchical result storage

---
# Output Structure

Results are stored in a hierarchical struct:

    frogStruct(f)
        .neurons(n)
            .muscles(m)
                .sdos(k)
                    .matrix
                    .background
                    .bootstrap
                    .peakValue
                    .isSignificant
                    .shift
                    .dura


This design enables scalable comparisons across:
- Temporal windows
- Neurons
- Muscles
- Experimental conditions

---
## Statistical Validation

Spike-specific effects are isolated using:

- Background transition modeling  
- Bootstrap resampling (≥100 iterations per condition)  
- Peak magnitude and variance-based thresholds  

These procedures reduce bias from baseline motor variability and ensure statistical robustness.

---

## Interpretation of SDO Matrices

High-intensity regions in an SDO matrix indicate spike-driven increases in transition probability between discrete motor states.

By analyzing:

- Peak transition magnitude  
- Distribution of significant transitions  
- Changes in transition structure  

we interpret neural control through a dynamical systems framework, where spikes reshape the underlying motor energy landscape.

---

## Reproducibility

All analyses are reproducible through:

- Parameterized temporal sweeps  
- Structured hierarchical result storage  
- Deterministic preprocessing and discretization  

The modular design allows extension to new datasets or experimental conditions with minimal modification.

---

## Research Applications

This toolkit supports research in:

- Computational neuroscience  
- Motor control modeling  
- Event-driven state-space analysis  
- Transition probability modeling  
- Neural-motor coupling studies  

---

## Technical Concepts

- Markov transition modeling  
- Bootstrap resampling  
- High-dimensional transition matrices  
- State-space discretization  
- Object-oriented MATLAB design  
- Hierarchical data structures  

---

## Author

Aiza Nygman  
Undergraduate Researcher – Computational Neuroscience  
Drexel University  

---

## Citation

If you use this repository in academic work, please provide appropriate attribution.
