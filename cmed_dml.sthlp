{smcl}
{* *! version 0.3.1  09mar2026}{...}
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
is a binary treatment (exposure). 
{p_end}
{...}
{phang}
{it:cvars}
are baseline confounders (pre-treatment confounders).
{p_end}

{...}
{marker method}{...}
{phang}
{it:method}
is one of {opt rforest} or {opt lasso}
{p_end}


{...}
{*  ___________________________________________________  Options short }{...}
{...}
{...}
{synoptset 36 tabbed}{...}
{synopthdr:options}
{synoptline}
{...}
{syntab:Effects}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{opt d(#)}}specify alternative level of {it:dvar}; 
default is 1
{p_end}
{...}
{synopt:{opt dstar(#)}}specify reference level of {it:dvar}; 
default is 0
{p_end}

{syntab:Models}
{synopt:{cmd:method(}{it:method}[{cmd:,} {it:method_options}]{cmd:)}}use 
machine learning method {it:method} to estimate the nuisance terms
{p_end}
{...}
{synopt:{cmd:censor(}{it:#1} {it:#2}{cmd:)}}censor the inverse probability 
and/or ratio-of-mediator-probability weights at the {it:#1}th and {it:#2}th percentiles
{p_end}
{...}
{synopt:{opt rmpw}}use an estimator that involves ratio-of-mediator-probability weighting
{p_end}
{...}
{synopt:{opt xfits(#)}}specify the number of folds for repeated cross-fitting;
default is 5.
{p_end}
{...}
{synopt:{opt seed(#)}}set random number seed to {it:#}
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
of a binary treatment (exposure) on an outcome using de-biased machine learning 
with either random forests or least absolute shrinkage and selection operator (LASSO) models. 
When multiple mediators are specified, 
the command estimates multivariate natural effects and, optionally, path-specific effects
through a set of causally ordered mediators. 
Asymptotic standard errors and confidence intervals are obtained
from the efficient influence function of the targeted estimand.

{pstd}
{cmd:cmed dml}
is based on the same multiply robust estimators implemented in {helpb cmed mr},
but instead of predicting the nuisance components from parametric models 
such as linear or logistic regressions, it uses machine learning models 
to provide additional protection against model misspecification.

{pstd}
In the simplest case with one mediator, 
{cmd:cmed dml} estimates the natural direct, indirect, and total effects
using de-biased machine learning by training models to estimate the
following nuisance terms:

{phang2}
(1) the conditional probability of the treatment 
given the baseline confounders
{p_end}
{phang2}
(2) the conditional probability of the treatment 
given the baseline confounders and the mediator
{p_end}
{phang2}
(3) the conditional expected value of the outcome 
given the treatment, mediator, and baseline confounders
{p_end}
{phang2}
(4) an iterated expectation of the outcome 
under the reference level of the treatment, 
conditional on the treatment and baseline confounders
{p_end}

{pstd}
Estimates of these nuisance terms are obtained 
using random forests, when {cmd:method(rforest)} is specified,
or using LASSO models with automatic inclusion of all two-way interactions among predictors 
when {cmd:method(lasso)} is specified.

{pstd}
To avoid over-fitting and ensure valid inference, 
the nuisance terms are estimated using a repeated cross-fitting procedure. 
This procedure randomly splits the data into several folds, 
trains the machine learning models on all but one fold, 
and then uses the held-out fold to estimate the nuisance terms. 
After iterating through all folds, 
every observation in the sample has estimates for the required nuisance terms. 
These estimates are then plugged into a multiply robust estimator 
for the natural direct and indirect effects. 
The estimator combines inverse probability weighting 
and regression imputation to obtain the quantities of interest.

{pstd}
The estimated effects have a causal interpretation 
provided that the machine learning models used to estimate the nuisance terms 
converge to these quantities at a rate faster than {it:n}^(1/4), 
where {it:n} is the sample size.
While parametric models, such as linear or logistic regressions, 
may fail under misspecification, 
both random forests and LASSO models are flexible enough 
that the condition can, in principle, be satisfied.

{pstd}
In addition to satisfying the convergence rate, 
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
({bf:A4}) There are no post-treatment confounders of the mediator-outcome relationship.
{p_end}

{pstd}
When more than one mediator is specified, 
{cmd:cmed dml} estimates multivariate natural direct and indirect effects
by including all mediators in the machine learning models 
for estimating (2) and (3) above. 
These estimated effects have a causal interpretation 
provided that the machine learning models used to estimate the nuisance terms 
converge to these quantities at a rate faster than {it:n}^(1/4), 
assumption {bf:A1} holds, and assumptions {bf:A2}-{bf:A4} hold 
with respect to all mediators under consideration. 

{pstd}
When option {helpb cmed_dml##pathspecific:pathspecific} is specified, 
{cmd:cmed dml} estimates path-specific effects of multiple mediators. 
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
by training machine learning models to estimate the nuisance terms 
described in (1) and (3) above. 
Additionally, {cmd:cmed dml} trains a machine learning model to estimate 
the conditional probability of the mediator 
given the treatment and baseline confounders.
The estimated effects have a causal interpretation 
provided that the machine learning models used to estimate the nuisance terms 
converge to these quantities at a rate faster than {it:n}^(1/4) 
and assumptions {bf:A1}–{bf:A4} hold.

{pstd}
{cmd:cmed dml} does not support post-treatment confounders 
or estimation of interventional or controlled direct effects at this time.

{pstd}
See {help cmed_dml##references:Wodtke and Zhou (2026)} for a detailed
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
The difference, {opt d()} - {opt dstar()} defines the treatment contrast 
evaluated for all estimated effects.

{phang}
{opt dstar(#)}
specifies the reference or control level of {it:dvar}. 
The default reference level is 0.
The difference, {opt d()} - {opt dstar()} defines the treatment contrast 
evaluated for all estimated effects.

{dlgtab:Models}

{phang}
{cmd:method(}{it:method}[{cmd:,} {it:method_options}]{cmd:)}
specifies the type of machine learning model 
used to estimate the nuisance terms. 
The following {it:method}s are supported:

{p2colset 12 24 24 4}{...}
{p2col:{cmd:rforest}}uses random forest algorithms; 
requires {helpb rforest} from {help ssc:SSC}
{p_end}
{p2col:{cmd:lasso}}uses lasso-based algorithms; 
requires {helpb lasso2} from the {cmd:lassopack} package from {help ssc:SSC}

{phang2}
The lasso models include all two-way interactions 
and their regularization parameter is optimized using a grid search 
to find the value that minimizes the Akaike information criterion. 

{phang2}
Both {cmd:rforest} and {cmd:lasso} use the default settings 
of their respective underlying commands, 
but any options may be passed through as {it:method_options}. 

{phang}
{cmd:censor(}{it:#1} {it:#2}{cmd:)}
censors the inverse probability and/or ratio-of-mediator probability weights 
at the {it:#1}th and {it:#2}th percentiles, 
bottom-coding weights lower than the {it:#1}th percentile 
and top-coding weights larger than {it:#2}th percentile. 

{phang}
{opt rmpw}
implements an estimator that involves 
ratio-of-mediator-probability weighting 
and a machine learning model for the mediator. 
{opt rmpw}
is only allowed with a single binary mediator. 

{phang}
{opt xfits(#)}
specifies the number of folds to use for repeated cross-fitting.
The default is 5.

{phang}
{opt seed(#)}
specifies a seed to ensure reproducibility. This seed is passed to the 
cross-fitting algorithm to ensure reproducibility of the folds.


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
using random forest
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, method(rforest)}
{p_end}

{pstd}
Same as above
{p_end}
{phang2}
{cmd:. cmed dml (cesd_age40) (ever_unemp_age3539) (att22) = female black hispan famsize, method(rforest)}
{p_end}

{pstd}
Estimate natural direct and indirect effects using lasso
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, method(lasso)}
{p_end}

{pstd}
Estimate multivariate natural effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539} together;
parentheses required
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize, method(rforest)}
{p_end}

{pstd}
Estimate path-specific effects through 
{cmd:ever_unemp_age3539} and {cmd:log_faminc_adj_age3539};
parentheses required
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 (log_faminc_adj_age3539 ever_unemp_age3539) att22 = female black hispan famsize, method(rforest) pathspecific}
{p_end}

{pstd}
Estimate natural effects, using a robust estimator with ratio-of-mediator-probability weights
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, method(lasso) rmpw}
{p_end}

{pstd}
Estimate natural effects, censoring the inverse probability weights in the 
multiply robust estimator
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, method(lasso) censor(1 99)}
{p_end}

{pstd}
Estimate natural effects, using random forest with 200 trees and a minimum 
leaf size of 10
{p_end}
{phang2}
{cmd:. cmed dml cesd_age40 ever_unemp_age3539 att22 = female black hispan famsize, method(rforest, iterations(200) lsize(10))}
{p_end}


{...}
{marker results}{...}
{title:Stored results}
{p2colset 5 19 21 2}{...}

{pstd}
{cmd:cmed dml} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:e(b)}}row vector of point estimates{p_end}
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
German Centre for Higher Education Research and Science Studies{break}
Email: klein@dzhw.eu

