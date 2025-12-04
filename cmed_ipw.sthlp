{smcl}
{* *! version 0.5.0  04dec2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_ipw##syntax"}{...}
{viewerjumpto "Description" "cmed_ipw##description"}{...}
{viewerjumpto "Options" "cmed_ipw##options"}{...}
{viewerjumpto "Examples" "cmed_ipw##examples"}{...}
{viewerjumpto "Stored results" "cmed_ipw##results"}{...}
{viewerjumpto "References" "cmed_ipw##references"}{...}
{viewerjumpto "Support" "cmed_ipw##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed ipw} {hline 2} {...}
Causal mediation analysis using inverse probability weighting


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
{cmd:ipw}
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
{cmd:ipw}
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
{cmd:ipw}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{opt paths:pecific} 
[{it:options}]


{pstd}
Interventional effects through a single mediator with a discrete post-treatment 
confounder

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{cmd:(}[{cmd:(}{it:mmodel}{cmd:)}] {help varname:{it:mvar}}{cmd:)}
{cmd:(}{cmd:(}{it:lmodel}{cmd:)} {help varname:{it:lvar}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
[{cmd:,} {it:options}]


{pstd}
Controlled direct effects with a single mediator

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{cmd:(}[{cmd:(}{it:mmodel}{cmd:)}] {help varname:{it:mvar}}{cmd:)}
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
is a mediator of interest. Only one mediator is allowed for estimating 
interventional and controlled direct effects. 
{p_end}
{...}
{phang}
{it:lvar}
is a post-treatment confounder (exposure-induced confounder).  
Only one binary or ordinal {it:lvar} is allowed for estimating 
interventional effects.
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
{phang}
{it:mmodel} is one of {cmdab:reg:ress} (default), {cmd:logit}, or {cmd:poisson}
{p_end}
{...}
{phang}
{it:lmodel} is one of {cmd:logit} or {cmd:ologit} 
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
{synopt:{opt censor(numlist)}}
censor the inverse probability weights at the percentiles supplied in numlist
{p_end}
{...}
{synopt:{opt nointer:action}}
do not include interaction between mediator and treatment 
when estimating controlled direct effects
{p_end}
{...}
{synopt:{opt cxd}}
include interactions between baseline confounders (if specified) and treatment 
in mediator model when estimating interventional or controlled direct effects
{p_end}
{...}
{synopt:{opt lxd}}
include interactions between post-treatment confounders (if specified) 
and treatment in mediator model when estimating interventional or 
controlled direct effects
{p_end}
{...}
{synopt:{opt detail}}
print the fitted models used to construct the inverse probability weights 
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
{cmd:cmed ipw} estimates the natural direct and indirect effects 
of a binary treatment (exposure) on an outcome using inverse probability
weights constructed from logit models for the treatment. When multiple mediators 
are specified, the command estimates multivariate natural effects using 
weights that are also constructed from logit models for the treatment. 
If a single, discrete post-treatment confounder is specified, the command 
estimates interventional direct and indirect effects using weights constructed
from a logit model for treatment and models for both the mediator and
post-treatment confounder. Optionally, the command estimates path-specific 
effects through a set of causally ordered mediators as well as controlled 
direct effects with a single mediator. Standard errors and confidence intervals 
are obtained using the nonparametric {help bootstrap}. 

{pstd}
In the simplest case with one mediator and no post-treatement confounders, 
{cmd:cmed ipw} estimates the natural direct and indirect effects,
along with the total effect, of a binary treatment by fitting two models:

{phang2}
(1) a logit model for treatment with the baseline confounders as predictors
{p_end}
{phang2}
(2) another logit model for treatment with the mediator and the baseline 
confounders as predictors
{p_end}

{pstd}
The models are used to construct inverse probability weights, which 
subsequently serve to estimate the natural direct and indirect effects of 
interest. The estimated effects have a causal interpretation provided that 
the logit models for treatment are correctly specified and the following 
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
When more than one mediator is specified, {cmd:cmed ipw} estimates 
multivariate natural direct and indirect effects by including all mediators 
as predictors in Model 2 above, in addition to the baseline confounders. 
Inverse probability weights are then constructed from the treatment models 
and used to estimate multivariate natural effects. The estimated effects 
in this case have a causal interpretation if both treatment models are 
correctly specified, assumption {bf:A1} holds, and assumptions 
{bf:A2}-{bf:A4} hold with respect to all the mediators under consideration. 
If the mediators are specified in causal order, option 
{helpb cmed_ipw##pathspecific:pathspecific} can be used to estimate 
path-specific effects using inverse probability weighting. To have a causal 
interpretation, these estimates additionally require that there are no 
unobserved or exposure-induced confounders for any of the mediator-mediator 
relationships.

{pstd}
When a single, discrete post-treatment confounder is specified, 
{cmd:cmed ipw} uses inverse probability weighting to estimate interventional 
direct and indirect effects that operate through a single, focal mediator. 
To construct the weights in this case, {cmd:cmed ipw} fits three models:

{phang2}
(1b) a logit model for treatment conditional on the baseline 
confounders, as above
{p_end}
{phang2}
(2b) a logit or ologit model for the post-treatment confounder with the 
treatment and baseline confounders as predictors
{p_end}
{phang2}
(3b) a linear, logit, or poisson model for the mediator with the 
treatment, baseline confounders, and post-treatment confounder as predictors
{p_end}

{pstd}
The estimated interventional effects have a causal interpretation if all these 
models are correctly specified and assumptions {bf:A1}-{bf:A3} hold.

{pstd}
With a single mediator, option {helpb cmed_linear##mvalue:mvalue} can 
be used for estimating controlled direct effects. The weights used to estimate
these effects are constructed from Models 1b and 3b above. Analyses of
controlled direct effects may include any number and type of post-treatment 
confounders, all of which are included as predictors in the model for the 
mediator. The analysis can also omit post-treatment confounders if none 
require adjustment, in which case the mediator model would include only 
treatment and the baseline confounders as predictors. The estimates of 
controlled direct effects have a causal interpretation provided that the 
models used to construct the weights are correctly specified and 
assumptions {bf:A1}-{bf:A2} hold.

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
capture the unique explanatory role of each mediator, net of the other mediators 
that precede it in causal order. 

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
allows the user to specify the alternative level of treatment. The default is 0.
d - dstar defines the treatment contrast evaluated for all estimated effects.
Only binary treatments are allowed with {cmd:cmed ipw}.

{dlgtab:Models}

{phang}
{opt censor(numlist)}
censors the inverse probability weights at the percentiles supplied in numlist. 
For example, {opt censor(1 99)} censors the weights at their 1st and 99th 
percentiles -- that is, it bottom codes very small weights at the 1st percentile 
and top codes very large weights at the 99th percentile. Censoring the weights
a tiny amount often improves the stability of estimates without compromising
their accuracy.

{phang}
{opt nointeraction}
is only allowed with a single mediator and when option {opt mvalue(#)} is 
also specified. This option excludes an interaction between the mediator 
and treatment in a weighted outcome model used to estimate the controlled 
direct effect. An interaction between the mediator and treatment is included 
by default.

{phang}
{opt cxd}
is only allowed if post-treatment confounders are specified or if option 
{opt mvalue(#)} is specified. This option includes all two-way interactions 
between the baseline confounders (if specified) and treatment in the model
for the mediator when estimating interventional or controlled direct effects.

{phang}
{opt lxd}
is only allowed if post-treatment confounders are specified. This option 
includes all two-way interactions between the post-treatment confounders
and treatment in the model for the mediator when estimating interventional 
or controlled direct effects.

{phang}
{opt detail}
prints output from each fitted model used to construct the inverse probability
weights. When this option is omitted, only the estimated causal effects are 
reported.

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
{cmd:. cmed ipw $depvar $mvar1 $dvar = $cvars}
{p_end}

{pstd}
Estimate natural direct and indirect effects through mvar1, censoring the 
weights
{p_end}
{phang2}
{cmd:. cmed ipw $depvar $mvar1 $dvar = $cvars, censor(1 99)}
{p_end}

{pstd}
Estimate controlled direct effects, controlling mvar1
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((logit) $mvar1) $dvar = $cvars, censor(1 99) m(1)}
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((logit) $mvar1) $dvar = $cvars, censor(1 99) m(0)}
{p_end}

{pstd}
Estimate interventional effects through mvar2, adjusting for mvar1 as a 
post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((regress) $mvar2) ((logit) $mvar1) $dvar = $cvars, 
censor(1 99)}
{p_end}

{pstd}
Estimate controlled direct effects, controlling mvar2 and adjusting for mvar1 
as a post-treatment confounder
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((regress) $mvar2) ($mvar1) $dvar = $cvars, censor(1 99) m(10.0)}
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((regress) $mvar2) ($mvar1) $dvar = $cvars, censor(1 99) m(10.5)}
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ((regress) $mvar2) ($mvar1) $dvar = $cvars, censor(1 99) m(11.0)}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ($mvar1 $mvar2) $dvar = $cvars, censor(1 99)}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ($mvar1 $mvar2) $dvar = $cvars, censor(1 99) paths}
{p_end}

{pstd}
Specify the number of bootstrap replications
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ($mvar1 $mvar2) $dvar = $cvars, censor(1 99) paths reps(1000)}
{p_end}

{pstd}
Parallelize the bootstrap replications
{p_end}
{phang2}
{cmd:. cmed ipw $depvar ($mvar1 $mvar2) $dvar = $cvars, censor(1 99) paths reps(1000) parallel}
{p_end}



{...}
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmed ipw} stores in {cmd:e()} the results of 
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