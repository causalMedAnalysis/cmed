{smcl}
{* *! version 0.3.0  12oct2025}{...}
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
{synopt:{helpb cmed_simulate:{ul:sim}ulate}}generalized linear models,
estimated via simulation
{p_end}
{...}
{synopt:{helpb cmed_ipw:ipw}}inverse probability weighting
{p_end}
{...}
{synopt:{helpb cmed_impute:{ul:imp}ute}}regression imputation
{p_end}
{...}
{synopt:{helpb cmed_mr:mr}}multiply robust; 
de-biased machine learning
{p_end}
{...}
{synoptline}


{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed}
performs causal mediation analysis.


{...}
{marker references}{...}
{title:References}

{pstd}Wodtke GT, and Zhou X. Causal Mediation Analysis. In preparation. {p_end}


{...}
{marker support}{...}
{title:Support}

{pstd}
Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago

{pstd}
Email: wodtke@uchicago.edu
