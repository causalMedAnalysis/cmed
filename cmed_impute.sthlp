{smcl}
{* *! version 0.6.0  04jan2026}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_impute##syntax"}{...}
{viewerjumpto "Description" "cmed_impute##description"}{...}
{viewerjumpto "Options" "cmed_impute##options"}{...}
{viewerjumpto "Examples" "cmed_impute##examples"}{...}
{viewerjumpto "Stored results" "cmed_impute##results"}{...}
{viewerjumpto "References" "cmed_impute##references"}{...}
{viewerjumpto "Support" "cmed_impute##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed impute} {hline 2} {...}
Causal mediation analysis using regression imputation


{...}
{*  __________________________________________________________  Syntax }{...}
{...}
{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Natural effects through a single mediator, pure regression imputation

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Multivariate natural effects through multiple mediators, pure regression
imputation

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Path-specific effects through multiple mediators, pure regression
imputation

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt paths:pecific} 
[{it:options}]


{pstd}
Natural effects, imputation-based weighting

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{cmd:(}{cmd:(logit)} {help varname:{it:dvar}}{cmd:)}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Path-specific effects, imputation-based weighting

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{cmd:(}{cmd:(logit)} {help varname:{it:dvar}}{cmd:)}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt paths:pecific} 
[{it:options}]


{pstd}
Controlled direct effects with a single mediator

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{help varname:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt m:value(#)} 
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
Only one mediator is allowed when estimating controlled direct effects.
{p_end}
{...}
{phang}
{it:dvar} 
is the treatment (exposure). 
The treatment must be binary for imputation-based weighting. 
{p_end}
{...}
{phang}
{it:cvars}
are baseline confounders (pre-treatment confounders).
{p_end}

{...}
{phang}
{it:ymodel} is one of {cmdab:reg:ress} (default) or {cmd:logit}.


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
{synopt:{opt m:value(#)}}estimate controlled direct effect at {it:mvar}={it:#}
{p_end}
{...}
{p2coldent :* {opt d(#)}}specify alternative level of {it:dvar}; 
default for dichotomous treatments is the second treatment level
{p_end}
{...}
{p2coldent:* {opt dstar(#)}}specify reference level of {it:dvar}; 
default for dichotomous treatments is the first treatment level
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
{synopt:{cmd:censor(}{it:#1} {it:#2}{cmd:)}}censor inverse probability weights 
at the {it:#1}th and {it:#2}th percentiles
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
{synopt:{opt detail}}print the fitted models used to compute effect estimates
{p_end}
{synoptline}
{pstd}
* {opt d()} and {opt dstar()} are required with continuous treatments.


{...}
{*  ____________________________________________________  Description }{...}
{...}
{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed impute} estimates the natural direct and indirect effects 
of a treatment (exposure) on an outcome using regression imputation. 
When multiple mediators are specified, the command estimates multivariate 
natural effects. Optionally, the command estimates path-specific 
effects through a set of causally ordered mediators as well as controlled 
direct effects with a single mediator. Standard errors and confidence intervals 
are obtained using the nonparametric {help bootstrap}. 

{pstd}
In the simplest case with one mediator and no post-treatment confounders, 
{cmd:cmed impute} constructs pure regression imputation estimates for 
natural direct and indirect effects, as well as the total effect, by 
fitting the following models:

{phang2}
(1) a linear or logit model for the outcome with the treatment and 
baseline confounders as predictors 
{p_end}
{phang2}
(2) a linear or logit model for the outcome with the treatment, 
baseline confounders, and mediator as predictors
{p_end}
{phang2}
(3) a linear or logit model for a set of predicted values from the 
previous model, conditional on the treatment and baseline confounders.
{p_end}

{pstd}
The models are used to impute the outcome under different counterfactual 
scenarios. These imputed outcomes are then averaged together and compared 
to estimate the natural direct and indirect effects of interest. The 
estimated effects have a causal interpretation provided that all the models 
used to construct the imputations are correctly specified and the following 
assumptions hold:

{phang2}
({bf:A1}) There are no unobserved treatment-outcome confounders.
{p_end}
{phang2}
({bf:A2}) There are no unobserved mediator-outcome confounders.
{p_end}
{phang2}
({bf:A3}) There are no unobserved treatment-mediator confounders.
{p_end}
{phang2}
({bf:A4}) There are no exposure-induced confounders of the mediator-outcome
relationship.
{p_end}

{pstd}
Alternatively, {cmd:cmed impute} can also construct imputation-based weighting 
estimates of natural direct and indirect effects, provided that the treatment
is binary. This approach also involves fitting Models 1 and 2, exactly as 
above. However, instead of fitting Model 3, imputation-based weighting involves
fitting a logit model for the treatment with the baseline confounders as 
predictors. This model is used to construct a set of inverse probability
weights, which are then used together with Model 2 to appropriately 
average its imputed outcomes and compute the effects of interest.

{pstd}
When more than one mediator is specified, {cmd:cmed impute} estimates 
multivariate natural direct and indirect effects by including all mediators 
as predictors in Model 2 above, in addition to the treatment and baseline 
confounders. Imputed outcomes are then obtained and used to estimate 
multivariate natural effects. The estimated effects in this case have a 
causal interpretation if all models are correctly specified, assumption 
{bf:A1} holds, and assumptions {bf:A2}-{bf:A4} hold with respect to all the 
mediators under consideration. If the mediators are specified in reverse causal 
order, such that the first mediator listed is the final mediator in the causal 
sequence, followed by the next-to-last mediator, and so on, then option 
{helpb cmed_impute##pathspecific:pathspecific} can be used to estimate 
path-specific effects as well. To have a causal interpretation, these estimates 
additionally require that there are no unobserved or exposure-induced 
confounders for any of the mediator-mediator relationships.

{pstd}
With a single mediator, option {helpb cmed_impute##mvalue:mvalue} can 
be used to estimating controlled direct effects. These effects are based on
imputed outcomes constructed using only Model 2. Estimates of controlled 
direct effects have a causal interpretation provided that this model 
is correctly specified and assumptions {bf:A1}-{bf:A2} hold.

{pstd}
{cmd:cmed impute} does not support post-treatment confounders or estimation
of interventional effects.

{pstd}
See {help cmed_impute##references:Wodtke and Zhou (2026)} for a detailed 
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
{opt mvalue(#)}
estimates controlled direct effects at {it:mvar}={it:#}. 
Controlled direct effects capture the influence of the treatment on the outcome 
if the mediator for each observation were set at a single specific value. 
This option may only be specified with a single mediator. 

{phang}
{opt d(#)}
specifies the alternative level of {it:dvar}. 
For dichotomous treatments, the default alternative level 
is the second treatment level. 
Option {opt d()} is required with continuous treatments. 
The difference, {opt d()} - {opt dstar()}, defines the treatment contrast 
evaluated for all estimated effects.

{phang}
{opt dstar(#)}
specifies the reference or control level of {it:dvar}. 
For dichotomous treatments, the default reference level 
is the first treatment level. 
Option {opt dstar()} is required with continuous treatments. 
The difference, {opt d()} - {opt dstar()}, defines the treatment contrast 
evaluated for all estimated effects.

{dlgtab:Models}

{phang}
{opt nointeraction}
excludes any two-way interaction(s) between the mediator(s) and treatment 
from the outcome model. 
By default, all interactions between the mediator(s) and treatment are included.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in every outcome model. 
Interactions are constructed 
after mean-centering the baseline confounders.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in the relevant outcome model. 
Interactions are constructed after mean-centering the baseline confounders.

{phang}
{cmd:censor(}{it:#1} {it:#2}{cmd:)}
censors the inverse probability weights 
at the {it:#1}th and {it:#2}th percentiles, 
bottom-coding weights lower than the {it:#1}th percentile 
and top-coding weights larger than {it:#2}th percentile. 
{opt censor()}
is only allowed with imputation-based weighting. 

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
prints output from each fitted model for the outcome and, 
for imputation-based weighting, from the fitted model for treatment.  
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
{cmd:. cmed impute cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize}
{p_end}

{pstd}
Same as above 
{p_end}
{phang2}
{cmd:. cmed impute (cesd_age40) (ever_unemp_age3539) (att22) = female black hispan famsize}
{p_end}

{pstd}
Same as above 
{p_end}
{phang2}
{cmd:. cmed impute ((regress) cesd_age40) (ever_unemp_age3539) (att22) = female black hispan famsize}
{p_end}

{pstd}
Estimate natural direct and indirect effects, 
using imputation-based weighting
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 ever_unemp_age3539 ((logit) att22) = female black hispan famsize}
{p_end}

{pstd}
Same as above 
{p_end}
{phang2}
{cmd:. cmed impute ((regress) cesd_age40) ever_unemp_age3539 ((logit) att22) = female black hispan famsize}
{p_end}

{pstd}
Estimate natural effects, using imputation-based weighting
and censoring inverse probability weights at the 1st and 99th percentile
{p_end}
{phang2}
{cmd:. cmed impute ((regress) cesd_age40) ever_unemp_age3539 ((logit) att22) = female black hispan famsize, censor(1 99)}
{p_end}

{pstd}
Estimate multivariate natural effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539} together;
parentheses required
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Estimate path-specific effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539};
parentheses required
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize, pathspecific}
{p_end}

{pstd}
Estimate controlled direct effects of {cmd:att22}, controlling {cmd:ever_unemp_age3539}
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, mvalue(1)}
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, mvalue(0)}
{p_end}

{pstd}
Parallelize the bootstrap and increase default number of replications
{p_end}
{phang2}
{cmd:. cmed impute cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, reps(1000) parallel}
{p_end}


{...}
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmed impute} stores in {cmd:e()} the results of 
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
