# IB-AGC-V1
IB-AGC: Annual 25 km global live biomass carbon product from SMOS L-band passive microwave vegetation optical depth

The dataset is available at https://zenodo.org/records/15676177

The IB AGC dataset provides global aboveground biomass carbon (AGC) estimates for 2010-2020, derived from SMOS-IC L-band vegetation optical depth (L-VOD) using improved calibration methods and corrections for vegetation water effects. The accuracy assessments revealed that the IB L-VOD-derived AGC shows a very good spatial and temporal consistency with national forest inventory data and forest disturbance events, when compared to other mainstream satellite products. The dataset is stored in netCDF4 format and projected on the global cylindrical Equal-Area Scalable Earth Grid version 2.0 (EASE-Grid 2.0), with dimensions of 584 by 1388 and a grid resolution of 25 km. It includes eight layers, featuring the AGC density map and its associated uncertainty layer, representing the standard error of calibration. Additionally, a sub-product of total biomass carbon (AGC+BGC) density is provided, calculated using a ratio method. The associated uncertainty, derived via error propagation, accounts for calibration errors in AGC and the AGC-to-BGC ratio.

There are several main steps involved in deriving IB AGC from SMOS-IC L-VOD, including low-quality daily L-VOD data filtering, RWC correction, calibration, and preliminary evaluation:

L-VOD filtering process. The accuracy of L-VOD retrieval can be notably affected by factors such as topography, frozen surface conditions (e.g., ice and snow), the proportion of water bodies, and radio frequency interference (RFI). To ensure the reliability of AGC estimates derived from L-VOD, it is essential to filter out these potentially spurious observations.

L-VOD correction for RWC effects. To correct for the potential influence of RWC variations on monthly L-VOD changes, we adopted a simple multiplicative model as done in Yang et al. (2021).

Global AGC derived from L-VOD. Following previous studies (Fan et al., 2019; Yang et al., 2023), we converted SMOS L-VOD to AGC density using published biomass maps as benchmarks. To reduce dependence on a single benchmark, we collected six widely used biomass maps (GEDI, Saatchi, GlobBiomass, Spawn, Avitabile, and Baccini). For the calibration, we divided the world into three regions: the tropics (30° S–30° N), the Northern Hemisphere (30° N–90° N), and the Southern Hemisphere (90° S–30° S). Calibration functions were derived separately for each region using published equations and optimal coefficients. This process generated 34 calibration functions (18 for the tropics and 8 each for the Northern and Southern Hemispheres). The final IB AGC map was the mean of these 34 estimates, with uncertainty quantified using their standard deviation.

Evaluation of IB AGC. The accuracy assessments showed that IB AGC had a reasonably good spatial agreement with the LiDAR reference data (R² = 0.60). Moreover, when aggregated at the national level, IB AGC exhibited stronger consistency with long-term net changes from country-level forest inventory data (R² = 0.62) than other mainstream satellite products.

For more details, readers are referred to Li et al. (2025).
