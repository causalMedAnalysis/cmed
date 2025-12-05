{smcl}
{* *! version 0.5.0  4dec2025}{...}
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
Only one mediator is allowed for estimating controlled direct effects.
{p_end}
{...}
{phang}
{it:dvar} 
is the treatement (exposure). 
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
{synoptset 23 tabbed}{...}
{synopthdr:options}
{synoptline}
{...}
{syntab:Effects}
{synopt:{opt paths:pecific}}
estimate path-specific effects
{p_end}
{...}
{synopt:{opt m:value(#)}}
estimate controlled direct effects at {it:mvar}={it:#}
{p_end}
{...}
{synopt:{opt d(#)}}
specify reference level of treatment; 
default is 1
{p_end}
{...}
{synopt:{opt dstar(#)}}
specify alternative level of treatment; 
default is 0
{p_end}

{syntab:Models}
{synopt:{opt nointer:action}}
do not include interaction(s) between mediator(s) and treatment 
in all relevant models
{p_end}
{...}
{synopt:{opt cxd}}
include interactions between baseline confounders (if specified) and treatment 
in all relevant models
{p_end}
{...}
{synopt:{opt cxm}}
include interactions between baseline confounders (if specified) and 
mediator(s) in all relevant models
{p_end}
{...}

{synopt:{opt censor(numlist)}}
censor the inverse probability weights at the percentiles supplied in numlist,
if using imputation-based weighting
{p_end}
{...}

{synopt:{opt detail}}
print the fitted models used to compute effect estimates
{p_end}

{syntab:Bootstrap}
{synopt:{it:...}}
any options are passed through
{p_end}
{...}
{synopt:{opt parallel}}
parallelize the bootstrap using {help parallel bs} 
(requires the {cmd:parallel} module)
{p_end}

{synoptline}


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
In the simplest case with one mediator and no post-treatement confounders, 
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
(3) a linear or logit model for the predicted values from the previous model, 
conditional on the treatment and baseline confounders.
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
mediators under consideration. If the mediators are specified in causal order, 
option {helpb cmed_impute##pathspecific:pathspecific} can be used to estimate 
path-specific effects as well. To have a causal interpretation, these estimates 
additionally require that there are no unobserved or exposure-induced 
confounders for any of the mediator-mediator relationships.

{pstd}
With a single mediator, option {helpb cmed_impute##mvalue:mvalue} can 
be used for estimating controlled direct effects. These effects are based on
imputed outcomes constructed using only Model 2. Estimates of controlled 
direct effects have a causal interpretation provided that this model 
is correctly specified and assumptions {bf:A1}-{bf:A2} hold.

{pstd}
See {help cmed_impute##references:Wodtke and Zhou (2026)} for a detailed 
discussion.

{pstd}
{cmd:cmed impute} does not support post-treatment confounders or estimation
of interventional effects.




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
estimates path-specific effects. When using this option, the mediators must be 
specified in their causal order, where the first mediator listed in the command 
syntax causally precedes the second mediator, which in turn precedes the third, 
and so on for all the mediators supplied. The path-specific effects will then 
capture the unique explanatory role of each mediator, net of the other 
mediators that precede it in causal order. 

{phang}
{opt mvalue(#)}
estimates controlled direct effects at {it:mvar}={it:#}. This option may only 
be specified with a single mediator. Controlled direct effects capture the 
influence of the treatment on the outcome if the mediator for each observation 
were set at a single specific value.

{phang}
{opt d(#)}
allows the user to specify the reference level of treatment. The default is 1.

{phang}
{opt dstar(#)}
allows the user to specify the alternative level of treatment. The default 
is 0. d - dstar defines the treatment contrast evaluated for all estimated 
effects. With treatments that have many values or are continuous, users can 
estimate the effects of different contrasts comparing particular levels of 
treatment by specifying d(#) and dstar(#).

{dlgtab:Models}

{phang}
{opt nointeraction}
excludes any two-way interaction(s) between the mediator(s) and treatment 
from the relevant outcome model. Interactions between the mediator(s) and 
treatment are included by default.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in every outcome model.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in the relevant outcome model.

{phang}
{opt censor(numlist)}
is only allowed when implementing imputation-based weighting. This option
censors the inverse probability weights at the percentiles supplied in numlist. 
For example, {opt censor(1 99)} censors the weights at their 1st and 99th 
percentiles -- that is, it bottom codes very small weights at the 1st percentile 
and top codes very large weights at the 99th percentile. Censoring the weights
a tiny amount often improves the stability of estimates without compromising
their accuracy.

{phang}
{opt detail}
prints output from each fitted model for the outcome. When implementing
imputation-based weighting, this option additionally prints output from
the fitted model for treatment. Only the estimated causal effects are 
reported if this option is omitted.

{dlgtab:Bootstrap}

{phang}
all {help bootstrap} options are available and passed through.

{phang}
{opt parallel}
implements a parallelized version of the bootstrap procedure using 
{help parallel bs} with default settings. This option requires the 
{cmd:parallel} module. Parallelization can be used to decrease the wall time 
needed to obtain inferential statistics when using a multicore system. 
The bootstrap procedure will not be parallelized when this option 
is omitted. 

{synoptline}


{...}
{marker examples}{...}
{title:Examples}

{pstd}
Setup
{p_end}
{phang2}
{cmd:. use nlsy79.dta} 
{p_end}

{phang2}
{cmd:. global cvars female black hispan paredu parprof parinc_prank famsize afqt3} 
{p_end}
{phang2}
{cmd:. global dvar att22} 
{p_end}
{phang2}
{cmd:. global mvar1 ever_unemp_age3539} 
{p_end}
{phang2}
{cmd:. global mvar2 log_faminc_adj_age3539}
{p_end}
{phang2}
{cmd:. global depvar cesd_age40} 
{p_end}

{pstd}
Estimate natural direct and indirect effects through mvar1
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) $mvar1 $dvar = $cvars}
{p_end}

{pstd}
Estimate natural effects, including interactions
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) $mvar1 $dvar = $cvars, cxd cxm}
{p_end}

{pstd}
Estimate natural effects, using imputation-based weighting with censoring
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) $mvar1 ((logit) $dvar) = $cvars, censor(1 99)}
{p_end}

{pstd}
Estimate controlled direct effects, controlling mvar1
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) $mvar1 $dvar = $cvars, m(1)}
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) $mvar1 $dvar = $cvars, m(0)}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) ($mvar1 $mvar2) $dvar = $cvars}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) ($mvar1 $mvar2) $dvar = $cvars, paths}
{p_end}

{pstd}
Estimate path-specific effects, using imputation-based weighting with censoring
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) ($mvar1 $mvar2) ((logit) $dvar) = $cvars, paths censor(1 99)}
{p_end}

{pstd}
Specify the number of bootstrap replications
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) ($mvar1 $mvar2) ((logit) $dvar) = $cvars, paths censor(1 99) reps(1000)}
{p_end}

{pstd}
Parallelize the bootstrap replications
{p_end}
{phang2}
{cmd:. cmed impute ((reg) $depvar) ($mvar1 $mvar2) ((logit) $dvar) = $cvars, paths censor(1 99) reps(1000) parallel}
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
YOUR AFFILIATION{break}
Email: YOUR INSTITUTIONAL EMAIL