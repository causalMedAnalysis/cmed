{smcl}
{* *! version 0.4.1  04dec2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{viewerjumpto "Syntax" "cmed##syntax"}{...}
{viewerjumpto "Description" "cmed##description"}{...}
{viewerjumpto "References" "cmed##references"}{...}
{viewerjumpto "Support" "cmed##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed} {hline 2} Causal mediation analysis


{...}
{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:cmed} 
{it:subcommand}
{it:...}


{...}
{synoptset 16}{...}
{synopthdr:subcommand}
{synoptline}
{...}
{synopt:{helpb cmed_linear:{ul:lin}ear}}linear models 
for mediator(s) and outcome
{p_end}
{...}
{synopt:{helpb cmed_simulate:{ul:sim}ulate}}generalized linear 
models, effects estimated via simulation
{p_end}
{...}
{synopt:{helpb cmed_ipw:ipw}}inverse probability weighting
{p_end}
{...}
{synopt:{helpb cmed_impute:{ul:imp}ute}}regression imputation
{p_end}
{...}
{synopt:{helpb cmed_mr:mr}}multiply robust estimation
{p_end}
{...}
{synopt:{helpb cmed_dml:dml}}de-biased machine learning
{p_end}
{...}
{synoptline}


{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed}
performs causal mediation analysis using methods discussed in 
{help cmed##references:Wodtke and Zhou (2026)}. It supports estimation of 
natural, interventional, controlled, and path-specific effects, which
capture in different ways how the effect of a treatment on an outcome is
transmitted, or not, through one or more mediators. The command can handle
multiple mediators, exposure-induced confounders, and many different types 
of variables, including measures that are binary, ordinal, continuous, or 
counts. Across its different subcommands, {cmd:cmed} supports estimation using 
linear models, generalized linear models and simulation methods, 
inverse probability weighting, regression imputation, multiply robust
methods that combine weighting and imputation, and de-biased machine learning.


{...}
{marker references}{...}
{title:References}

{pstd}
Wodtke GT, and Zhou X. 2026. {browse "https://www.cambridge.org/us/universitypress/subjects/social-science-research-methods/quantitative-methods/causal-mediation-analysis":Causal Mediation Analysis}. Cambridge University Press.
{p_end}


{...}
{marker support}{...}
{title:Support}

{pstd}
Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{break}
Email: wodtke@uchicago.edu
