*!TITLE: LINMED - causal mediation analysis using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define linmedbs, rclass
	
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

	if ("`nointeraction'"=="") {
		foreach m in `mvars' {
			capture confirm new variable Dx_`m'
				if _rc {
					display as error "{p 0 0 5 0}The command needs to create a new variable"
					display as error "with the following name: Dx_`m', "
					display as error "but this variable has already been defined.{p_end}"
					error 110
				}
			qui gen Dx_`m' = `dvar' * `m' if `touse'
			local inter `inter' Dx_`m'
		}
	}

	foreach c in `cvars' {
		tempvar `c'_r001
		qui regress `c' [`weight' `exp'] if `touse'
		qui predict ``c'_r001' if e(sample), resid
		local cvars_r `cvars_r' ``c'_r001'
	}

	if ("`cxd'"!="") {	
		foreach c in `cvars_r' {
			tempvar `c'xD
			qui gen ``c'xD' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars' ``c'xD'
		}
	}

	local i = 1
	if ("`cxm'"!="") {	
		foreach c in `cvars_r' {
			foreach m in `mvars' {
				tempvar mXc`i'
				qui gen `mXc`i'' = `m' * `c' if `touse'
				local cxm_vars `cxm_vars' `mXc`i''
				local ++i
			}
		}
	}

	if ("`nointeraction'"!="") {
		local k = 1
		foreach m in `mvars' {
			di ""
			di "Model for `m' conditional on {cvars `dvar'}:"
			regress `m' `dvar' `cvars_r' `cxd_vars' [`weight' `exp'] if `touse' 
			scalar beta2`k' = _b[`dvar']
			local ++k
		}

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvars'}:"
		regress `yvar' `dvar' `mvars' `cvars_r' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse' 
		scalar gamma2 = _b[`dvar']
		local k = 1
		foreach m in `mvars' {
			scalar gamma3`k' = _b[`m']
			local ++k
		}
			
		scalar nie_summand = 0
		forval k=1/`num_mvars' {
			scalar nie_summand = nie_summand + (beta2`k'*gamma3`k')
		}
				
		return scalar nde = gamma2*(`d'-`dstar')
		return scalar nie = nie_summand*(`d'-`dstar')
		return scalar ate = (gamma2 + nie_summand)*(`d'-`dstar')
	}

	if ("`nointeraction'"=="") {
		local k = 1
		foreach m in `mvars' {
			di ""
			di "Model for `m' conditional on {cvars `dvar'}:"
			regress `m' `dvar' `cvars_r' `cxd_vars' [`weight' `exp'] if `touse'
			scalar beta0`k' = _b[_cons]
			scalar beta2`k' = _b[`dvar']
			local ++k
		}

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvars'}:"
		regress `yvar' `dvar' `mvars' `inter' `cvars_r' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse' 
		scalar gamma2 = _b[`dvar']
		local k = 1
		foreach m in `mvars' {
			scalar gamma3`k' = _b[`m']
			scalar gamma4`k' = _b[Dx_`m']
			local ++k
		}
			
		scalar nde_summand = 0
		forval k=1/`num_mvars' {
			scalar nde_summand = nde_summand + gamma4`k'*(beta0`k' + beta2`k'*`dstar')
		}

		scalar nie_summand = 0
		forval k=1/`num_mvars' {
			scalar nie_summand = nie_summand + (beta2`k'*(gamma3`k' + gamma4`k'*`d'))
		}

		return scalar nde = (gamma2 + nde_summand)*(`d'-`dstar')
		return scalar nie = nie_summand*(`d'-`dstar')
		return scalar ate = (gamma2 + nde_summand + nie_summand)*(`d'-`dstar')
		
		foreach m in `mvars' {
			capture drop Dx_`m'
		}
	}
	
end linmedbs
