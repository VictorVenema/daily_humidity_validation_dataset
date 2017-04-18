Manual Matlab software to generate validation data

This document is a short manual to help installing and running the Matlab software used to generate validate data for the homogenisation of daily humidity station data. The scientific background can be found in the corresponding article:

Barbara Chimani, Victor Venema, Annemarie Lexer, Konrad Andre, Ingeborg Auer, Johanna Nemec, 2017: Intercomparison of methods to homogenise daily relative humidity. Submitted. 

The software has a GLP-3.0. If you use this software, please cite the article.

The software performs four main steps:
1. Generate surrogate data based on measured humidity data.
2. Add long-term variability to generate the “homogeneous” data from this surrogate data.
3. Insert missing data.
4. Add inhomogeneities to the homogeneous data.

These steps are also reflected in the directory structure. The measurement data the surrogates are based on to be found in the zip file: Netzwerke_Metainformation.zip. Please unzip it to the directory where the code expects it to be:
/data/zamg_humidity/Netzwerke_Metainformation/

To generate a new validation dataset, you need to download all Matlab function to a new directory and call the following “generate” functions. 

1. The measurement data is used to generate surrogate data. After calling the function to generate the surrogates, generate_surrogate_zamg.m, the surrogate data can be found in:
/data/zamg_humidity/Surrogate/

2. After adding the long-term variability with the function generate_homogeneous_data_zamg_additive.m the homogeneous data can be found in:
/data/zamg_humidity/Homogeneous/

3. There are two functions to generate the two versions of inhomogeneous data, generate_idealised_error_reference.m and generate_realistic_error_reference.m. They also insert the missing data in the realistic dataset and store this version of the data in:
/data/zamg_humidity/Reference/deterministic/
/data/zamg_humidity/Reference/realistic/
The “deterministic” dataset is called “idealised” in the article. It does not contain missing data, but for symetry still a dataset in /Reference is created. The software also produces a dataset called “stochastic”. It has the same statistical properties as “realistic”, but does not have missing data.

After inserting the inhomogeneities the data can be found in:
/data/zamg_humidity/Inhomogeneous/deterministic/
/data/zamg_humidity/Inhomogeneous/realistic/

You will have to create these main data directories. The subdirectories will be created automatically. The software was written for a Linux directory system, but should also work under Windows. In this case the names of the directories at the top of the generate function will need to be changed to Windows directories. 

Coding conventions
Variable and function names are normally self-explanatory. Variable names consisting of multiple words are combined using CamelCase. Function names consisting of multiple words are combined using underscores. 

Sometimes a line
a=0; %#ok<NASGU>
Is inserted to be able to set a breakpoint.

Some comments have been added afterwards and the code has been cleaned, but some lines that were commented out were retained in case the user may want to uncomment them to see what the code does. 


