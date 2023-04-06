# MINT (Mesh of Idealized Neural Trajectories)
This repository is the official implementation of MINT, a decode algorithm for brain-computer interfaces developed in the [Churchland lab](https://churchland.zuckermaninstitute.columbia.edu/). The method is described in detail in a preprint (submission to bioRxiv in process, will be available online within 24-48 hours):

**Perkins, S., Cunningham, J., Wang, Q., & Churchland, M. (2023). Simple decoding of behavior from a complicated neural manifold. *bioRxiv*.**

For convenience, the abstract is reproduced here:

> Decoders for brain-computer interfaces (BCIs) assume constraints on neural activity, chosen to reflect scientific beliefs while yielding tractable computations. We document how low tangling – a typical property of motor-cortex neural trajectories – yields unusual neural geometries. We designed a decoder, MINT, to embrace appropriate statistical constraints for these geometries. MINT takes a trajectory-centric approach: a library of neural trajectories (rather than a set of neural dimensions) provides a scaffold approximating the neural manifold. Each neural trajectory has a corresponding behavioral trajectory, allowing straightforward but highly nonlinear decoding. MINT outperformed other interpretable methods, and outperformed expressive machine learning methods in 37 of 42 comparisons. Yet unlike such methods MINT's constraints are known, not the implicit result of optimizing decoder output. MINT performed well across tasks, suggesting its assumptions are generally well-matched to the statistics of neural data. Despite embracing highly nonlinear relationships between behavior and potentially complex neural trajectories, MINT's computations are simple, scalable, and provide interpretable quantities such as data likelihoods. MINT's performance and simplicity suggest it may be an excellent candidate for clinical BCI applications.

## Getting Started
### Downloading Data
Navigate to the `data` directory and run the `download_data` script. This will automatically download three datasets: Area2_Bump, MC_Maze, and MC_RTT. 

Area2_Bump contains neural recordings from area2 of somatosensory cortex while a monkey uses a manipulandum to make center-out reaches or is perturbed outward by the manipulandum. MC_Maze contains neural recordings from M1 and PMd while a monkey makes delayed center-out curved and straight reaches. MC_RTT contains neural recordings from M1 while a monkey makes self-paced reaches in an 8x8 grid. More information on these datasets can be found in the paper or in [the repository for alternative decoders](https://github.com/seanmperkins/bci-decoders) that MINT is compared to in the paper.

### Running MINT
To get started, first refer to the 'Requirements' section below to ensure the necessary MATLAB toolboxes are installed. Then, simply execute the `run_decoder` script in the directory `run`. By default, this will run MINT on the Area2_Bump dataset, but you can modify which dataset you'd like to run in the script. To re-run with different hyperparameters, simply edit the config files in `run/+config` and re-execute `run_decoder`.

The implementation of MINT provided here is basic and intended to make it easy for a user to get up and running. There are variants on MINT described in the paper that are not implemented here, but they are fully documented in the methods section of the paper. In the interest of simplicity, we also did not include a hyperparameter optimization procedure in the code (though any suitable method could be easily inserted in the `train` function). However, the default values provided in the config files were taken directly from the paper and were optimized via grid searches with cross validation on the training sets.

## Repository Structure
### core
This directory contains all the essential code for implementing MINT. `@MINT` contains a class definition for creating a MINT object with a training method `fit` and decoding method `predict`. `estimation` contains functions related to estimating the most likely neural state and interpolating between states, `recursion` contains functions for implementing MINT's log-likelihood recursion as a MEX file to speed up execution, and `utils` contains functions related to binning data and managing indices.

`indexing` contains functions related to managing indices,  and `smoothing` contains functions related to binning/filtering spikes and smoothing rates across neurons, conditions, and/or trials.

### data
This directory contains a script for downloading the data. Once run, this directory will also contain the .mat files for the three example datasets.

### run
This directory contains data for actually running MINT on the datasets. `run_decoder` is the primary script for executing a run (i.e. loading data, training, testing, evaluating performance, and saving results). `utils` contains supporting functions for `run_decoder`. Each dataset requires its own config file to specify settings and hyperparameters. These are stored in the `+config` subdirectory. The `results` subdirectory (which is autogenerated the first time you run MINT) contains the results for each run. Each results file will contain the following variables:
| Variable |  Description |
| --- | --- |
| `behavior` | cell array (# trials x 1) where each cell contains an M x T matrix of ground truth behavioral variables |
| `behavior_estimate` | cell array (# trials x 1) where each cell contains an M x T matrix of decoded behavioral variables |
| `neural_state_estimate` | cell array (# trials x 1) where each cell contains an N x T matrix of neural state estimates in spikes/second |
| `R2` | vector of coefficients of determination for each decoded behavioral variable |
| `TrainSummary` | Structure with fields `HyperParams` and `behavior_labels`. `HyperParams` contains a variety of hyperparameters and settings related to the run. `behavior_labels` is a cell array of strings labeling each behavioral variable.|

where M is the number of behavioral variables, N is the number of neurons, and T is the number of time samples (typically milliseconds) in a trial.

### task-related
Although the core operations of MINT itself are stored in the `core` directory, there is task-specific code related to loading data and learning trajectories.  Thus, each task receives its own subdirectory (e.g. `+area2_bump`), containing three functions: `get_trial_data`, `preprocess_behavior`, and `fit_trajectories`. `get_trial_data` loads and formats each dataset. `preprocess_behavior` simply selects the behavioral variables we're interested in decoding, provides any basic preprocessing (like subtracting baseline position at movement onset), and labels behavioral variables for later reference. But the really important one is `fit_trajectories`, which determines how we learn the idealized neural trajectories and corresponding behavioral trajectories. This is something that will often be implemented differently for different tasks. For example, in some tasks we’ll just align to some trial event (e.g. movement onset) and then average across trials. In other tasks, we may need to dilate individual trials in time prior to averaging due to variability in task execution speed. In the MC_RTT dataset, we build the neural trajectories from single-trial rates estimated by AutoLFADS. Thus, when the main `fit` method is run, it actually calls a task-specific `fit_trajectories` function from one of these subdirectories. The `utils` subdirectory contains supporting functions that are re-used across `fit_trajectories` functions from different tasks.

## Requirements
This code was written in MATLAB R2021b. It will likely run with other versions, but this has not been tested. Code requires 'Signal Processing', 'Statistics and Machine Learning', and 'MATLAB Coder' toolboxes.

## Attributions
All three datasets used in this repository were curated and publicly released by the [Neural Latents Benchmark](https://neurallatents.github.io/) (NLB) team.

Area2_Bump was provided to the NLB team by Raeed Chowdhury and Lee Miller at Northwestern University. The full data set is available on [DANDI](https://dandiarchive.org/dandiset/000127) and more information about the data can be found in the journal article [Chowdhury et al. 2020](https://elifesciences.org/articles/48198).

MC_Maze was provided to the NLB team by Matt Kaufman, Mark Churchland, and Krishna Shenoy at Stanford University. The full data set is available on [DANDI](https://dandiarchive.org/dandiset/000128) and more information about the data can be found in the journal article [Churchland et al. 2010](https://pubmed.ncbi.nlm.nih.gov/21040842/).

MC_RTT was provided to the NLB team by Joseph O'Doherty and Philip Sabes at the University of California San Francisco. The full data set is available on [DANDI](https://dandiarchive.org/dandiset/000129) and more information about the data can be found in the journal article [Makin et al. 2018](https://iopscience.iop.org/article/10.1088/1741-2552/aa9e95).

## Copyright Notice
Protected by U.S. Pat. No. 11,429,847 and additional patents pending.

© 2023 The Trustees of Columbia University in the City of New York.

Use is subject to the terms of the License Agreement.

## Contact
Feel free to reach out to Sean with any questions at: sp3222 [at] columbia [dot] edu
