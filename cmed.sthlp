{smcl}
{* *! version 0.5.1  04jan2026}{...}
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

{p 5 8 2}
Basic syntax

{p 8 16 2}
{cmd:cmed} 
{it:{help cmed##subcommands:subcommand}}
{it:{help cmed##vars:depvar}}
{it:{help cmed##vars:mvar}}
[{it:{help cmed##vars:lvar}}]
{it:{help cmed##vars:dvar}}
[{cmd:=} {it:{help cmed##vars:cvars}}]
{ifin}
[{cmd:,} {it:options}]

{p 5 8 2}
Full syntax

{p 8 16 2}
{cmd:cmed} 
{it:{help cmed##subcommands:subcommand}}
{cmd:(}{it:{help cmed##varspec:yspec}}{cmd:)}
{cmd:(}{it:{help cmed##varspec:mspec}}{cmd:)}
[{cmd:(}{it:{help cmed##varspec:lspec}}{cmd:)}]
{cmd:(}{it:{help cmed##varspec:dspec}}{cmd:)}
[{cmd:=} {it:{help varlist:cvars}}]
{ifin}
[{cmd:,} {it:options}]


{...}
{marker subcommands}{...}
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
{marker vars}{...}
{phang}
{it:{help depvar}} is the outcome of interest.
{p_end}
{phang}
{it:{help varname:mvar}} is a mediator of interest. 
Multiple mediators must be enclosed in parentheses.
{p_end}
{phang}
{it:{help varname:lvar}} is a post-treatment confounder (exposure-induced confounder).
Multiple post-treatment confounders must be enclosed in parentheses.
{p_end}
{phang}
{it:{help varname:dvar}} is the treatment (exposure).
{p_end}
{phang}
{it:{help varlist:cvars}} are baseline confounders (pre-treatment confounders).
{p_end}

{...}
{marker varspec}{...}
{phang}
{it:yspec} is [{cmd:(}{it:ymodel}{cmd:)}] {it:{help depvar}}
{p_end}
{phang}
{it:mspec} is [{cmd:(}{it:mmodel}{cmd:)}] {it:{help varlist:mvars}} 
[{cmd:(}{it:mmodel}{cmd:)} {it:{help varlist:mvars}} {it:...}]
{p_end}
{phang}
{it:lspec} is [{cmd:(}{it:lmodel}{cmd:)}] {it:{help varlist:lvars}} 
[{cmd:(}{it:lmodel}{cmd:)} {it:{help varlist:lvars}} {it:...}]
{p_end}
{phang}
{it:dspec} is [{cmd:(}{cmd:logit}{cmd:)}] {it:{help varname:dvar}}
{p_end}

{...}
{phang}
{it:ymodel}, {it:mmodel}, and {it:lmodel} are 
{it:subcommand}-specific 
and one of
{cmdab:reg:ress}, 
{cmd:logit}, 
{cmd:poission}, 
or
{cmd:ologit}.
{p_end}


{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed}
performs causal mediation analysis 
using the methods discussed in {help cmed##references:Wodtke and Zhou (2026)}. 
The command supports estimation of natural, interventional, controlled direct, 
and path-specific effects, which capture in different ways how the effect 
of a treatment on an outcome is transmitted, or not, through one or more mediators. 
The command handles multiple mediators, exposure-induced confounders, 
and different variable types, including binary, ordinal, continuous, 
and count measures. 
Across its subcommands, {cmd:cmed} provides estimators based on  
linear models, generalized linear models and simulation methods, 
inverse probability weighting, regression imputation, multiply robust
methods that combine weighting and imputation, and de-biased machine learning.


{...}
{marker references}{...}
{title:References}

{pstd}
Wodtke GT, and Zhou X. 2026. 
{browse "https://www.cambridge.org/us/universitypress/subjects/social-science-research-methods/quantitative-methods/causal-mediation-analysis":Causal Mediation Analysis}. 
Cambridge University Press.
{p_end}


{...}
{marker support}{...}
{title:Support}

{pstd}
Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{break}
Email: wodtke@uchicago.edu

{pstd}
Daniel Klein{break}
German Centre for Higher Education Research and Science Studies{break}
Email: klein@dzhw.eu
