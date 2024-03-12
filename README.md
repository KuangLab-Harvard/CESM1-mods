# CESM1-mods

SourceMods changes used by the Kuang group for running CESM1 for various projects. 

Includes:
- TwinCRM: SourceMods for running two CRM copies in SPCAM, used in Sarah Weidman and Zhiming Kuang. 10/28/2023. “Potential predictability of the Madden-Julian Oscillation in a superparameterized model.” Geophysical Research Letters, 50, 21, Pp. [e2023GL105705](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2023GL105705)
- Replay: SourceMods for implementing a replay to reanalysis in CAM, similar to the procedure in GEOS. Implemented by Ned Kleiner, 2023. Can output 6-hr U,V,Q,T tendencies between CAM and the reanalysis of choice. 
- Corrector: SourceMods for using the (smoothed and averaged) tendencies output by the Replay method to "correct" CAM towards reanalysis, similar to the procedure in GEOS. Implemented by Ned Kleiner, 2023. 
