*!TITLE: PATHIMP - path-specific effects using pure regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mpathimp, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
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

	if ("`nointeraction'" == "") {
		foreach m in `mvars' {
			tempvar i_`m'
			qui gen `i_`m'' = `dvar' * `m' if `touse'
			local inter `inter' `i_`m''
		}
	}

	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar dX`c'
			qui gen `dX`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars' `dX`c''
		}
	}

	local i = 1
	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			foreach m in `mvars' {
				tempvar mXc`i'
				qui gen `mXc`i'' = `m' * `c' if `touse'
				local cxm_vars `cxm_vars' `mXc`i''
				local ++i
			}
		}
	}

	tempvar dvar_orig
	qui gen `dvar_orig' = `dvar' if `touse'
	
	if ("`yreg'"=="regress") {
	
		qui reg `yvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'

		tempvar yhat`d'M`d' yhat`dstar'M`dstar'
		
		qui replace `dvar' = `d' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		qui predict `yhat`d'M`d'' if `touse', xb
		
		qui replace `dvar' = `dstar' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		qui predict `yhat`dstar'M`dstar'' if `touse', xb
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		di ""
		di "Model for `yvar' given {cvars `dvar' `mvars'}:"
		reg `yvar' `dvar' `mvars' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		
		tempvar yhatC`d'M
		
		qui replace `dvar' = `d' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		if ("`nointeraction'" == "") {
			foreach m in `mvars' {
				qui replace `i_`m'' = `dvar' * `m' if `touse'
			}
		}
		
		qui predict `yhatC`d'M' if `touse', xb
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		if ("`nointeraction'" == "") {
			foreach m in `mvars' {
				qui replace `i_`m'' = `dvar' * `m' if `touse'
			}
		}
		
		di ""
		di "Model for predictions from previous model under D:=d given {cvars `dvar'}:"
		reg `yhatC`d'M' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		
		tempvar yhat`d'M`dstar'
		
		qui replace `dvar' = `dstar' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		qui predict `yhat`d'M`dstar'' if `touse', xb
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}
		
	}

	if ("`yreg'"=="logit") {
	
		qui glm `yvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse', family(b) link(l)

		tempvar yhat`d'M`d' yhat`dstar'M`dstar'
		
		qui replace `dvar' = `d' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		qui predict `yhat`d'M`d'' if `touse'
		
		qui replace `dvar' = `dstar' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		qui predict `yhat`dstar'M`dstar'' if `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		di ""
		di "Model for `yvar' given {cvars `dvar' `mvars'}:"
		glm `yvar' `dvar' `mvars' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse', family(b) link(l)
		
		tempvar yhatC`d'M
		
		qui replace `dvar' = `d' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		if ("`nointeraction'" == "") {
			foreach m in `mvars' {
				qui replace `i_`m'' = `dvar' * `m' if `touse'
			}
		}
			
		qui predict `yhatC`d'M' if `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
			
		if ("`nointeraction'" == "") {
			foreach m in `mvars' {
				qui replace `i_`m'' = `dvar' * `m' if `touse'
			}
		}
		
		di ""
		di "Model for predictions from previous model under D:=d given {cvars `dvar'}:"
		glm `yhatC`d'M' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse', family(b) link(l)
		
		tempvar yhat`d'M`dstar'
		
		qui replace `dvar' = `dstar' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
		
		qui predict `yhat`d'M`dstar'' if `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace `dX`c'' = `dvar' * `c' if `touse'
			}
		}	
	
	}
	
	tempvar ATEgivenC NDEgivenC NIEgivenC
	qui gen `ATEgivenC' = `yhat`d'M`d'' - `yhat`dstar'M`dstar'' if `touse'
	qui gen `NDEgivenC' = `yhat`d'M`dstar'' - `yhat`dstar'M`dstar'' if `touse'
	qui gen `NIEgivenC' = `yhat`d'M`d'' - `yhat`d'M`dstar'' if `touse'
		
	qui reg `ATEgivenC' [`weight' `exp'] if `touse'
	return scalar ate = _b[_cons]

	qui reg `NDEgivenC' [`weight' `exp'] if `touse'
	return scalar nde = _b[_cons]

	qui reg `NIEgivenC' [`weight' `exp'] if `touse'
	return scalar nie = _b[_cons]
	
end mpathimp
