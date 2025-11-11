{smcl}
{* *! version 0.1.0  11nov2025}{...}
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
Single mediator

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} {cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
[{it:options}]


{pstd}
Multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} {cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
[{it:options}]


{pstd}
Single binary mediator, ratio-of-mediator-probability weighting

{p 8 16 2}
{cmd:cmed}
{cmd:dml}
{depvar}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{cmd:,} {cmd:method(}{it:{help cmed_dml##method:method}}{cmd:)}
{opt rmpw} 
[{it:options}]


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
{phang}
{it:method}
is one of {opt rforest} or {opt lasso}
{p_end}


{...}
{synoptset 36 tabbed}{...}
{synopthdr:options}
{synoptline}
{p2coldent :* {cmd:method(}{it:{help cmed_dml##method:method}}[{cmd:,} {it:method_options}]{cmd:)}}use 
machine learning algorithm {it:method} to predict the nuisance terms
{p_end}
{synopt:{opt paths:pecific}}estimate path-specific effects
{p_end}
{...}
{synopt:{opt rmpw}}use ratio-of-mediator-probability weighting
{p_end}
{...}
{synopt:{it:...}}any options are passed thru
{p_end}
{...}
{synoptline}
{pstd}* {opt method()} is required
{p2colreset}{...}


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
