*!TITLE: PATHSIMBS - analysis of path-specific effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define pathsimbs, eclass properties(svyb)
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight iweight], ///
		dvar(varname numeric) ///
		mvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		mregs(string) ///
		[nsim(integer 200)] ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] 
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	local yvar `varlist'
	
	local num_mvars = wordcount("`mvars'")
	
	*loop over mediators in reverse order
	forv k=`num_mvars'(-1)1 {
		
		*select all mediators up to the mediator in question
		local mvars_include = ""
		local mregs_include = ""
		forv j=1/`k' {
			local mvars_include `mvars_include' `=word("`mvars'",`j')'
			local mregs_include `mregs_include' `=word("`mregs'",`j')'
		}
		
		*estimate natural effects
		mnesimbs `yvar' [`weight' `exp'] if `touse', ///
			dvar(`dvar') mvars(`mvars_include') cvars(`cvars') ///
			d(`d') dstar(`dstar') mregs(`mregs_include') yreg(`yreg') ///
			nsim(`nsim') `nointeraction' `cxd' `cxm'	
		
		* special case: only one total mediator
		if `num_mvars'==1 {
			scalar nde = _b[NDE]
			scalar nie = _b[NIE]
			scalar ate = _b[ATE]
		}
		
		* 2+ total mediators: last mediator
		if `num_mvars'>1 & `k'==`num_mvars' {
			scalar pse_DY = _b[MNDE]
			scalar prev_mnde = _b[MNDE]
		}
		
		* 2+ total mediators: first mediator
		if `num_mvars'>1 & `k'==1 {
			scalar pse_DM`=`k'+1'Y = _b[NDE] - prev_mnde
			scalar pse_DM1Y = _b[NIE]
			scalar ate = _b[ATE]
		}
		
		* 2+ total mediators: all other mediators
		if `num_mvars'>1 & !inlist(`k',1,`num_mvars') {
			scalar pse_DM`=`k'+1'Y = _b[MNDE] - prev_mnde
			scalar prev_mnde = _b[MNDE]
		}
			
	}
	
	local effects 
	local lbls "ATE"
	
	if (`num_mvars' == 1) {
		local effects `effects' nde nie
		local lbls `lbls' "NDE" "NIE"
	}
	
	if (`num_mvars' > 1) {
		local effects `effects' pse_DY
		local lbls `lbls' "PSE_DY" 
		forv k=`num_mvars'(-1)1 {
			local effects `effects' pse_DM`k'Y
			local lbls `lbls' "PSE_DM`k'Y"
		}
	}
	
	ereturn clear

	tempname b 
	
	matrix `b' = (ate)
	foreach e of local effects {
		matrix `b' = `b', (`e')
	}
	
	matrix colnames `b' = `lbls'	
	
	ereturn post `b' , esample(`touse') obs(`N')

end pathsimbs
