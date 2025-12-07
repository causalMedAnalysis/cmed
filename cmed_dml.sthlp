{smcl}
{* *! version 0.2.0  6dec2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_dml##syntax"}{...}
{viewerjumpto "Description" "cmed_dml##description"}{...}
{viewerjumpto "Options" "cmed_dml##options"}{...}
{viewerjumpto "Examples" "cmed_dml##examples"}{...}
{viewerjumpto "Stored results" "cmed_dml##results"}{...}
{viewerjumpto "References" "cmed_dml##references"}{...}
{viewerjumpto "Support" "cmed_dml##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed dml} {hline 2} {...}
Causal mediation analysis using de-biased machine learning 


{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Natural effects through a single mediator

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
[{it:options}]


{pstd}
Multivariate natural effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
[{it:options}]


{pstd}
Path-specific effects through multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} 
{cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
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
Multiple mediators are allowed.
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
{phang}
{it:method}
is one of {opt rforest} or {opt lasso}
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
{synopt:{opt d(#)}}specify reference level of treatment; default is 1
{p_end}
{...}
{synopt:{opt dstar(#)}}specify alternative level of treatment; default is 0
{p_end}

{syntab:Models}
{synopt:{opt method(method)}}use machine learning algorithm {it:method} 
to estimate the nuisance terms
{p_end}
{...}
{synopt:{opt rmpw}}use an estimator that involves 
ratio-of-mediator-probability weighting
{p_end}
{...}
{synopt:{opt censor(numlist)}}censor the inverse probability and/or 
ratio-of-mediator-probability weights at the percentiles supplied in numlist
{p_end}
{...}
{synopt:{opt xfits(#)}}specify the number of folds for repeated cross-fitting;
default is 5.
{p_end}
{...}
{synopt:{opt seed(#)}}specify a seed to ensure reprodicibility.
{p_end}

{synoptline}



{...}
{*  ____________________________________________________  Description }{...}
{...}
{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:cmed dml} estimates the natural direct and indirect effects
of a binary treatment (exposure) on an outcome using de-biased machine
learning with either random forests or least absolute shrinkage and selection
operator (LASSO) models. The command is based on the same multiply robust 
estimators employed by {helpb cmed mr}, but rather than predict the 
nuisance terms in these estimators from parametric models, like linear and 
logistic regressions, it predicts them using machine learning models instead.
This can provide an added layer of protection against concerns about model 
misspecification. When multiple mediators are specified, {cmd:cmed dml}
estimates multivariate natural effects and, optionally, path-specific effects
through a set of causally ordered mediators. Asymptotic standard errors and
confidence intervals are derived from the efficient influence function for
the targeted estimand.

{pstd}
With one or more mediators, {cmd:cmed dml} constructs de-biased 
machine learning estimates of natural direct and indirect effects, as well as
the total effect, by training machine learning models to estimate the
following nuisance terms:

{phang2}
(1) the conditional probability of treatment given the baseline confounders
{p_end}
{phang2}
(2) the conditional probability of treatment given the baseline confounders
and the mediator(s)
{p_end}
{phang2}
(3) the conditional expected value of the outcome given the treatment,
mediator(s), and baseline confounders
{p_end}
{phang2}
(4) an iterated expectation of the outcome under the reference level of
treatment, conditional on the treatment and the baseline confounders
{p_end}

{pstd}
Estimates of these nuisance terms can be obtained from a series of random
forests if {opt method(rforest)} is specified. Alternatively, they can be
obtained from a set of LASSO models that automatically include all two-way
interactions among the predictors when {opt method(lasso)} is specified.
The command depends on the {helpb rforest} and {helpb lassopack} modules 
for training these models.

{pstd}
To avoid over-fitting and ensure valid inference, the nuisance terms 
are estimated in conjunction with a repeated cross-fitting procedure. 
Repeated cross-fitting works by randomly splitting the data into several 
folds, repeatedly training the machine learning models on all but one fold, 
and then using the held-out fold to estimate the nuisance terms. After 
iterating through every fold, all observations in the sample have estimates 
for the required nuisance terms. These estimates are then plugged into a 
multiply robust estimator for natural direct and indirect effects to obtain 
the quantities of interest. This estimator involves a combination of inverse 
probability weighting and regression imputation.

{pstd}
The estimated effects have a causal interpretation under a set of modeling and
identification assumptions. The modeling assumptions require that the machine
learning models used to estimate the nuisance terms converge to these
quantities at a rate faster than {it:n} (the sample size) to the one-fourth 
power, a condition that both random forests and LASSO models can satisfy. 
The identification assumptions stipulate that the following conditions hold:

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
When more than one mediator is specified, {cmd:cmed dml} estimates
multivariate natural direct and indirect effects. The estimated effects in this
case have a causal interpretation under the same modeling conditions outlined
above, provided that assumption {bf:A1} holds and that assumptions
{bf:A2}–{bf:A4} hold for all mediators under consideration. If the mediators
are specified in causal order, option
{helpb cmed_dml##pathspecific:pathspecific} can be used to estimate
path-specific effects as well. To have a causal interpretation, these
estimates additionally require that there are no unobserved or
exposure-induced confounders for any of the mediator–mediator
relationships.

{pstd}
Alternatively, with a single binary mediator, option
{helpb cmed_dml##rmpw:rmpw} can be used to implement a different 
multiply robust estimator. This estimator involves a combination of 
ratio-of-mediator-probability weighting and regression imputation. 
In this case, estimates of the natural direct and indirect effects through 
a binary mediator are constructed by training machine learning models to 
estimate the following nuisance terms:

{phang2}
(1b) the conditional probability of treatment given the baseline confounders
{p_end}
{phang2}
(2b) the conditional probability of the mediator given the baseline confounders
and treatment
{p_end}
{phang2}
(3b) the conditional expected value of the outcome given the treatment,
mediator, and baseline confounders
{p_end}

{pstd}
As before, estimates of these nuisance terms are obtained via cross-fitting a
series of random forests or LASSO models, depending on the specification of
{opt method(method)}. These estimates are then plugged into the multiply
robust estimator to obtain the effects of interest. The estimated effects in
this case have a causal interpretation provided that assumptions
{bf:A1}–{bf:A4} hold and that the machine learning models converge 
at a rate faster than {it:n} to the one-fourth power.

{pstd}
See {help cmed_dml##references:Wodtke and Zhou (2026)} for a detailed
discussion.

{pstd}
{cmd:cmed dml} does not support post-treatment confounders or estimation
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
{opt d(#)}
allows the user to specify the reference level of treatment. The default is 1.

{phang}
{opt dstar(#)}
allows the user to specify the alternative level of treatment. The default 
is 0. d - dstar defines the treatment contrast evaluated for all estimated 
effects. Only binary treatments are allowed with {cmd:cmed dml}.

{dlgtab:Models}

{phang}
{opt method(method)}
specifies the type of machine learning model used to estimate the 
nuisance terms; {opt method(rforest)} implements random forests 
trained with the {helpb rforest} module, while {opt method(lasso)} uses 
LASSO models trained with the {helpb lassopack} module. The random forests
are autmatically trained with the default settings of {cmd:rforest}, but any 
options for this command can be passed through. The LASSO models 
automatically include all two-way interactions and their regularization 
parameter is optimized using a grid search to find the value that minimizes 
the Akaike information criterion. Any options for the {cmd:lasso2} command
can be passed through.

{phang}
{opt rmpw}
is only allowed with a single binary treatment. This option implements an 
alternative estimator that involves ratio-of-mediator-probability weighting 
and a machine learning model for the mediator.

{phang}
{opt censor(numlist)}
censors the inverse probability and/or ratio-of-mediator probability weights
required for de-biased machine learning estimation of mediation effects at the 
percentiles supplied in numlist. For example, {opt censor(1 99)} censors 
the weights at their 1st and 99th percentiles -- that is, it bottom codes 
very small weights at the 1st percentile and top codes very large weights at 
the 99th percentile. Censoring the weights a tiny amount often improves the 
stability of estimates without compromising their accuracy.

{phang}
{opt xfits(#)}
specifies the number of folds to use for repeated cross-fitting.
The default is 5.

{phang}
{opt seed(#)}
specifies a seed to ensure reprodicibility. The default is 
12345. This seed is passed to both the cross-fitting algorithm to ensure 
reproducibility of the folds and to the random forest algorithm, 
if {opt method(rforest)} is specified, to ensure the reproducibility of 
its estimates as well.


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
Estimate natural direct and indirect effects through mvar1, using the LASSO
with default settings
{p_end}
{phang2}
{cmd:. cmed dml $depvar $mvar1 $dvar = $cvars, method(lasso)}
{p_end}

{pstd}
Estimate natural effects, using random forests with default settings
{p_end}
{phang2}
{cmd:. cmed dml $depvar $mvar1 $dvar = $cvars, method(rforest)}
{p_end}

{pstd}
Estimate natural effects, using random forests with 200 trees and a minimum 
leaf size of 10
{p_end}
{phang2}
{cmd:. cmed dml $depvar $mvar1 $dvar = $cvars, method(rforest, iter(200) lsize(10))}
{p_end}

{pstd}
Estimate natural effects, censoring the inverse probability weights in the 
multiply robust estimator
{p_end}
{phang2}
{cmd:. cmed dml $depvar $mvar1 $dvar = $cvars, method(lasso) censor(1 99)}
{p_end}

{pstd}
Estimate natural effects, using a robust estimator with ratio-of-mediator-probability weights
{p_end}
{phang2}
{cmd:. cmed dml $depvar $mvar1 $dvar = $cvars, method(lasso) rmpw}
{p_end}

{pstd}
Estimate multivariate natural effects through mvar1 and mvar2 together
{p_end}
{phang2}
{cmd:. cmed dml $depvar ($mvar1 $mvar2) $dvar = $cvars, method(lasso)}
{p_end}

{pstd}
Estimate path-specific effects through mvar1 and mvar2
{p_end}
{phang2}
{cmd:. cmed dml $depvar ($mvar1 $mvar2) $dvar = $cvars, method(lasso) paths}
{p_end}


{...}
{marker results}{...}
{title:Stored results}
{p2colset 5 19 21 2}{...}

{pstd}
{cmd:cmed dml} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:e(est)}}row vector of point estimates{p_end}
{synopt:{cmd:e(se)}}row vector of standard errors{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}


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