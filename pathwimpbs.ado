*!TITLE: PATHWIMP - path-specific effects using an imputation-based weighting estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2  - support for unlimited num of mediators
*!

program define pathwimpbs, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[sampwts(varname numeric)] ///
		[censor(numlist min=2 max=2)] ///
		[detail]
		
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
		mpathwimp `yvar' `mvars_include' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
			
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

end pathwimpbs
