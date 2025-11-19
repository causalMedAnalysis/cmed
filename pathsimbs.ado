*!TITLE: PATHSIMBS - analysis of path-specific effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define pathsimbs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
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
		mnesimbs `yvar' if `touse' [`weight' `exp'], ///
			dvar(`dvar') mvars(`mvars_include') cvars(`cvars') ///
			d(`d') dstar(`dstar') mregs(`mregs_include') yreg(`yreg') ///
			nsim(`nsim') `nointeraction' `cxd' `cxm'	
		
		*K=1 mediators
		if `num_mvars'==1 {
			return scalar nde = r(mnde)
			return scalar nie = r(mnie)
			return scalar ate = r(ate)
		}
		
		*K>=2 mediators: last mediator
		if `num_mvars'>1 & `k'==`num_mvars' {
			return scalar pse_DY = r(mnde)
			scalar prev_mnde = r(mnde)
		}
		
		*K>=2 mediators: first mediator
		if `num_mvars'>1 & `k'==1 {
			return scalar pse_DM`=`k'+1'Y = r(mnde) - prev_mnde
			return scalar pse_DM1Y = r(mnie)
			return scalar ate = r(ate)
		}
		
		*K>=2 mediators: all other mediators
		if `num_mvars'>1 & !inlist(`k',1,`num_mvars') {
			return scalar pse_DM`=`k'+1'Y = r(mnde) - prev_mnde
			scalar prev_mnde = r(mnde)
		}
			
	}

end pathsimbs
