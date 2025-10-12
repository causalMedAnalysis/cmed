{smcl}
{* *! version 0.3.0  12oct2025}{...}
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
Causal mediation analysis using multiply robust estimators


{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Single binary mediator

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{cmd:(}{cmd:(logit)} {help varlist:{it:mvar}}{cmd:)}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
[ {cmd:,} {it:options} ]


{pstd}
Multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
[ {cmd:,} {it:options} ]


{pstd}
De-biased machine learning

{p 8 16 2}
{cmd:cmed}
{cmd:mr}
{depvar}
{cmd:(}{it:mspec}{cmd:)}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
{cmd:,} {cmd:dml(}{it:dmlmodel}[{cmd:,} {it:dml_options}]{cmd:)}
[ {it:options} ]


{...}
{phang}
{it:depvar}
is the continuous outcome of interest.
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
is the binary treatement (exposure). 
{p_end}
{...}
{phang}
{it:cvars}
are baseline confounders.
{p_end}

{...}
{phang}
{it:mspec} is one of {c -(}{cmd:(logit)} {it:mvar} {c |} {it:mvars}{c )-}
{p_end}
{...}
{phang}
{it:dmlmodel} is one of {cmd:rforest} or {cmd:lasso}
{p_end}


{...}
{synoptset 32 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{cmd:dml(}{it:model}[{cmd:,} {it:options}]{cmd:)}}use {it:model}
with {it:options} for de-biased machine learning
{p_end}
{...}
{synopt:{it:...}}any options are passed thru
{p_end}
{...}
{synoptline}


{...}
{marker description}{...}
{title:Description}


{...}
{marker options}{...}
{title:Options}


{...}
{marker examples}{...}
{title:Examples}


{...}
{marker results}{...}
{title:Stored results}


{...}
{marker references}{...}
{title:References}

{pstd}Wodtke GT, and Zhou X. Causal Mediation Analysis. In preparation. {p_end}


{...}
{marker support}{...}
{title:Support}

{pstd}
Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago

{pstd}
Email: wodtke@uchicago.edu
