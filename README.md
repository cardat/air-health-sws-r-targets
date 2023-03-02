---
title: "Air-Health Scientific Workflow System based on R targets"
output: 
  html_document:
    toc: true
    toc_float: true
    toc_collapsed: false
    toc_depth: 3
    number_sections: true
    theme: readable
bibliography: references.bib
---

This is an R [targets](https://github.com/ropensci/targets) pipeline for environmental health impact assessment using air pollution as a case study. It has been developed on R 4.1.2 "Bird Hippie" and RStudio 2021.09.2 "Ghost Orchid". It requires R \>= 4.0.0 and access to CARDAT's Environment_General data storage folder on [Cloudstor](https://cloudstor.aarnet.edu.au/).

The structure and syntax of an R targets pipeline may be unfamiliar to you depending on your level of coding experience. Depending on your intended usage, some or all of the following may guide your understanding of the workflow. Links to further useful examples and documentation are provided in the references.

# Background

Health Impact Assessment's (HIA) of ambient air pollution can quantify the health impacts of current air pollution and the health benefits of policies, programmes, or projects to reduce air population. HIA's can make recommendations for decision-makers and stakeholders, with the aim of maximizing a proposal's positive health effects and minimizing its negative effects [@who]. A HIA also provides a way to engage with the public by producing meaningful numbers to quantify health effects of air pollution. The SWS R targets workflow is a tool for quantifying the impact on health for given air pollution policy intervention scenarios, illustrated by a WHO guideline case study.

# Theory and Methods

## Epidemiological study designs: source, sample and study populations

Fundamental concept underpinning all epidemiological research is the requirement to clearly define the source population, also known as the study base [@checkoway2007].

## Case definition

Mortality -- a special type of incidence in which the "event" is death rather than the occurrence of disease or injury.

## Relative risk, odds ratio and hazard ratio

### Relative Risk

Expressed as the ratio by which risk of mortality increases per given increase in air pollution level.

Relative risk (RR) for a unit change in pollution level is represented by the coefficient β, which is derived from empirical studies. For example, the WHO case study example uses a β coefficient from a pooled RR estimated from a meta-analysis of European and North American studies, as recommended by WHO. That is a RR of 1.062 (95% CI 1.041, 1.084) per 10-g/m3 increment in annual average PM2.5 exposures of people aged ≥30 years.

Relative risk is a function of the difference in pollution levels (x~1~ -- x~0~).

For any change in pollution level from x~0~ to x~1~, the relative risk is given by the formula:

$$
RR(x~1~ - x~0~) = exp(β*(x~1~ - x~0~)
$$

The pollution level x~1~ may be a target or cut-off level for which a policy or legislation is aiming, and it is likely to be lower than x~0~.

*Change in time -- temporal relationship can be determined*

### Odds Ratio

*Cross-sectional studies -- temporal relationship cannot be determined, hypothesis generating research questions*

As for a RR where ratio of two risks is taken for two separate groups -- ratio of two odds taken for two separate groups to produce an odds ratio (OR).

RR causality assumption -- when unable to conclude this use Odds Ratio.

Give example using Air Pollution study[^1]

[^1]: DJ highlighted - work on examples

### Hazard Ratio

Comparison of two hazards -- shows how quickly two survivorship curves diverge through comparison of the slopes of the curves. An HR of 1 indicates no divergence - within both curves, the likelihood of the event was equally likely at any given time. An HR not equal to 1 indicates that two events are not occurring at an equal rate, and the risk of an individual in one group is different than the risk of an individual in another at any given time interval [@george2020].

Give example using Air Pollution study[^2]

[^2]: DJ highlighted - work on examples

Used in survival analysis, a hazard ratio (HR) is the ratio of hazard rates corresponding to the conditions characterised by two distinct air pollution levels. *Hazard ratios differ from RRs and ORs in that RRs and ORs are cumulative over an entire study with a defined endpoint, whereas HRs represent instantaneous risk.*

Concerns rates of change

The hazard rate (H) at pollution level x~1~ are derived from those at level x~0~ by:

$$
H(x~1~) = RR(x~1~ -- x~0~)*h(x~0~)
$$

[Further information:]{.underline}

<https://www.cureus.com/articles/39455-whats-the-risk-differentiating-risk-ratios-odds-ratios-and-hazard-ratios>

<https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7515812/>

## The PAF (population attributable fraction)

The impact of any given exposure on public health is assessed by measuring its contribution to total disease incidence or mortality. Attributable risk and attributable fraction are the most important measurements of this impact.

Attributable risk (AR) is the rate (proportion) of a health outcome (disease or death) in exposed individuals, which can be attributed to the exposure. AR assesses, in absolute terms, how much greater the frequency of an outcome is among the exposed compared with the non-exposed. It is measured as the difference in the rates of an outcome among unexposed individuals (Iu) from the rates among those who have been exposed (I~e~), according to the formula [@faustini2020]:

$$
AR = I~e~ - I~u~
$$

The attributable fraction (AF) is the proportion of all cases (or overall incidence) that can be attributed to a specific exposure in a population as it combines relative risk and prevalence of exposure. It is the AR divided by the incidence risk in the exposed, according to the formula: AF = ((Ie -- Iu)/Ie). It gives an estimate of the proportion of cases that would not have occurred if exposure had been totally absent [@faustini2020a].

*"Attributable burden is the disease burden ascribed to a particular risk factor. It is the reduction in burden that would have occurred if exposure to the risk factor had been avoided or had been reduced to its lowest level. It is estimated by applying a population attributable fraction to the estimated disease burden for that linked disease.*

*The population attributable fractions (PAF) is the proportion of a particular disease that could have been avoided if the population had never been exposed to a risk factor. The calculation of PAFs requires as inputs the relative risk (the increased risk of developing or dying from the disease if exposed to the risk factor) and the prevalence of exposure to the risk factor in the population. PAFs can also be calculated directly from comprehensive data sources such as registries."* [@australianinstituteofhealthandwelfare2015].

## TMREL -- Theoretical minimum risk exposure level

Defined as the theoretical minimum exposure for which there is no increased risk of linked disease/death. These estimates reflect how much disease burden can be prevented if exposure in the population was at the theoretical minimum. This amount of exposure to the risk factor may not be achievable or feasible.

[Air pollution]{.underline}

-   In global burden of disease study - TMREL assigned a uniform distribution of 2.4 -- 5.9 µg/m³ for PM2·5 [@cohen2017].

-   Uniform distribution reflects uncertainty regarding the adverse effects of low-level exposure to air pollution

[CHECK THIS SECTION WITH DJ]{style="color:red"}

**1. Study Population and health outcomes**

**a. Source, sample and study population**

**2. Exposure assessment**

**a. Spatial modelling and dealing with coverage issues or missingness**

**b.Counterfactual**

Generalise from below info:

**Hanigan paper:**

Annual average PM~2.5~ concentrations were obtained from a validated satellite-based land-use regression (LUR) model, as described by Knibbs et al. [15]. The regression model uses satellite imagery, chemical-transport model (CTM) simulations and land-use data as predictors and incorporates direct PM~2.5~ measurements from ambient-air monitoring agencies in Australia [15]. The data are available on request from the Australian Centre for Air pollution, energy and health Research (CAR) <https://cloudstor.aarnet.edu.au/plus/f/2454567279>. The model was estimated for each mesh-block (MB), which is the smallest area in the Census geography

**Knibbs paper:**

Over the past decade, improvements in the spatiotemporal resolution of satellite-derived data have increased their utility for air pollution exposure assessment in epidemiological studies. Satellites have enabled exposure assessment to be extended to regions with few or no ground-based air quality monitors. However, despite these recent advances, the spatial resolution of most satellite instruments and processing algorithms may not fully capture local-scale, small-area (∼1 km or less) exposure contrasts within cities, which may be of interest in epidemiological studies.

One method for potentially improving the spatial resolution of PM2.5 estimates is to use geophysically derived estimates, obtained by relating satellite AOD to surface PM2.5 concentrations using chemical transport model (CTM) simulations, in land-use regression (LUR) models.

Australia -- relatively diverse sources and low concentrations of ambient fine particle matter (\<2.5 µm, PM~2.5~).

Knibbs et al -- evaluated a land-use regression model including global geophysical estimates of PM~2.5~, derived by relating satellite observed aerosol optical depth to ground-level PM~2.5~ ("SAT-PM~2.5~"). Found that SAT-PM~2.5~ estimates improved LUR model performance, while local land-use predictors increased the utility of global SAT-PM~2.5~ estimates, including enhanced characterization of within-city gradients. (7)

**3. Link population, health and environment data**

**a. Spatial and temporal issues**

**4. Attributable number**

**a. Life table**

[What is a life table?]{.underline}

-   A table describing the age structure of a real of hypothetical population, and the annual mortality within each age group.

-   Layout of a life table facilitates the prediction of life expectancy.

"Life table calculations produce as their output an estimate of age-specific life expectancy (i.e. average remaining life expressed in life years (LY)) at birth, and the remaining life expectancy conditional on having reached the start of each age group. These are a direct function of the ASDRs (also known as hazard rates) in the life table, and it follows that changes to the age-specific death rates (ASDRs) predict different life expectancies. This is the basis for estimating the impacts of changes in pollution levels; the epidemiological studies provide unit relative risks that can be applied to changes in mean pollution concentration values, and the resulting relative risks are applied to the ASDRs, and new mortality experience predicted."

# Run the pipeline: step-by-step guide

To run the Air Health SWS for the first time:

1. Download and unzip the [air-health-sws-r-targets](https://github.com/cardat/air-health-sws-r-targets) repository from the `Code` dropdown button. Alternatively, clone the repository via RStudio's `New Project > Version Control` dialogue or Git command line. 

2.  Load the R project. Open the `_targets.R` script.

- Edit the global variables `years` and `states` to set the study coverage. The present inputs cover states NSW, VIC, QLD, SA, WA, TAS, NT, ACT and years 2010-2015 inclusive.
- Set `download_data` to TRUE if you wish to download the required data via the [cloudstoR](https://github.com/pdparker/cloudstoR) package.
- Set `dir_cardat` to the parent directory of your mirrored Environment_General directory. (This is the destination of the download if `download_data` is `TRUE`.)

3.  Open the `main..R` script. (This is not integral to the targets pipeline but is a place to keep all the useful commands for visualising, running and exploring the pipeline outside of the pipeline itself.) Begin running the script line-by-line from the top.

-  `renv` should automatically install and activate. Install the packages using `renv::restore()` or try the alternative custom installation function `install_pkgs()` (installs the latest version if library not already available). Installation may take some time.
-  If you have set `download_data <- FALSE` in `_targets.R`, uncomment and run the lines at the top of the *Run pipeline* section to authenticate your `cloudstoR` package's access to Cloudstor.  You should not need to authenticate again unless your credentials have changed.
- Visualise the targets with `tar_glimpse()` or `tar_visnetwork()`, or get a table of targets with `tar_manifest()`.
- Run the pipeline with `tar_make()`.
- Continue on to visualise and run the pipeline.

4.  See the results of the desired target with`tar_read(target_name)`.

`_targets.R` and the custom functions called by targets (stored in R/) can be modified and extended to control pipeline output.
