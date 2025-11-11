*!TITLE: LINPATH - path-specific effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define linpathbs, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
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
			
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
	
	* loop over mediators in reverse order
	forv k=`num_mvars'(-1)1 {
		
		* select all mediators up to the mediator in question
		local mvars_include
		forv j=1/`k' {
			local mvars_include `mvars_include' `=word("`mvars'",`j')'
		}
		
		* estimate natural effects
		mlinpath `yvar' `mvars_include' [`weight' `exp'] if `touse', ///
			dvar(`dvar') cvars(`cvars')	d(`d') dstar(`dstar') ///
			`cxd' `cxm' `nointeraction'
		
		* special case: only one total mediator
		if `num_mvars'==1 {
			return scalar nde = r(nde)
			return scalar nie = r(nie)
			return scalar ate = r(ate)
		}
		
		* 2+ total mediators: last mediator
		if `num_mvars'>1 & `k'==`num_mvars' {
			return scalar pse_DY = r(nde)
			scalar prev_mnde = r(nde)
		}
		
		* 2+ total mediators: first mediator
		if `num_mvars'>1 & `k'==1 {
			return scalar pse_DM`=`k'+1'Y = r(nde) - prev_mnde
			return scalar pse_DM1Y = r(nie)
			return scalar ate = r(ate)
		}
		
		* 2+ total mediators: all other mediators
		if `num_mvars'>1 & !inlist(`k',1,`num_mvars') {
			return scalar pse_DM`=`k'+1'Y = r(nde) - prev_mnde
			scalar prev_mnde = r(nde)
		}
			
	}

end linpathbs
