*!TITLE: MRMED - causal mediation analysis using parametric multiply robust methods
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mrmed, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		type(string) ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		censor(numlist min=2 max=2) ///
		detail * ]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
		
	local mrtypes mr1 mr2
	local nmrtype : list posof "`type'" in mrtypes
	if !`nmrtype' {
		display as error "Error: type must be chosen from: `mrtypes'."
		error 198		
	}

	if ("`censor'" != "") {
		local censor1: word 1 of `censor'
		local censor2: word 2 of `censor'

		if (`censor1' >= `censor2') {
			di as error "The first number in the censor() option must be less than the second."
			error 198
		}

		if (`censor1' < 1 | `censor1' > 49) {
			di as error "The first number in the censor() option must be between 1 and 49."
			error 198
		}

		if (`censor2' < 51 | `censor2' > 99) {
			di as error "The second number in the censor() option must be between 51 and 99."
			error 198
		}
	}

	if ("`type'"=="mr1") {
	
		if (`num_mvars' > 1) {
			display as error "type(mr1) robust estimation only supports a single mediator"
			display as error "but `num_mvars' mediators --`mvars' -- have been specified."
			error 198
		}
	
		foreach i in `dvar' `mvars' {
			confirm variable `i'
			qui levelsof `i', local(levels)
			if "`levels'" != "0 1" & "`levels'" != "1 0" {
				display as error "The variable `i' is not binary and coded 0/1"
				error 198
			}
		}

		if ("`detail'"!="") {
			mr1med `yvar' if `touse', ///
				dvar(`dvar') mvar(`mvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
		}
			
		bootstrap ///
			ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
			NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
			NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
				`options' noheader notable: ///
					mr1med `yvar' if `touse', ///
						dvar(`dvar') mvar(`mvars') d(`d') dstar(`dstar') ///
						cvars(`cvars') `nointeraction' `cxd' `cxm' censor(`censor')
			
		estat bootstrap, p noheader

	}

	if ("`type'"=="mr2") {

		confirm variable `dvar'
		qui levelsof `dvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The variable `dvar' is not binary and coded 0/1"
			error 198
		}

		if ("`detail'"!="") {
			mr2med `yvar' `mvars' if `touse', ///
				dvar(`dvar') d(`d') dstar(`dstar') ///
				cvars(`cvars') `nointeraction' `cxd' `cxm'
		}	

		if (`num_mvars'==1) {
		
			bootstrap ///
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
					`options' noheader notable: ///
						mr2med `yvar' `mvars' if `touse', ///
							dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
							`nointeraction' `cxd' `cxm' censor(`censor')
		}

		if (`num_mvars'>=2) {
		
			bootstrap ///
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				MNDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				MNIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
					`options' noheader notable: ///
						mr2med `yvar' `mvars' if `touse', ///
							dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
							`nointeraction' `cxd' `cxm' censor(`censor')
		}
		
		estat bootstrap, p noheader

	}
		
end mrmed
