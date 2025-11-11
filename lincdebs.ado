*!TITLE: LINCDE - estimating controlled direct effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define lincdebs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
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
	
	if ("`nointeraction'"=="") {
		capture confirm new variable __DxM__
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create a new variable"
				display as error "with the following name: __DxM__, "
				display as error "but this variable has already been defined.{p_end}"
				error 110
			}
		qui gen __DxM__ = `dvar'*`mvar' if `touse'
	}
	
	if ("`cvars'"!="") {
		foreach c in `cvars' {
			tempvar `c'_r001
			qui regress `c' [`weight' `exp'] if `touse'
			qui predict ``c'_r001' if e(sample), resid
			local cvars_r `cvars_r' ``c'_r001'
		}
	}

	if ("`cxd'"!="") {	
		foreach c in `cvars_r' {
			tempvar `c'_xD
			qui gen ``c'_xD' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars' ``c'_xD'
		}
	}

	if ("`cxm'"!="") {	
		foreach c in `cvars_r' {
			tempvar `c'_xM
			qui gen ``c'_xM' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars' ``c'_xM'
		}
	}
		
	if ("`nointeraction'"!="") {
		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		regress `yvar' `dvar' `mvar' `cvars_r' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse' 
		
		return scalar cde = _b[`dvar']*(`d'-`dstar')
	}
		
	if ("`nointeraction'"=="") {
		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		regress `yvar' `dvar' `mvar' __DxM__ `cvars_r' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse' 
		
		return scalar cde = (_b[`dvar'] + _b[__DxM__]*`m')*(`d'-`dstar')
		
		capture drop __DxM__
	}

end lincdebs
