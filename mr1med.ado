*!TITLE: MRMED - causal mediation analysis using parametric multiply robust methods
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mr1med, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[censor(numlist min=2 max=2)] 
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	local yvar `varlist'
	
	if ("`nointeraction'" == "") {
		tempvar inter
		qui gen `inter' = `dvar' * `mvar' if `touse'
	}

	local cxd_vars
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
		}
	}

	local cxm_vars
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			tempvar `mvar'X`c'
			qui gen ``mvar'X`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  ``mvar'X`c''
		}
	}
		
	tempvar dvar_orig mvar_orig
	qui gen `dvar_orig' = `dvar' if `touse'
	qui gen `mvar_orig' = `mvar' if `touse'
	
	di ""
	di "Model for `dvar' conditional on {cvars}:"
	logit `dvar' `cvars' if `touse'
	
	tempvar phat_D1_C pi`d'_C pi`dstar'_C
	qui predict `phat_D1_C' if `touse', pr
	qui gen `pi`d'_C' = `phat_D1_C'*`d' + (1-`phat_D1_C')*(1-`d') if `touse'
	qui gen `pi`dstar'_C' = `phat_D1_C'*`dstar' + (1-`phat_D1_C')*(1-`dstar') if `touse'
	
	di ""
	di "Model for `mvar' conditional on {cvars `dvar'}:"
	logit `mvar' `dvar' `cvars' `cxd_vars' if `touse'
	
	qui replace `dvar' = `dstar' if `touse'
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}
	
	tempvar f_M1_CD`dstar' f_M0_CD`dstar' f_M_CD`dstar'
	qui predict `f_M1_CD`dstar'' if `touse', pr
	qui gen `f_M0_CD`dstar'' = 1 - `f_M1_CD`dstar'' if `touse'
	qui gen `f_M_CD`dstar'' = `f_M1_CD`dstar''*`mvar' + `f_M0_CD`dstar''*(1-`mvar') if `touse'

	qui replace `dvar' = `d' if `touse'
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	tempvar f_M1_CD`d' f_M0_CD`d' f_M_CD`d'
	qui predict `f_M1_CD`d'' if `touse', pr
	qui gen `f_M0_CD`d'' = 1 - `f_M1_CD`d''	if `touse'
	qui gen `f_M_CD`d'' = `f_M1_CD`d''*`mvar' + `f_M0_CD`d''*(1-`mvar') if `touse'
	
	qui replace `dvar' = `dvar_orig' if `touse'
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}

	di ""
	di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
	
	reg `yvar' `dvar' `mvar' `inter' `cvars' `cxd_vars' `cxm_vars' if `touse'

	qui replace `dvar' = `dstar' if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`dstar'_CM
	qui predict `mu`dstar'_CM' if `touse'
	
	qui replace `dvar' = `d' if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}			
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`d'_CM
	qui predict `mu`d'_CM' if `touse'

	qui replace `dvar' = `dstar' if `touse'
	qui replace `mvar' = 0 if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`dstar'_CM0
	qui predict `mu`dstar'_CM0'

	qui replace `dvar' = `dstar' if `touse'
	qui replace `mvar' = 1 if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`dstar'_CM1
	qui predict `mu`dstar'_CM1' if `touse'

	qui replace `dvar' = `d' if `touse'
	qui replace `mvar' = 0 if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`d'_CM0
	qui predict `mu`d'_CM0' if `touse'
	
	qui replace `dvar' = `d' if `touse'
	qui replace `mvar' = 1 if `touse'
	
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}		
	
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
	}
	
	tempvar mu`d'_CM1
	qui predict `mu`d'_CM1' if `touse'
	
	qui replace `dvar' = `dvar_orig' if `touse'
	qui replace `mvar' = `mvar_orig' if `touse'
	
	tempvar ipw`d' ipw`dstar' rmpw

	qui gen `ipw`d'' = 0 if `touse'
	qui replace `ipw`d'' = 1/`pi`d'_C' if `dvar'==`d' & `touse'

	
	qui gen `ipw`dstar'' = 0 if `touse'
	qui replace `ipw`dstar'' = 1/`pi`dstar'_C' if `dvar'==`dstar' & `touse'
		
	qui gen `rmpw' = `ipw`d''*(`f_M_CD`dstar''/`f_M_CD`d'') if `touse'

	if ("`censor'"!="") {
		qui centile `ipw`d'' if `ipw`d''!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `ipw`d''=r(c_1) if `ipw`d''<r(c_1) & `ipw`d''!=. & `dvar'==`d' & `touse'
		qui replace `ipw`d''=r(c_2) if `ipw`d''>r(c_2) & `ipw`d''!=. & `dvar'==`d' & `touse'
	
		qui centile `ipw`dstar'' if `ipw`dstar''!=. & `dvar'==`dstar' & `touse', c(`censor') 
		qui replace `ipw`dstar''=r(c_1) if `ipw`dstar''<r(c_1) & `ipw`dstar''!=. & `dvar'==`dstar' & `touse'
		qui replace `ipw`dstar''=r(c_2) if `ipw`dstar''>r(c_2) & `ipw`dstar''!=. & `dvar'==`dstar' & `touse'	

		qui centile `rmpw' if `rmpw'!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `rmpw'=r(c_1) if `rmpw'<r(c_1) & `rmpw'!=. & `dvar'==`d' & `touse'
		qui replace `rmpw'=r(c_2) if `rmpw'>r(c_2) & `rmpw'!=. & `dvar'==`d' & `touse'
	}
		
	tempvar dr`d'`d'_summand
	qui gen `dr`d'`d'_summand' = `ipw`d''*(`yvar' - `mu`d'_CM') ///
		+ `ipw`d''*(`mu`d'_CM' - (`mu`d'_CM0'*`f_M0_CD`d'' + `mu`d'_CM1'*`f_M1_CD`d'')) ///
		+ (`mu`d'_CM0'*`f_M0_CD`d'' + `mu`d'_CM1'*`f_M1_CD`d'') if `touse'
	
	tempvar dr`dstar'`dstar'_summand
	qui gen `dr`dstar'`dstar'_summand' = `ipw`dstar''*(`yvar' - `mu`dstar'_CM') ///
		+ `ipw`dstar''*(`mu`dstar'_CM' - (`mu`dstar'_CM0'*`f_M0_CD`dstar'' + `mu`dstar'_CM1'*`f_M1_CD`dstar'')) ///
		+ (`mu`dstar'_CM0'*`f_M0_CD`dstar'' + `mu`dstar'_CM1'*`f_M1_CD`dstar'') if `touse'

	tempvar dr`dstar'`d'_summand
	qui gen `dr`dstar'`d'_summand' = `rmpw'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`dstar''*(`mu`d'_CM' - (`mu`d'_CM0'*`f_M0_CD`dstar'' + `mu`d'_CM1'*`f_M1_CD`dstar'')) ///
		+ (`mu`d'_CM0'*`f_M0_CD`dstar'' + `mu`d'_CM1'*`f_M1_CD`dstar'') if `touse'
			
	qui reg `dr`d'`d'_summand' if `touse'
	return scalar psi`d'`d' = _b[_cons]

	qui reg `dr`dstar'`dstar'_summand' if `touse'
	return scalar psi`dstar'`dstar' = _b[_cons]

	qui reg `dr`dstar'`d'_summand' if `touse'
	return scalar psi`dstar'`d' = _b[_cons]

end mr1med
