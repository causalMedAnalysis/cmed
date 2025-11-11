{smcl}
{* *! version 0.4.0  11nov2025}{...}
{vieweralsosee "[CAUSAL] mediate" "help mediate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[CAUSAL] teffects" "help teffects"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[SEM] sem" "help sem command"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[COMMUNITY-CONTRIBUTED] cmed" "help cmed"}{...}
{viewerjumpto "Syntax" "cmed_impute##syntax"}{...}
{viewerjumpto "Description" "cmed_impute##description"}{...}
{viewerjumpto "Options" "cmed_impute##options"}{...}
{viewerjumpto "Examples" "cmed_impute##examples"}{...}
{viewerjumpto "Stored results" "cmed_impute##results"}{...}
{viewerjumpto "References" "cmed_impute##references"}{...}
{viewerjumpto "Support" "cmed_impute##support"}{...}
{bf:[COMMUNITY-CONTRIBUTED] cmed impute} {hline 2} {...}
Causal mediation analysis using imputation


{...}
{marker syntax}{...}
{title:Syntax}

{pstd}
Pure regression imputation, single mediator

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{help varlist:{it:mvar}}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Pure regression imputation, multiple mediators

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{help varname:{it:dvar}}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Imputation-based weighting

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{cmd:(}{help varlist:{it:mvars}}{cmd:)}
{cmd:(}{cmd:(logit)} {help varname:{it:dvar}}{cmd:)}
[{cmd:=} {help varlist:{it:cvars}}]
{ifin} 
{weight}
[{cmd:,} {it:options}]


{pstd}
Controlled direct effect

{p 8 16 2}
{cmd:cmed}
{cmdab:imp:ute}
{cmd:(}[{cmd:(}{it:ymodel}{cmd:)}] {depvar}{cmd:)}
{help varname:{it:mvar}}
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
is a mediator of interest.  
Only one mediator is allowed for estimating controlled direct effects.
{p_end}
{...}
{phang}
{it:dvar} 
is the treatement (exposure). 
The treatment must be binary for imputation-based weighting. 
{p_end}
{...}
{phang}
{it:cvars}
are baseline confounders.
{p_end}

{...}
{phang}
{it:ymodel} is one of {cmdab:reg:ress} (default) or {cmd:logit}; 
{it:ymodel} may be {cmd:poisson} for controlled direct effects.


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
