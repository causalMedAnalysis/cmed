{smcl}
{* *! version 0.8.0  04jan2026}{...}
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

{...}
{phang}
{it:depvar}
is the outcome of interest.
{p_end}
{...}
{phang}
{it:mvar} 
is a mediator of interest.
Only one mediator is allowed when estimating interventional and controlled 
direct effects.
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
{p_end}

{phang}
{it:ymodel}, {it:mmodel}, and {it:lmodel}
are one of 
{cmdab:reg:ress} (default), 
{cmd:logit}, 
{cmd:poisson}, 
or {cmd:ologit}.
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
between mediator(s) and treatment in the outcome model
{p_end}
{...}
{synopt:{opt cxd}}include interactions between baseline confounders 
(if specified) and treatment in all relevant models
{p_end}
{...}
{synopt:{opt cxm}}include interactions between baseline confounders 
(if specified) and mediator(s) in the outcome model
{p_end}
{...}
{synopt:{opt lxm}}include interactions between post-treatment confounders 
(if specified) and mediator in the outcome model
{p_end}

{syntab:Simulations}
{synopt:{opt nsim(#)}}
specify the number of simulated values to generate; default is 200
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
{synopt:{opt detail}}print fitted models used to generate simulations
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
In the simplest case with one mediator and no post-treatment confounders, 
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
the baseline confounders, and all subsequent mediators included as predictors
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
If the mediators are specified in reverse causal order, such that 
the first mediator supplied is the final mediator in the causal sequence,
followed by the next-to-last mediator, and so on, then option 
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
with treatment, the baseline confounders, and all subsequent post-treatment 
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
option {helpb cmed_simulate##mvalue:mvalue} can be used to estimate 
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
This option may only be specified with a single mediator
and at least one post-treatment confounder. 

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
(if specified) and treatment in models for the mediator(s), outcome, and 
post-treatment confounders (if specified). These interactions are constructed 
after mean-centering the baseline confounders.

{phang}
{opt cxm}
includes all two-way interactions between the baseline confounders 
(if specified) and the mediator(s) in the outcome model. 
Interactions are constructed after mean-centering the baseline confounders.

{phang}
{opt lxm}
includes all two-way interactions between the post-treatment confounders 
(if specified) and the mediator(s) in the outcome model. 
Interactions are constructed after residualizing the post-treatment confounders 
with respect to treatment and the baseline confounders. 

{dlgtab:Simulations}

{phang}
{opt nsim(#)}
specifies the number of simulated values to generate. 
The default is 200. 
A larger number of simulated values improves the precision of the effect 
estimates but increases the wall time needed to compute them. 
For most applications, {help cmed##references:Wodtke and Zhou (2026)} recommend 
using at least 1000 simulations.

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
prints output from each fitted model used to generate the simulations.
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
{cmd:. cmed simulate cesd_age40 ((logit) ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed simulate (cesd_age40) ((logit) ever_unemp_age3539) (att22) = female black hispan famsize}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed simulate ((regress) cesd_age40) ((logit) ever_unemp_age3539) (att22) = female black hispan famsize}
{p_end}

{pstd}
Estimate natural direct and indirect effects
using an ordered logistic model for {cmd:cesd_age40} 
{p_end}
{phang2}
{cmd:. cmed simulate ((ologit) cesd_age40) ((logit) ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Estimate multivariate natural effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539} together
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 ((regress) log_faminc_adj_age3539 (logit) ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Estimate path-specific effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539}
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 ((regress) log_faminc_adj_age3539 (logit) ever_unemp_age3539) att22 = female black hispan famsize, pathspecific}
{p_end}

{pstd}
Estimate interventional effects through {cmd:log_faminc_adj_age3539}, 
treating {cmd:ever_unemp_age3539} as a post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 ((regress) log_faminc_adj_age3539) ((logit) ever_unemp_age3539) att22 = female black hispan famsize}
{p_end}

{pstd}
Estimate controlled direct effects through {cmd:log_faminc_adj_age3539}, 
adjusting for {cmd:ever_unemp_age3539} as a post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 log_faminc_adj_age3539 ((logit) ever_unemp_age3539) att22 = female black hispan famsize, mvalue(10.5)}
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 log_faminc_adj_age3539 ((logit) ever_unemp_age3539) att22 = female black hispan famsize, mvalue(11.0)}
{p_end}

{pstd}
Parallelize the bootstrap and increase number of replications and simulations
{p_end}
{phang2}
{cmd:. cmed simulate cesd_age40 ((logit) ever_unemp_age3539) att22 = female black hispan famsize, nsim(1000) reps(1000) parallel}
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
German Centre for Higher Education Research and Science Studies{break}
Email: klein@dzhw.eu

