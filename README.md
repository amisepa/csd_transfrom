# Current-source density (CSD) transformation / Surface Laplacian
Convert EEG data to reference-free current-source density (CSD) transformed data (i.e., surface Laplacian). 

## Requirements

- MATLAB installed
- EEGLAB installed
- Some EEG data


## Usage

1) Clone (or download + unzip) this repository

3) Add path to matlab (or move folder into eeglab > plugins)

5) Launch EEGLAB

7) Load EEG data into EEGLAB

8) Load your EEG channel locations

9) Type in command window:

```EEG = csd_transform(EEG);```

## Comparison with conventional referencing methods

Here is a comparison of ERP between emotional and neutral stimuli for each method to assess how the referencing method affects statistical results at the group level (N = 81; p<0.01 after spatiotemporal cluster-correction). This illustrates well how CSD-transformation increases spatial resolution and helps highlight local dynamics, whereas AV- and REST- referenced data increase global dynamics. 

Reference to Average (left), Infinity (middle), and Surface Laplacian transformation (right)

![figures_merged](https://github.com/amisepa/csd_transfrom/assets/58382227/8430f169-0d7f-49df-8c53-3818cd8e0eab)


## Literature

Nunez, P. L., Silberstein, R. B., Cadusch, P. J., Wijesinghe, R. S., Westdorp, A. F., & Srinivasan, R. (1994). A theoretical and experimental study of high resolution EEG based on surface Laplacians and cortical imaging. Electroencephalography and clinical neurophysiology, 90(1), 40-57.

https://www.sciencedirect.com/science/article/abs/pii/0013469494901120

Tandonnet, C., Burle, B., Hasbroucq, T., & Vidal, F. (2005). Spatial enhancement of EEG traces by surface Laplacian estimation: comparison between local and global methods. Clinical neurophysiology, 116(1), 18-24.

https://www.sciencedirect.com/science/article/abs/pii/S1388245704002676

Carvalhaes, C., & De Barros, J. A. (2015). The surface Laplacian technique in EEG: Theory and methods. International Journal of Psychophysiology, 97(3), 174-188.

https://www.sciencedirect.com/science/article/abs/pii/S0167876015001749

Kayser, J., & Tenke, C. E. (2015). Issues and considerations for using the scalp surface Laplacian in EEG/ERP research: A tutorial review. International Journal of Psychophysiology, 97(3), 189-209.

https://www.sciencedirect.com/science/article/abs/pii/S0167876015001609

Kayser, J., & Tenke, C. E. (2015). On the benefits of using surface Laplacian (current source density) methodology in electrophysiology. International journal of psychophysiology: official journal of the International Organization of Psychophysiology, 97(3), 171.

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4610715/
