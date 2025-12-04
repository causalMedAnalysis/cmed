{smcl}
{* *! version 0.5.0  03dec2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_linear##syntax"}{...}
{viewerjumpto "Description" "cmed_linear##description"}{...}
{viewerjumpto "Options" "cmed_linear##options"}{...}
{viewerjumpto "Examples" "cmed_linear##examples"}{...}
{viewerjumpto "Stored results" "cmed_linear##results"}{...}
{viewerjumpto "References" "cmed_linear##references"}{...}
{viewerjumpto "Support" "cmed_linear##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed linear} {hline 2} {...}
Causal mediation analysis using linear models


{...}
{*  __________________________________________________________  Syntax }{...}
{...}
{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Natural effects through a single mediator

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{help varname:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Multivariate natural effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Path-specific effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt paths:pecific} 
[{it:options}]


{pstd}
Interventional effects through a single mediator with post-treatment confounders

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{help varname:{it:mvar}}
{cmd:(}{help varname:{it:lvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} 
{it:options}]


{pstd}
Controlled direct effects with a single mediator

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{help varname:{it:mvar}}
[{cmd:(}{help varlist:{it:lvars}}{cmd:)}]
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
Only one mediator is allowed for estimating interventional and 
controlled direct effects. 
{p_end}
{...}
{phang}
{it:lvars}
are post-treatment confounders (exposure-induced confounders).  
{p_end}
{...}
{phang}
{it:dvar} 
is the treatment (exposure).
{p_end}
{...}
{phang}
{it:cvars} 
are baseline confounders (pre-treatment confounders). 


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
in the outcome model
{p_end}
{...}
{synopt:{opt cxd}}
include interactions between baseline confounders (if specified) and treatment 
in all relevant models
{p_end}
{...}
{synopt:{opt cxm}}
include interactions between baseline confounders (if specified) and 
mediator(s) in the outcome model
{p_end}
{...}
{synopt:{opt lxm}}
include interactions between post-treatment confounders (if specified) 
and mediator in the outcome model
{p_end}
{...}
{synopt:{opt cat(lvars)}}
treat {it:lvars} as categorical
{p_end}
{...}
{synopt:{opt detail}}
print the fitted models for mediator(s) and outcome
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
{cmd:cmed linear} estimates the natural direct and indirect effects 
of a treatment (exposure) on an outcome using linear models 
for both the mediator and the outcome. When multiple mediators are specified,
the command estimates multivariate natural effects using linear models for
all the mediators and the outcome. If post-treatment confounders
are specified, the command estimates interventional direct and indirect 
effects. Optionally, the command estimates path-specific effects through a set 
of causally ordered mediators as well as controlled direct effects with a 
single mediator. Standard errors and confidence intervals are obtained 
using the nonparametric {help bootstrap}. 

{pstd}
In the simplest case with one mediator and no post-treatement confounders, 
{cmd:cmed linear} estimates natural direct and indirect effects,
along with the total effect, by fitting two models:

{phang2}
(1) a linear model for the mediator with the treatment and baseline 
confounders as predictors
{p_end}
{phang2}
(2) a linear model for the outcome with the treatment, baseline confounders, 
and mediator as predictors
{p_end}

{pstd}
All baseline confounders are first centered around their sample means. 
The estimated effects have a causal interpretation provided that these models
are correctly specified and the following assumptions hold:

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
When post-treatment (i.e., exposure-induced) confounders are specified, 
{cmd:cmed linear} uses a regression-with-residuals approach 
to estimate interventional direct and indirect effects, also known as 
randomized intervention analogues to natural direct and indirect effects. 
For each post-treatment confounder, {cmd:cmed linear} fits a model with the 
treatment and baseline confounders as predictors, computes the residuals, 
and then includes these residuals as additional predictors in the linear model 
for the outcome. The estimated effects in this case have a causal 
interpretation when assumptions {bf:A1}-{bf:A3} hold.

{pstd}
With a single mediator, option {helpb cmed_linear##mvalue:mvalue} can 
be used for estimating controlled direct effects, which only involves
the linear model for the outcome. These effects have a causal interpretation 
provided that the outcome model is correctly specified and assumptions 
{bf:A1}-{bf:A2} hold.

{pstd}
When more than one mediator is specified, {cmd:cmed linear} estimates 
multivariate natural direct and indirect effects using a separate 
linear model for each mediator and a linear model for the outcome that
includes all mediators as predictors, in addition to the treatment and
baseline confounders. The estimated effects in this case have a causal 
interpretation if every model is correctly specified, assumption 
{bf:A1} holds, and assumptions {bf:A2}-{bf:A4} hold with respect to all the 
mediators under consideration. If the mediators are specified in causal order, 
option {helpb cmed_linear##pathspecific:pathspecific} can be used for 
estimating path-specific effects using linear models. To have a causal 
interpretation, these estimates additionally require that there are no 
unobserved or exposure-induced confounders for any of the mediator-mediator 
relationships.

{pstd}
See {help cmed##references:Wodtke and Zhou (2026)} for a detailed discussion.


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
in the outcome model. Interactions between the mediator(s) and treatment are
included by default.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in models for the mediator(s), outcome, and 
post-treatment confounders (if specified). These interactions are constructed 
after mean-centering the baseline confounders.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in the outcome model. These interactions 
are constructed after mean-centering the baseline confounders.

{phang}
{opt lxm}
includes all two-way interactions between the post-treatment confounders 
(if specified) and the mediator(s) in the outcome model. These interactions 
are constructed after residualizing the post-treatment confounders with 
respect to treatment and the baseline confounders.

{phang}
{opt cat(lavrs)}
is only allowed if post-treatment confounders are specified. Variables passed 
to this option are automatically one-hot encoded and then residualized using 
logistic models when implementing regression-with-residuals for interventional 
and controlled effects.

{phang}
{opt detail}
prints output from each fitted model for the mediator(s) and outcome. When 
this option is omitted, only the estimated causal effects are reported.

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
{cmd:. cmed linear $depvar $mvar1 $dvar = $cvars}
{p_end}

{pstd}
Estimate natural effects, including interactions
{p_end}
{phang2}
{cmd:. cmed linear $depvar $mvar1 $dvar = $cvars, cxd cxm}
{p_end}

{pstd}
Estimate controlled direct effects, including interactions
{p_end}
{phang2}
{cmd:. cmed linear $depvar $mvar1 $dvar = $cvars, cxd cxm m(1)}
{p_end}
{phang2}
{cmd:. cmed linear $depvar $mvar1 $dvar = $cvars, cxd cxm m(0)}
{p_end}

{pstd}
Estimate interventional effects through mvar2, adjusting for mvar1 as a 
post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed linear $depvar $mvar2 ($mvar1) $dvar = $cvars}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed linear $depvar ($mvar1 $mvar2) $dvar = $cvars}
{p_end}

{pstd}
Estimate multivariate natural effects, including interactions
{p_end}
{phang2}
{cmd:. cmed linear $depvar ($mvar1 $mvar2) $dvar = $cvars, cxd cxm}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2, including interactions
{p_end}
{phang2}
{cmd:. cmed linear $depvar ($mvar1 $mvar2) $dvar = $cvars, cxd cxm paths}
{p_end}

{pstd}
Specify the number of bootstrap replications
{p_end}
{phang2}
{cmd:. cmed linear $depvar ($mvar1 $mvar2) $dvar = $cvars, cxd cxm paths reps(1000)}
{p_end}

{pstd}
Parallelize the bootstrap replications
{p_end}
{phang2}
{cmd:. cmed linear $depvar ($mvar1 $mvar2) $dvar = $cvars, cxd cxm paths reps(1000) parallel}
{p_end}


{...}
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmed linear} stores in {cmd:e()} the results of 
{helpb bootstrap##results:bootstrap}


{...}
{marker references}{...}
{title:References}

{pstd}
Wodtke GT, and Zhou X. 2026. Causal Mediation Analysis. Cambridge University 
Press.
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