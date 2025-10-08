---
title: Neural Network Modeling of Ionospheric F2-Layer Electrodynamics
date: 2018-05-05
status: past
tags: ["ionosphere", "machine learning", "neural networks", "space weather"]
cover: /images/2017-05-msc-ionospheric-nn/figure-1-global.png
coverCaption: >
  Spatial (longitude–latitude) distributions of NmF2 (left) and hmF2 (right)
  simulated using an ANN-based global 3D ionospheric model under quiet (Kp = 2)
  and disturbed (Kp = 9) conditions. [Source: Tulasi Ram et al. (2018), Fig. 10]
links:
  - label: MSc Thesis (PDF)
    href: https://github.com/mitraarka27/Master-sThesis/blob/main/Mitra_MS_Thesis.pdf
  - label: ANNIM-2D (JGR 2018)
    href: https://doi.org/10.1029/2018JA025559
  - label: ANNIM-3D (JGR 2019)
    href: https://doi.org/10.1029/2019JA026540
abstract: >
  This project developed one of the earliest neural-network–based ionospheric models capable of predicting global F2-layer peak density (NmF2) and peak height (hmF2) from long-term satellite and ground-based measurements. The work demonstrated that machine-learning approaches can replicate large-scale ionospheric electrodynamics traditionally captured only by empirical or physics-based models.
---

## Context & Motivation

The high-latitude ionosphere is a dynamic plasma environment controlled by **solar EUV radiation, geomagnetic forcing, and neutral wind circulation**. Accurate estimates of **NmF2** (peak electron density) and **hmF2** (corresponding altitude) are essential for **radio communication forecasting, satellite navigation accuracy, and space weather nowcasting**.

Traditional ionospheric models fall into two camps:

- **Physics-based models** (e.g., [TIEGCM](https://doi.org/10.1029/93RS01510), [SAMI2/SAMI3](https://ccmc.gsfc.nasa.gov/models/modelinfo.php?model=SAMI3)) that solve continuity and momentum equations.
- **Empirical models** (e.g., [IRI](https://doi.org/10.1029/95RS01548), [NeQuick](https://www.itu.int/en/ITU-R/software/Pages/nequick.aspx)) that fit climatological data using analytical functions.

However, both approaches struggle with **nonlinear responses to geomagnetic storms, solar minima, and [Equatorial Ionization Anomaly](https://en.wikipedia.org/wiki/Equatorial_Electrojet)**. With the advent of large-scale **radio occultation (RO) datasets from [FORMOSAT-3/COSMIC](https://cdaac-www.cosmic.ucar.edu/cdaac/), [CHAMP](https://earth.esa.int/eogateway/missions/champ), [GRACE](https://www.nasa.gov/missions/gravity-recovery-and-climate-experiment-grace/)**, and **global [Digisonde GIRO network](https://giro.uml.edu/)**, machine learning offered a viable alternative.

This project explored that possibility.

## Approach / Methods

The core methodology was a **feed-forward artificial neural network (ANN)** trained to map observed and modeled ionospheric conditions, magnetic fields, solar activity, and winds to NmF₂ and hₘF₂.

<figure class="mt-6">
  <img src="/images/2017-05-msc-ionospheric-nn/figure-2-model.png" alt="Neural network architecture" class="rounded-2xl" />
  <figcaption class="text-sm text-zinc-500 mt-2 text-center">
    <em>Architecture of the feed-forward neural network used in artificial neural network-based global three-dimensional ionospheric model. DOY = day of the year; UT = universal time. [Source: Tulasi Ram et al. (2018), Fig. 2]</em>
  </figcaption>
</figure>

**Key elements:**

- **Input Data Sources**
  - GPS-RO from **[COSMIC](https://cdaac-www.cosmic.ucar.edu/cdaac/), [CHAMP](https://earth.esa.int/eogateway/missions/champ), [GRACE](https://www.nasa.gov/missions/gravity-recovery-and-climate-experiment-grace/)**
  - **[Digisonde GIRO network](https://giro.uml.edu/)** (confidence ≥ 90)
  - *(Later extensions incorporated topside sounders – see ANNIM-3D)*

- **Architecture**
  - Single hidden layer with **40 neurons**
  - **Levenberg–Marquardt** backpropagation (fast convergence)
  - **70% training / 15% validation / 15% testing**

- **Two Training Paradigms** (tested in thesis)
  - **Single global network** → underfit regional structures
  - **Gridded neural networks** → one ANN per **5° dip-lat × 15° longitude** patch

- **Physics-aware augmentation**
  - Neutral **zonal/meridional winds from HWM-14**
  - **IGRF magnetic field parameters** (declination, inclination)

## Key Results & Findings

- Reproduced **diurnal and seasonal variations** of NmF2/hmF2.  
- Captured **Equatorial Ionization Anomaly (EIA)**, **annual anomaly**, **Weddell Sea anomaly**.  
- **Improved representation of postsunset hmF2 enhancement** in equatorial regions *(first reported in later ANNIM-2D upgrades)*.  
- Demonstrated that **machine learning can distinguish solar irradiance vs geomagnetic forcing** through controlled ANN simulations.

<figure class="mt-6">
  <img src="/images/2017-05-msc-ionospheric-nn/figure-3-enhancement.png" alt="Dip latitude variation and spectral analysis" class="rounded-2xl" />
  <figcaption class="text-sm text-zinc-500 mt-2 text-center">
    <em>Dip latitude variation of zonally averaged day time (a) NmF2 and (b) hmF2 as a function of day number and the corresponding [Lomb–Scargle periodogram](https://en.wikipedia.org/wiki/Lomb%E2%80%93Scargle_periodogram) of (c) NmF2 and (d) hmF2. The superimposed black curves in left panels indicate the daily averaged [Kp-index](https://en.wikipedia.org/wiki/K-index). The white curves in right panels indicate the periodogram of daily averaged Kp-index. [Source: Gowtham et al. (2019), Fig. 7]</em>
  </figcaption>
</figure>

## Implications / Applications

- Demonstrated **feasibility of data-driven space weather forecasting**.  
- Formed **the foundational prototype** for the **[ANNIM-2D](https://doi.org/10.1029/2018JA025559)** (JGR 2018) and **[ANNIM-3D](https://doi.org/10.1029/2019JA026540)** models used in later publications.  
- Provided a **generalizable recipe** for **physics-informed neural networks in geospace modeling**.

## Further Reading

- Tulasi Ram et al. (2018), *The Improved Two‐Dimensional Artificial Neural Network‐Based Ionospheric Model*, **JGR Space Physics**.  
- Gowtam et al. (2019), *A New ANN-Based Global Three-Dimensional Ionospheric Model*, **JGR Space Physics**.  
- Mitra, A. (2018), *MSc Thesis: A Study of Extensive Radio Occultation Data...*, [PDF](https://github.com/mitraarka27/Master-sThesis/blob/main/Mitra_MS_Thesis.pdf).
