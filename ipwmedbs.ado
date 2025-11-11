*!TITLE: IPWMED - causal mediation analysis using inverse probability weighting
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define ipwmedbs, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
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

	tempvar wts
	qui gen `wts' = 1 if `touse'
	
	if ("`sampwts'" != "") {
		qui replace `wts' = `wts' * `sampwts'
		qui sum `wts'
		qui replace `wts' = `wts' / r(mean)
	}
	
	di ""
	di "Model for `dvar' conditional on cvars:"
	logit `dvar' `cvars' [pw=`wts'] if `touse'
	tempvar phat_D1_C phat_D0_C
	qui predict `phat_D1_C' if e(sample), pr
	qui gen `phat_D0_C'=1-`phat_D1_C' if `touse'
	
	di ""
	di "Model for `dvar' conditional on {cvars `dvar' `mvars'}:"
	logit `dvar' `mvars' `cvars' [pw=`wts'] if `touse'
	tempvar phat_D1_CM phat_D0_CM
	qui predict `phat_D1_CM' if e(sample), pr
	qui gen `phat_D0_CM'=1-`phat_D1_CM' if `touse'

	qui logit `dvar' [pw=`wts'] if `touse'
	tempvar phat_D1 phat_D0
	qui predict `phat_D1' if e(sample), pr
	qui gen `phat_D0'=1-`phat_D1' if `touse'
	
	tempvar sw1 sw2 sw3
	qui gen `sw1' = `phat_D`dstar'' / `phat_D`dstar'_C' if `dvar'==`dstar' & `touse'
	qui gen `sw2' = `phat_D`d'' / `phat_D`d'_C' if `dvar'==`d' & `touse'
	qui gen `sw3' = (`phat_D`dstar'_CM'*`phat_D`d'') / (`phat_D`d'_CM'*`phat_D`dstar'_C') if `dvar'==`d' & `touse'
	
	if ("`censor'"!="") {
		foreach i of var `sw1' `sw2' `sw3' {
			qui centile `i' if `i'!=. & `touse', c(`censor') 
			qui replace `i'=r(c_1) if `i'<r(c_1) & `i'!=. & `touse'
			qui replace `i'=r(c_2) if `i'>r(c_2) & `i'!=. & `touse'
		}
	}
	
	foreach i of var `sw1' `sw2' `sw3' {
		qui replace `i'=`i' * `wts' if `touse'
	}
	
	if ("`detail'"!="") {
		qui gen sw1_r001 = `sw1'
		qui gen sw2_r001 = `sw2'
		qui gen sw3_r001 = `sw3'
	
	}

	preserve
	
	qui reg `yvar' [pw=`sw1'] if `dvar'==`dstar' & `touse'
	local Ehat_Y0M0=_b[_cons]
		
	qui reg `yvar' [pw=`sw2'] if `dvar'==`d' & `touse'
	local Ehat_Y1M1=_b[_cons]
		
	qui reg `yvar' [pw=`sw3'] if `dvar'==`d' & `touse'
	local Ehat_Y1M0=_b[_cons]
	
	return scalar ate=`Ehat_Y1M1'-`Ehat_Y0M0'
	return scalar nde=`Ehat_Y1M0'-`Ehat_Y0M0'
	return scalar nie=`Ehat_Y1M1'-`Ehat_Y1M0'
		
	restore

end ipwmedbs
