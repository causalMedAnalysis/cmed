{smcl}
{* *! version 0.4.0  11nov2025}{...}
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
{marker syntax}{...}
{title:Syntax}

{pstd}
Single mediator, linear models for mediator and outcome

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{depvar}
{help varname:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Single mediator, generalized linear models

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{cmd:(}{it:ymodel}{cmd:)} {depvar}{cmd:)}
{cmd:(}{cmd:(}{it:mmodel}{cmd:)} {help varname:{it:mvar}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Interventional effects, post-treatment covariates

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}{it:mspec}{cmd:)} 
{cmd:(}{it:lspec}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Controlled direct effect

{p 8 16 2}
{cmd:cmed}
{cmdab:sim:ulate}
{cmd:(}{it:yspec}{cmd:)} 
{cmd:(}{it:mspec}{cmd:)} 
{cmd:(}{it:lspec}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
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
is the mediator of interest.
Only one mediator is allowed. 
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
{p_end}

{...}
{phang}
{it:ysepc} 
is 
[{cmd:(}{it:ymodel}{cmd:)}] {it:depvar}
{p_end}
{...}
{phang}
{it:msepc} 
is 
[{cmd:(}{it:mmodel}{cmd:)}] {it:mvar}
{p_end}
{...}
{phang}
{it:lsepc} 
is 
[{cmd:(}{it:lmodel}{cmd:)}]  {it:lvars} 
[{cmd:(}{it:lmodel}{cmd:)} {it:lvars}] {it:...}
{p_end}

{phang}
{it:ymodel}, {it:mmodel}, {it:lmodel}
are one of {cmdab:reg:ress} (default), {cmd:logit}, or {cmd:poisson}
{p_end}

{phang}
{it:lvars} 
are post-treatment covariates (exposure-induced confounders).
{p_end}


{...}
{synoptset 32 tabbed}{...}
{synopthdr:options}
{synoptline}
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
