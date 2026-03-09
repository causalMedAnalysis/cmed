{smcl}
{* *! version 0.5.1  09mar2026}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_mr##syntax"}{...}
{viewerjumpto "Description" "cmed_mr##description"}{...}
{viewerjumpto "Options" "cmed_mr##options"}{...}
{viewerjumpto "Examples" "cmed_mr##examples"}{...}
{viewerjumpto "Stored results" "cmed_mr##results"}{...}
{viewerjumpto "References" "cmed_mr##references"}{...}
{viewerjumpto "Support" "cmed_mr##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed mr} {hline 2} {...}
Causal mediation analysis using multiply robust estimation


{...}
{*  __________________________________________________________  Syntax }{...}
{...}
{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Natural effects through a single mediator, logit models for treatment, 
linear models for outcome

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Natural effects through a single binary mediator, logit models for treatment 
and mediator, linear model for outcome

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} {opt rmpw} [{it:options}]


{pstd}
Multivariate natural effects through multiple mediators, logit models for 
treatment, linear models for outcome

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Path-specific effects through multiple mediators, logit models for 
treatment, linear models for outcome

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt paths:pecific} 
[{it:options}]


{...}
{phang}
{it:depvar}
is the outcome of interest.
{p_end}
{...}
{phang}
{it:mvar} 
is a mediator of interest.
{p_end}
{...}
{phang}
{it:dvar} 
is a binary treatment (exposure). 
{p_end}
{...}
{phang}
{it:cvars}
are baseline confounders (pre-treatment confounders).
{p_end}


{...}
{*  ___________________________________________________  Options short }{...}
{...}
{...}
{synoptset 24 tabbed}{...}
{synopthdr:options}
{synoptline}
{...}
{syntab:Effects}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{opt d(#)}}specify alternative level of {it:dvar}; 
default is 1.
{p_end}
{...}
{synopt:{opt dstar(#)}}specify reference level of {it:dvar}; 
default is 0.
{p_end}

{syntab:Models}
{synopt:{opt nointer:action}}do not include interaction(s) 
between mediator(s) and treatment in all relevant models
{p_end}
{...}
{synopt:{opt cxd}}include interactions between baseline confounders 
(if specified) and treatment in all relevant models
{p_end}
{...}
{synopt:{opt cxm}}include interactions between baseline confounders 
(if specified) and mediator(s) in all relevant models
{p_end}
{...}
{synopt:{cmd:censor(}{it:#1} {it:#2}{cmd:)}}censor inverse probability 
and/or ratio-of-mediator-probability weights  
at the {it:#1}th and {it:#2}th percentiles
{p_end}
{synopt:{opt rmpw}}use an estimator that involves 
ratio-of-mediator-probability weighting
{p_end}

{syntab:Bootstrap}
{synopt:{opt r:eps(#)}}perform {it:#} bootstrap replications; 
default is {cmd:reps(50)}
{p_end}
{...}
{synopt:{cmd:seed(}{it:#}{c |}{it:{help numlist}}{cmd:)}}set random number seed to {it:#}; 
when {opt parallel} is specified, supply one seed per processor 
{p_end}
{...}
{synopt:{opt parallel}}parallelize the bootstrap using {helpb parallel bs};
requires community-contributed {cmd:parallel} 
from {browse "https://github.com/gvegayon/parallel":GitHub} 
{p_end}
{...}
{synopt:{opt svy}}perform nonparametric bootstrap 
using adjusted bootstrap replicate weights; 
see {helpb svy_bootstrap:[SVY] svy bootstrap}
{p_end}
{...}
{synopt:{it:{help bootstrap##options:bootstrap_options}}}options are passed through 
to {helpb bootstrap}
{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; 
default is {cmd:level(}{cmd:{ccl level})}
{p_end}
{...}
{synopt:{opt detail}}print fitted models to compute effect estimates.
{p_end}
{synoptline}


{...}
{*  ____________________________________________________  Description }{...}
{...}
{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed mr} estimates the natural direct and indirect effects
of a binary treatment (exposure) on an outcome using multiply robust methods. 
When multiple mediators are specified, 
the command estimates multivariate natural effects 
and, optionally, path-specific effects 
through a set of causally ordered mediators. 
Standard errors and confidence intervals are obtained 
using the nonparametric bootstrap; see {manlink R bootstrap}. 

{pstd}
In the simplest case with a single mediator,
{cmd:cmed mr} 
estimates the natural direct, indirect, and total effects
of a binary treatment using multiply robust methods by fitting the following models:

{phang2}
(1) a logit model for the treatment 
with the baseline confounders as predictors
{p_end}
{phang2}
(2) another logit model for the treatment 
with the mediator and baseline confounders as predictors
{p_end}
{phang2}
(3) a linear model for the outcome 
with the treatment, mediator, and baseline confounders as predictors
{p_end}
{phang2}
(4) a linear model for a set of predicted values from Model (3)
with the treatment and baseline confounders as predictors
{p_end}

{pstd}
These models are used to construct the nuisance components 
of a multiply robust estimator, 
which is then evaluated to obtain the estimates of interest. 
The estimator combines inverse probability weighting and regression imputation. 
It is sometimes called "triply robust" 
because it offers three distinct ways to satisfy its modeling assumptions.

{pstd}
The estimated effects have a causal interpretation 
provided that at least one of the following three conditions is met: 

{phang2}
{bind:  }({it:i}) Models (1) and (2) are correctly specified
{p_end}
{phang2}
{bind: }({it:ii}) {bf:or} Models (1) and (3) are correctly specified
{p_end}
{phang2}
({it:iii}) {bf:or} Models (3) and (4) are correctly specified
{p_end}

{pstd}
Beyond the modeling requirements ({it:i})-({it:iii}) above, 
the following assumptions must hold:

{phang2}
({bf:A1}) There are no unobserved treatment–outcome confounders.
{p_end}
{phang2}
({bf:A2}) There are no unobserved mediator–outcome confounders.
{p_end}
{phang2}
({bf:A3}) There are no unobserved treatment–mediator confounders.
{p_end}
{phang2}
({bf:A4}) There are no post-treatment confounders of the mediator–outcome
relationship.
{p_end}

{pstd}
When more than one mediator is specified, 
{cmd:cmed mr} estimates multivariate natural direct and indirect effects 
by including all mediators as predictors in Models (2) and (3) above. 
These estimated effects have a causal interpretation 
provided that the modelling conditions ({it:i})-({it:iii}) are met, 
assumption {bf:A1} holds and assumptions {bf:A2}-{bf:A4} hold 
with respect to all mediators under consideration. 

{pstd}
When option {helpb cmed_mr##pathspecific:pathspecific} is specified, 
{cmd:cmed mr} estimates path-specific effects of multiple mediators. 
To have a causal interpretation, these estimates additionally require 
that the mediators are specified in reverse causal order, 
such that the first mediator listed is the final mediator in the causal sequence,
followed by the next-to-last mediator, and so on. 
In addition, there must be no unobserved or post-treatment confounders 
of any mediator–mediator relationship.

{pstd}
For a single binary mediator, option {opt rmpw} 
implements a different multiply robust estimator 
that combines ratio-of-mediator-probability weighting and regression imputation 
by fitting Models (1) and (3) above. Additionally, {cmd:cmed mr} fits
a logit model for the (binary) mediator 
with the treatment and baseline confounders as predictors. 
The estimated effects have a causal interpretation 
provided that at least two of the models are correctly specified 
and assumptions {bf:A1}–{bf:A4} hold.

{pstd}
{cmd:cmed mr} does not support post-treatment confounders 
or estimation of interventional or controlled direct effects at this time.

{pstd}
See {help cmed_mr##references:Wodtke and Zhou (2026)} for a detailed
discussion.


{...}
{*  _________________________________________________________  Options }{...}
{...}
{...}
{marker options}{...}
{title:Options}

{dlgtab:Effects}

{marker pathspecific}{...}
{phang}
{opt pathspecific}
estimates path-specific effects of multiple mediators.
Mediators must be specified in reverse causal order, where
the first mediator listed is the last mediator in the causal sequence,
followed by the next-to-last mediator, and so on,
with the final mediator listed being the first in causal order.
The path-specific effects will then capture the unique explanatory role 
of each mediator, net of the other mediators that precede it in causal order. 

{phang}
{opt d(#)}
specifies the alternative level of {it:dvar}. 
The default alternative level is 1.
The difference, {opt d()} - {opt dstar()}, defines the treatment contrast 
evaluated for all estimated effects.

{phang}
{opt dstar(#)}
specifies the reference or control level of {it:dvar}. 
The default reference level is 0. 
The difference, {opt d()} - {opt dstar()}, defines the treatment contrast 
evaluated for all estimated effects.

{dlgtab:Models}

{phang}
{opt nointeraction}
excludes any two-way interaction(s) between the mediator(s) and treatment 
from the relevant models. 
By default, all interactions between the mediator(s) and treatment are included.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in every relevant model. 
Interactions are constructed 
after mean-centering the baseline confounders.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in every relevant model. 
Interactions are constructed after mean-centering the baseline confounders.

{phang}
{cmd:censor(}{it:#1} {it:#2}{cmd:)}
censors the inverse probability and/or ratio-of-mediator probability weights 
required for multiply robust estimation of mediation effects 
at the {it:#1}th and {it:#2}th percentiles, 
bottom-coding weights lower than the {it:#1}th percentile 
and top-coding weights larger than {it:#2}th percentile. 

{phang}
{opt rmpw}
implements an 
alternative approach to multiply robust estimation that involves 
ratio-of-mediator-probability weighting and a logit model for the mediator. 
{opt rmpw}
is only allowed with a single binary mediator. 

{dlgtab:Bootstrap}

{phang}
{opt reps(#)}
specifies the number of bootstrap replications to be performed.  
The default is 50.  
See {helpb bootstrap##options:bootstrap}. 

{phang}
{cmd:seed(}{it:#}{c |}{it:{help numlist}}{cmd:)}
sets the random-number seed(s).  

{phang2}
{bf:Note}:
When option {opt parallel} is specified, 
option {opt seed(numlist)} is required for reproducibility. 
Specify as many seeds as there are processors. 
Using the command {cmd:set seed} alone is insufficient 
to reproduce results obtained with {opt parallel}.

{phang}
{opt parallel}
implements a parallelized version of the bootstrap procedure using 
{helpb parallel bs} with default settings. 
This option requires community-contributed {cmd:parallel} 
from {browse "https://github.com/gvegayon/parallel":GitHub}. 
Parallelization decreases the wall time needed to obtain inferential statistics 
when using a multicore system. 
{opt parallel} may not be combined with {opt svy}.

{phang}
{opt svy}
performs nonparametric bootstrap estimation 
using adjusted bootstrap replicate weights. 
This option requires that the data are {help svyset}  
with option {opt bsrweight()}; see {manlink SVY svy bootstrap}.
{opt svy} may not be combined with {opt parallel}.

{phang}
{it:{help bootstrap##options:bootstrap_options}} 
are any additional options; 
these options are passed through to {helpb bootstrap}.

{dlgtab:Reporting}

{phang}
{opt level(#)}
specifies the confidence level, as a percentage, for confidence intervals.  
The default is {cmd:level(}{cmd:{ccl level})} or as set by {helpb set level}.

{phang}
{opt detail}
prints output from each fitted model used to estimate the nuisance terms
of the multiply robust estimator. 
By default, only the estimated causal effects are reported.


{...}
{marker examples}{...}
{title:Examples}

{pstd}
Setup
{p_end}
{phang2}
{cmd:. sysuse nlsy79.dta} 
{p_end}

{pstd}
Estimate natural direct and indirect effects
of {cmd:att22} on {cmd:cesd_age40} through {cmd:ever_unemp_age3539},
adjusting for pre-treatment confounders 
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed mr (cesd_age40) (ever_unemp_age3539) (att22) = female black hispan famsize}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed mr ((regress) cesd_age40) (ever_unemp_age3539) ((logit) att22) = female black hispan famsize}
{p_end}

{pstd}
Estimate natural effects, censoring inverse probability weights in the 
multiply robust estimator
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, censor(1 99)}
{p_end}

{pstd}
Estimate natural effects, using a robust estimator with ratio-of-mediator-probability weights
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, rmpw}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed mr ((regress) cesd_age40) ((logit) ever_unemp_age3539) ((logit) att22) = female black hispan famsize, rmpw}
{p_end}

{pstd}
Estimate multivariate natural effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539} together;
parentheses required
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Estimate path-specific effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539};
parentheses required
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize, pathspecific}
{p_end}

{pstd}
Parallelize the bootstrap and increase default number of replications
{p_end}
{phang2}
{cmd:. cmed mr cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, reps(1000) parallel}
{p_end}


{...}
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmed mr} stores in {cmd:e()} the results of 
{helpb bootstrap##results:bootstrap}


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
Geoffrey T. Wodtke{break}
Department of Sociology{break}
University of Chicago{break}
Email: wodtke@uchicago.edu

{pstd}
Daniel Klein{break}
German Centre for Higher Education Research and Science Studies{break}
Email: klein@dzhw.eu

