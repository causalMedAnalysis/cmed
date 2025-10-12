{smcl}
{* *! version 0.3.0  12oct2025}{...}
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
{marker syntax}{...}
{title:Syntax}

{pstd}
Single mediator, linear models for mediator and outcome

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
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
Multiple mediators, linear models for mediators and outcome

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
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
Controlled direct effect

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{help varname:{it:mvar}}
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
Interventional effects, post-treatment covariates, linear models

{p 8 16 2}
{cmd:cmed}
{cmdab:lin:ear}
{depvar}
{help varname:{it:mvar}}
{cmd:(}{help varname:{it:lvars}}{cmd:)}
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
is the continuous outcome of interest.
{p_end}
{...}
{phang}
{it:mvar} 
is a continuous mediator of interest.
Only one mediator is allowed for estimating
controlled direct effects. 
{p_end}
{...}
{phang}
{it:lvar}
is a continuous post-treatment covariate (exposure-induced confounder).  
Multiple post-treatment covariates are allowed.
{p_end}
{...}
{phang}
{it:dvar} 
is the treatment (exposure).
{p_end}
{...}
{phang}
{it:cvars} 
are baseline confounders. 


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
