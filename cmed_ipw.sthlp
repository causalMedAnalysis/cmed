{smcl}
{* *! version 0.3.0  12oct2025}{...}
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
{marker syntax}{...}
{title:Syntax}

{pstd}
Single mediator, logit model for treatment

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{help varname:{it:mvar}}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
{weight}
[ {cmd:,} {it:options} ]


{pstd}
Multiple mediators, logit model for treatment

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
{weight}
[ {cmd:,} {it:options} ]


{pstd}
Controlled direct effect, binary mediator, optional post-treatment covariates

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{cmd:(}{cmd:(logit)} {help varname:{it:mvar}}{cmd:)}
[
{cmd:(}{help varlist:{it:lvars}}{cmd:)}
]
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
{weight}
{cmd:,} 
{opt m:value(#)} 
[ {it:options} ]


{pstd}
Interventional effects, single post-treatment covariate

{p 8 16 2}
{cmd:cmed}
{cmd:ipw}
{depvar}
{cmd:(}[{cmd:(}{it:mmodel}{cmd:)}] {help varname:{it:mvar}}{cmd:)}
{cmd:(}{cmd:(}{it:lmodel}{cmd:)} {help varname:{it:lvar}}{cmd:)}
{help varname:{it:dvar}}
[ 
{cmd:=} {help varlist:{it:cvars}}
]
{ifin} 
{weight}
{cmd:,} 
{opt m:value(#)}
[ {it:options} ]


{...}
{phang}
{it:depvar}
is the outcome of interest.
{p_end}
{...}
{phang}
{it:mvar} 
is a mediator of interest. 
Only one binary mediator is allowed for estimating 
controlled direct effects.
{p_end}
{...}
{phang}
{it:lvar}
is a post-treatment covariate (exposure-induced confounder).  
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
are baseline confounders.
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
{synoptset 32 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{opt m:value(#)}}estimate controlled direct effects at {it:mvar}={it:#}
{p_end}
{...}
{synopt:{it:...}}any options are passed thru
{p_end}
{...}
{synoptline}
{p 4 6 2}
{cmd:pweight}s are allowed; see {help weight}.
{p_end}


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
