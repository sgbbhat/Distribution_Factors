# Distribution_Factors
Code of the project Calculation of Distribution Factors - PTDF and LODF

Distribution factors are used mainly in security and contingency
analysis. They are used to approximately determine the impact of
generation and load on transmission flows. Power Transfer
Distribution Factor (PTDF) and Load Outage Distribution factor
(LODF) as two such factors which will give an insight on effects
of power generation and load. PTDF calculates a relative change
in power flow on a particular line due to a change in injection and
corresponding withdrawal at a pair of busses and LODF
calculates a redistribution of power in the system in case of an
outage. Goal of this project is to parallelize the calculations using
CUDA C on the GPU GTX 480.
