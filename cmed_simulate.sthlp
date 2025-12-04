{smcl}
{* *! version 0.7.0  4dec2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{viewerjumpto "Syntax" "cmed_simulate##syntax"}{...}
{viewerjumpto "Description" "cmed_simulate##description"}{...}
{viewerjumpto "Options" "cmed_simulate##options"}{...}
{viewerjumpto "Examples" "cmed_simulate##examples"}{...}
{viewerjumpto "Stored results" "cmed_simulate##results"}{...}
{viewerjumpto "References" "cmed_simulate##references"}{...}
{viewerjumpto "Support" "cmed_simulate##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed simulate} {hline 2} {...}
Causal mediation analysis using simulation and generalized linear models


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
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}[{cmd:(}{it:mmodel}{cmd:)}] {help varname:{it:mvar}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Multivariate natural effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}{it:mspec}{cmd:)} 
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Path-specific effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}{it:mspec}{cmd:)} 
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
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}[{cmd:(}{it:mmodel}{cmd:)}] {help varname:{it:mvar}}{cmd:)}
{cmd:(}{it:lspec}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Controlled direct effects with a single mediator and post-treatment confounders

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{help varname:{it:mvar}}
{cmd:(}{it:lspec}{cmd:)}
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
Only one mediator is allowed for estimating interventional and controlled 
direct effects.
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
{p_end}

{...}
{phang}
{it:yspec} 
is 
[{cmd:(}{it:ymodel}{cmd:)}] {it:depvar}
{p_end}
{...}
{phang}
{it:mspec} 
is 
[{cmd:(}{it:mmodel}{cmd:)}]  {it:mvars} 
[{cmd:(}{it:mmodel}{cmd:)} {it:mvars}] {it:...}
{p_end}
{...}
{phang}
{it:lspec} 
is 
[{cmd:(}{it:lmodel}{cmd:)}]  {it:lvars} 
[{cmd:(}{it:lmodel}{cmd:)} {it:lvars}] {it:...}
{p_end}

{phang}
{it:ymodel}, {it:mmodel}, and {it:lmodel}
are one of 
{cmdab:reg:ress} (default), 
{cmd:logit}, 
{cmd:poisson}, 
or {cmd:ologit}
{p_end}

{phang}
{it:lvars} 
are post-treatment covariates (exposure-induced confounders).
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
{synopt:{opt nsim(#)}}
specify the number of simulated values to generate; default is 200
{p_end}
{...}
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
{synopt:{opt detail}}
print the fitted models used to generate the simulations
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
{cmd:cmed simulate} estimates the natural direct and indirect effects 
of a treatment (exposure) on an outcome by simulating variables from
generalized linear models (GLMs) for the mediator and outcome. When multiple 
mediators are specified, the command estimates multivariate natural effects by
simulating variables from a series of GLMs for each mediator and the outcome.
If post-treatment confounders are specified, the command estimates 
interventional direct and indirect effects by simulating variables from GLMs 
for the mediator, outcome, and each post-treatment confounder. Optionally, 
the command estimates path-specific effects through a set of causally ordered 
mediators as well as controlled direct effects with a single mediator.
Standard errors and confidence intervals are obtained using the 
nonparametric {help bootstrap}. 

{pstd}
In the simplest case with one mediator and no post-treatement confounders, 
{cmd:cmed simulate} estimates the natural direct and indirect effects,
as well as the total effect, of a treatment by fitting two models:

{phang2}
(1) a GLM for the mediator with treatment and the baseline confounders as 
predictors
{p_end}
{phang2}
(2) a GLM for the outcome with treatment, the mediator, and the baseline 
confounders as predictors
{p_end}

{pstd}
The models are used to generate simulated values for the mediator and outcome 
under different counterfactual scenarios. These simulated values are then 
averaged together and compared to estimate the natural direct and indirect 
effects of interest. The estimated effects have a causal interpretation 
provided that the GLMs for the mediator and outcome are correctly specified 
and the following assumptions hold:

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
When more than one mediator is specified, {cmd:cmed simulate} estimates 
multivariate natural direct and indirect effects. To estimate these effects,
the command fits the following models:

{phang2}
(1b) a GLM for each mediator in the order they are specified, with treatment, 
the baseline confounders, and all preceding mediators included as predictors
{p_end}
{phang2}
(2b) a GLM for the outcome with treatment, all the mediators, and the baseline 
confounders as predictors
{p_end}

{pstd}
With these models, simulated values for each mediator and the outcome are 
generated under different counterfactual scenarios, which are then used to 
estimate multivariate natural effects. The estimated effects 
in this case have a causal interpretation if every model is correctly 
specified, assumption {bf:A1} holds, and assumptions {bf:A2}-{bf:A4} 
hold with respect to all the mediators under consideration. 
If the mediators are specified in causal order, option 
{helpb cmed_simulate##pathspecific:pathspecific} can be used to estimate 
path-specific effects. To have a causal interpretation, these estimates 
additionally require that there are no unobserved or exposure-induced 
confounders for any of the mediator-mediator relationships.

{pstd}
When post-treatment (i.e., exposure-induced) confounders are specified, 
{cmd:cmed simulate} estimates interventional direct and indirect effects 
operating through a single, focal mediator. To construct these estimates,
the command fits the following models:

{phang2}
(1c) a GLM for the focal mediator with treatment and the baseline confounders as 
predictors
{p_end}
{phang2}
(2c) a GLM for each post-treatment confounder in the order they are specified, 
with treatment, the baseline confounders, and all preceding post-treatment 
confounders included as predictors
{p_end}
{phang2}
(3c) a GLM for the outcome with treatment, the mediator, the baseline 
confounders, and the post-treatment confounders as predictors
{p_end}

{pstd}
The models are used to generate simulated values for each post-treatment 
confounder, the focal mediator, and the outcome under different 
counterfactual scenarios. These simulated values are then averaged together 
and compared to estimate the interventional effects of interest. The estimated 
effects have a causal interpretation if all the models used to generate the
simulations are correctly specified and assumptions {bf:A1}-{bf:A3} hold.

{pstd}
With a single mediator, and when post-treatment confounders are specified, 
option {helpb cmed_simulate##mvalue:mvalue} can be used for estimating 
controlled direct effects. The simulated values used to estimate these effects 
are generated from Models 2c and 3c above. Estimates of controlled direct 
effects have a causal interpretation provided that the models used to generate
the simulations are correctly specified and assumptions {bf:A1}-{bf:A2} hold.
Users attempting to estimate controlled direct effects with {cmd:cmed simulate} 
when there are no post-treatment confounders should use {cmd:cmed impute} 
instead. In the absence of post-treatment confounders, {cmd:cmed impute} 
implements an estimator for controlled direct effects that is essentially 
identical to {cmd:cmed simulate} but does not suffer from any simulation error 
and thus will yield more stable estimates. It is also more computationally 
efficient.

{pstd}
See {help cmed_simulate##references:Wodtke and Zhou (2026)} for a detailed discussion.


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
be specified with a single mediator and when post-treatment confounders are
also supplied. Controlled direct effects capture the influence of the 
treatment on the outcome if the mediator for each observation were set at a 
single specific value.

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
{opt nsim(#)}
specifies the number of simulated values to generate. The default is 200. 
A larger number of simulated values improves the precision of the effect 
estimates but increases the wall time needed to compute them. 
For most applications, {help cmed##references:Wodtke and Zhou (2026)} recommend 
using at least 1000 simulations.

{phang}
{opt nointeraction}
excludes any two-way interaction(s) between the mediator(s) and treatment 
in the outcome model. Interactions between the mediator(s) and treatment are
included by default.

{phang}
{opt cxd}
includes all two-way interactions between the baseline confounders 
(if specified) and treatment in models for the mediator(s), outcome, and 
post-treatment confounders (if specified).

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in the outcome model.

{phang}
{opt lxm}
includes all two-way interactions between the post-treatment confounders 
(if specified) and the mediator(s) in the outcome model.

{phang}
{opt detail}
prints output from each fitted model used to generate the simulations. When 
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
is omitted. Parallelization is highly recommended when using 
{cmd:cmed simulate}; otherwise, the wall time required for bootstrapping 
can be very long.

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
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1) $dvar = $cvars}
{p_end}

{pstd}
Estimate natural effects, including interactions
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1) $dvar = $cvars, cxd cxm}
{p_end}

{pstd}
Estimate natural effects, using ologit model for depvar
{p_end}
{phang2}
{cmd:. cmed sim ((ologit) $depvar) ((logit) $mvar1) $dvar = $cvars}
{p_end}

{pstd}
Estimate natural effects, using 1000 simulations
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1) $dvar = $cvars, nsim(1000)}
{p_end}

{pstd}
Estimate interventional effects through mvar2, adjusting for mvar1 as a 
post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((reg) $mvar2) ((logit) $mvar1) $dvar = $cvars}
{p_end}

{pstd}
Estimate controlled direct effects through mvar2, adjusting for mvar1 as a 
post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) $mvar2 ((logit) $mvar1) $dvar = $cvars, m(10.0)}
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) $mvar2 ((logit) $mvar1) $dvar = $cvars, m(10.5)}
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) $mvar2 ((logit) $mvar1) $dvar = $cvars, m(11.0)}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1 (reg) $mvar2) $dvar = $cvars}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1 (reg) $mvar2) $dvar = $cvars, paths}
{p_end}

{pstd}
Specify the number of bootstrap replications, using 1000 simulations
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1 (reg) $mvar2) $dvar = $cvars, paths nsim(1000) reps(1000)}
{p_end}

{pstd}
Parallelize the bootstrap replications
{p_end}
{phang2}
{cmd:. cmed sim ((reg) $depvar) ((logit) $mvar1 (reg) $mvar2) $dvar = $cvars, paths nsim(1000) reps(1000) parallel}
{p_end}


{...}
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmed simulate} stores in {cmd:e()} the results of 
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