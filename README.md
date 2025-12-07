# cmed: A Stata Module for Analyzing Causal Mediation

## About 
`cmed` is a Stata module for implementing the methods described in [Causal Mediation Analysis](https://www.cambridge.org/us/universitypress/subjects/social-science-research-methods/quantitative-methods/causal-mediation-analysis) (Wodtke and Zhou Forthcoming, Cambridge University Press). This package is live and fully functional but also under active development to add new features, so functionality may change without notice. Please report any issues to causalmed (at) gmail (dot) com.

## Table of Contents

1. [Installation](#installation)  
2. [Overview](#overview)  
3. [General Syntax](#general-syntax)  
4. [Subcommands](#subcommands)  
   - [cmed linear](#1-cmed-linear)  
   - [cmed simulate](#2-cmed-simulate)  
   - [cmed ipw](#3-cmed-ipw)  
   - [cmed impute](#4-cmed-impute)  
   - [cmed mr](#5-cmed-mr)  
   - [cmed dml](#6-cmed-dml)  

---

## Installation

To install directly from GitHub:

```stata
net install cmed, from("https://raw.githubusercontent.com/causalMedAnalysis/cmed/main/")
````

---

## Overview

`cmed` is a comprehensive Stata package for causal mediation analysis, implementing a wide range of methods for a wide range of estimands. It can accommodate multiple mediators, exposure-induced confounders, and variables of many types (binary, ordinal, continuous, counts).

Supported causal effects include:

* **Natural direct and indirect effects through a single mediator**
* **Multivariate natural direct and indirect effects through multiple mediators**
* **Path-specific effects through multiple mediators**
* **Interventional direct and indirect effects**
* **Controlled direct effects**

Supported approaches to estimation include:

* **Linear modeling**
* **Simulation with generalized linear models**
* **Inverse probability weighting**
* **Regression imputation**
* **Multiply robust methods**
* **De-biased machine learning**

---

## General Syntax

At the top level, all commands follow:

```stata
cmed subcommand ...
```

where `subcommand` is one of:

* `linear` – linear models for mediator(s) and outcome
* `simulate` – generalized linear models, effects estimated via simulation
* `ipw` – inverse probability weighting
* `impute` – regression imputation
* `mr` – multiply robust estimation
* `dml` – de-biased machine learning

---

## Subcommands

Each subcommand is summarized below.

---

# 1. cmed linear

Causal mediation analysis using **linear models** for mediator(s) and outcome.

## Basic syntax

### Natural effects through a single mediator

```stata
cmed linear depvar mvar dvar [= cvars] [if] [in] [, options]
```

### Multivariate natural effects through multiple mediators

```stata
cmed linear depvar (mvars) dvar [= cvars] [if] [in] [, options]
```

### Path-specific effects through multiple mediators

```stata
cmed linear depvar (mvars) dvar [= cvars] [if] [in] , paths [options]
```

### Interventional effects through a single mediator with post-treatment confounders

```stata
cmed linear depvar mvar (lvars) dvar [= cvars] [if] [in] [, options]
```

### Controlled direct effects with a single mediator

```stata
cmed linear depvar mvar [(lvars)] dvar [= cvars] [if] [in] , mvalue(#) [options]
```

---

# 2. cmed simulate

Causal mediation analysis using **generalized linear models (GLMs)** and **simulation**.

## Basic syntax

### Natural effects through a single mediator

```stata
cmed simulate (yspec) ([ (mmodel) ] mvar) dvar [= cvars] [if] [in] [, options]
```

### Multivariate natural effects through multiple mediators

```stata cmed simulate (yspec) (mspec) dvar [= cvars] [if] [in] [, options]
```

### Path-specific effects through multiple mediators

```stata cmed simulate (yspec) (mspec) dvar [= cvars] [if] [in] , paths [options]
```

### Interventional effects through a single mediator with post-treatment confounders

```stata
cmed simulate (yspec) ([ (mmodel) ] mvar) (lspec) dvar [= cvars] [if] [in] [, options]
```

### Controlled direct effects with a single mediator and post-treatment confounders

```stata
cmed simulate (yspec) mvar (lspec) dvar [= cvars] [if] [in] , mvalue(#) [options]
```

where 

* `yspec` is `[(ymodel)] depvar`
* `mspec` is `[(mmodel)] mvars [ (mmodel) mvars ] ...`
* `lspec` is `[(lmodel)] lvars [ (lmodel) lvars ] ...`

and the model types are `regress`, `logit`, `poisson`, or `ologit`.

---

# 3. cmed ipw

Causal mediation analysis using **inverse probability weighting**.

## Basic syntax

### Natural effects through a single mediator

```stata
cmed ipw depvar mvar dvar [= cvars] [if] [in] [, options]
```

### Multivariate natural effects through multiple mediators

```stata
cmed ipw depvar (mvars) dvar [= cvars] [if] [in] [, options]
```

### Path-specific effects through multiple mediators

```stata
cmed ipw depvar (mvars) dvar [= cvars] [if] [in] , paths [options]
```

### Interventional effects through a single mediator with a discrete post-treatment confounder

```stata
cmed ipw depvar ([ (mmodel) ] mvar) ((lmodel) lvar) dvar [= cvars] [if] [in] [, options]
```

### Controlled direct effects with a single mediator

```stata
cmed ipw depvar ([ (mmodel) ] mvar) [(lvars)] dvar [= cvars] [if] [in] , mvalue(#) [options]
```

---

# 4. cmed impute

Causal mediation analysis using **regression imputation**.

## Basic syntax

### Natural effects through a single mediator, pure regression imputation

```stata
cmed impute ([(ymodel)] depvar) mvar dvar [= cvars] [if] [in] [, options]
```

### Multivariate natural effects through multiple mediators, pure regression imputation

```stata
cmed impute ([(ymodel)] depvar) (mvars) dvar [= cvars] [if] [in] [, options]
```

### Path-specific effects through multiple mediators, pure regression imputation

```stata
cmed impute ([(ymodel)] depvar) (mvars) dvar [= cvars] [if] [in] , paths [options]
```

### Natural effects, imputation-based weighting

```stata
cmed impute ([(ymodel)] depvar) (mvars) ((logit) dvar) [= cvars] [if] [in] [, options]
```

### Path-specific effects, imputation-based weighting

```stata
cmed impute ([(ymodel)] depvar) (mvars) ((logit) dvar) [= cvars] [if] [in] , paths [options]
```

### Controlled direct effects with a single mediator

```stata
cmed impute ([(ymodel)] depvar) mvar dvar [= cvars] [if] [in] , mvalue(#) [options]
```

where

`ymodel` is `regress` (default) or `logit`.

---

# 5. cmed mr

Causal mediation analysis using **multiply robust** estimation.

## Basic syntax

### Natural effects through a single mediator

(logit models for treatment, linear models for outcome)

```stata
cmed mr depvar mvar dvar [= cvars] [if] [in] [, options]
```

### Natural effects through a single binary mediator

(logit models for treatment and mediator, linear model for outcome)

```stata
cmed mr depvar mvar dvar [= cvars] [if] [in] , rmpw [options]
```

### Multivariate natural effects through multiple mediators

```stata
cmed mr depvar (mvars) dvar [= cvars] [if] [in] [, options]
```

### Path-specific effects through multiple mediators

```stata
cmed mr depvar (mvars) dvar [= cvars] [if] [in] , paths [options]
```

---

# 6. cmed dml

Causal mediation analysis using **de-biased machine learning** (random forests or LASSO).

## Basic syntax

### Natural effects through a single mediator

```stata
cmed dml depvar mvar dvar [= cvars] [if] [in] , method(method) [options]
```

### Multivariate natural effects through multiple mediators

```stata
cmed dml depvar (mvars) dvar [= cvars] [if] [in] , method(method) [options]
```

### Path-specific effects through multiple mediators

```stata
cmed dml depvar (mvars) dvar [= cvars] [if] [in] , method(method) paths [options]
```

where `method` is `rforest` or `lasso`.

---

# Identification Assumptions

Across subcommands, interpretting the estimated effects causally typically relies on some or all of:

* **A1:** No unobserved treatment–outcome confounders
* **A2:** No unobserved mediator–outcome confounders
* **A3:** No unobserved treatment–mediator confounders
* **A4:** No exposure-induced confounders of the mediator–outcome relationship

The different estimators also impose modeling assumptions. See help files for details.
