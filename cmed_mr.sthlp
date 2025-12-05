{smcl}
{* *! version 0.4.0  11nov2025}{...}
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
is a binary treatement (exposure). 
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
{synoptset 23 tabbed}{...}
{synopthdr:options}
{synoptline}
{...}
{syntab:Effects}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{opt rmpw}}use a robust estimator that involves 
ratio-of-mediator-probability weighting
{p_end}
{...}
{synopt:{opt d(#)}}specify reference level of treatment; default is 1
{p_end}
{...}
{synopt:{opt dstar(#)}}specify alternative level of treatment; default is 0
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
censor the inverse probability and/or ratio-of-mediator-probability weights at 
the percentiles supplied in numlist
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
{cmd:cmed mr} estimates the natural direct and indirect effects
of a binary treatment (exposure) on an outcome using multiply robust
methods. When multiple mediators are specified, the command estimates
multivariate natural effects and, optionally, path-specific effects
through a set of causally ordered mediators. Standard errors and
confidence intervals are obtained using the nonparametric {help bootstrap}.

{pstd}
In the simplest case with one mediator and no post-treatment confounders,
{cmd:cmed mr} constructs multiply robust estimates of the natural direct and
indirect effects, as well as of the total effect, by fitting the following models:

{phang2}
(1) a logit model for the treatment with the baseline confounders as predictors
{p_end}
{phang2}
(2) another logit model for the treatment with the baseline confounders
and the mediator as predictors
{p_end}
{phang2}
(3) a linear model for the outcome with the treatment, mediator, and
baseline confounders as predictors
{p_end}
{phang2}
(4) a linear model for a set of predicted values from the previous model,
conditional on the treatment and baseline confounders
{p_end}

{pstd}
These models are used to construct all the nuisance terms in a multiply robust
estimator for natural effects, which is then evaluated to produce the 
estimates of interest. The estimated effects have a causal interpretation 
under a set of modeling and identification assumptions. The modeling 
assumptions require that at least one of the following three conditions 
is met: (i) Models 1 and 2 are correctly specified, (ii) Models 1 and 3 are 
correctly specified, or (iii) Models 3 and 4 are correctly specified. This 
estimator is sometimes described as "triply robust" because it provides three 
distinct opportunities to satisfy its modeling requirements. Beyond these 
modeling requirements, the identification assumptions stipulate that the 
following conditions hold:

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
({bf:A4}) There are no exposure-induced confounders of the mediator–outcome
relationship.
{p_end}

{pstd}
When more than one mediator is specified, {cmd:cmed mr} estimates
multivariate natural direct and indirect effects by including all mediators
as predictors in Models 2 and 3 above. The estimated effects in this case have
a causal interpretation under the same modeling conditions outlined previously,
provided that assumption {bf:A1} holds and that assumptions {bf:A2}–{bf:A4}
hold with respect to all mediators under consideration. If the mediators
are specified in causal order, option {helpb cmed_mr##pathspecific:pathspecific}
can be used to estimate path-specific effects as well. To have a causal
interpretation, these estimates additionally require that there are no
unobserved or exposure-induced confounders for any of the mediator–mediator
relationships.

{pstd}
Alternatively, with a single binary mediator, option
{helpb cmed_mr##rmpw:rmpw} can be used to implement a different multiply
robust estimator that involves ratio-of-mediator-probability weighting.
In this case, estimates for the natural direct and indirect effects through
this binary mediator are constructed by fitting the following models:

{phang2}
(1b) a logit model for the treatment with the baseline confounders as predictors
{p_end}
{phang2}
(2b) a logit model for the mediator with the treatment and baseline confounders
as predictors
{p_end}
{phang2}
(3b) a linear model for the outcome with the treatment, mediator, and
baseline confounders as predictors
{p_end}

{pstd}
These models are used to construct all the nuisance terms in another multiply
robust estimator for natural effects, which is then evaluated to produce the 
estimates of interest. The estimated effects in this case have a causal
interpretation provided that assumptions {bf:A1}–{bf:A4} hold and that
at least two of the three models above are correctly specified. In other words,
this approach to multiply robust estimation requires that either (i) Models 1b
and 2b are correctly specified, (ii) Models 2b and 3b are correctly specified,
or (iii) Models 1b and 3b are correctly specified. Thus, it is also
sometimes described as "triply robust," offering three opportunities to
satisfy its modeling requirements.

{pstd}
See {help cmed_mr##references:Wodtke and Zhou (2026)} for a detailed
discussion.

{pstd}
{cmd:cmed mr} does not support post-treatment confounders or estimation
of interventional or controlled direct effects at this time.


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
{opt rmpw}
is only allowed with a single binary treatment. This option implements an 
alternative approach to multiply robust estimation that involves 
ratio-of-mediator-probability weighting and a logit model for the mediator.

{phang}
{opt d(#)}
allows the user to specify the reference level of treatment. The default is 1.

{phang}
{opt dstar(#)}
allows the user to specify the alternative level of treatment. The default 
is 0. d - dstar defines the treatment contrast evaluated for all estimated 
effects. Only binary treatments are allowed with {cmd:cmed mr}.

{dlgtab:Models}

{phang}
{opt nointeraction}
excludes any two-way interaction(s) between the mediator(s) and treatment 
from the relevant outcome model. Interactions between the mediator(s) and 
treatment are included by default.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in every relevant model.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in every relevant model.

{phang}
{opt censor(numlist)}
censors the inverse probability and/or ratio-of-mediator probability weights
required for multiply robust estimation of mediation effects at the 
percentiles supplied in numlist. For example, {opt censor(1 99)} censors 
the weights at their 1st and 99th percentiles -- that is, it bottom codes 
very small weights at the 1st percentile and top codes very large weights at 
the 99th percentile. Censoring the weights a tiny amount often improves the 
stability of estimates without compromising their accuracy.

{phang}
{opt detail}
prints output from each fitted model used to estimate the nuisance terms
of the multiply robust estimator. Only the estimated causal effects are 
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
{cmd:. cmed mr $depvar $mvar1 $dvar = $cvars}
{p_end}

{pstd}
Estimate natural effects, including interactions
{p_end}
{phang2}
{cmd:. cmed mr $depvar $mvar1 $dvar = $cvars, cxd cxm}
{p_end}

{pstd}
Estimate natural effects, censoring the inverse probability weights in the 
multiply robust estimator
{p_end}
{phang2}
{cmd:. cmed mr $depvar $mvar1 $dvar = $cvars, censor(1 99)}
{p_end}

{pstd}
Estimate natural effects, using a robust estimator with ratio-of-mediator-probability weights
{p_end}
{phang2}
{cmd:. cmed mr $depvar $mvar1 $dvar = $cvars, rmpw}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed mr $depvar ($mvar1 $mvar2) $dvar = $cvars}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2
{p_end}
{phang2}
{cmd:. cmed mr $depvar ($mvar1 $mvar2) $dvar = $cvars, paths}
{p_end}

{pstd}
Specify the number of bootstrap replications
{p_end}
{phang2}
{cmd:.  cmed mr $depvar ($mvar1 $mvar2) $dvar = $cvars, paths reps(1000)}
{p_end}

{pstd}
Parallelize the bootstrap replications
{p_end}
{phang2}
{cmd:. cmed mr $depvar ($mvar1 $mvar2) $dvar = $cvars, paths reps(1000) parallel}
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
YOUR AFFILIATION{break}
Email: YOUR INSTITUTIONAL EMAIL