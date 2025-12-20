*!TITLE: WIMPMED - causal mediation analysis using an imputation-based weighting estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define wimpmedbs, eclass properties(svyb)
	
	version 15	

	syntax varlist(min=2 numeric) [if][in] [pweight iweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
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

	local yregtypes regress logit
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}
	else {
		local mreg : word `nyreg' of `yregtypes'
	}
		
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

	tempvar sampwts
	qui gen `sampwts' = 1 if `touse'
	
	if ("`weight'" != "") {
		tempvar wtvar
		quietly {
			gen double `wtvar' `exp'
			sum `wtvar' if `touse' , meanonly
			replace `sampwts' = `wtvar'/r(mean) if `touse'
		}
	}
		
	tempvar dvar_orig
	qui gen `dvar_orig' = `dvar' if `touse'

	/***COMPUTE INVERSE PROBABILITY WEIGHTS***/
	di ""
	di "{bf:Model for `dvar' given {cvars}:}"	
	logit `dvar' `cvars' [`weight' `exp'] if `touse'
	tempvar phat_D1_C phat_D0_C
	qui predict `phat_D1_C' if e(sample), pr
	qui gen `phat_D0_C'=1-`phat_D1_C' if `touse'
	
	qui logit `dvar' [`weight' `exp'] if `touse'
	tempvar phat_D1 phat_D0
	qui predict `phat_D1' if e(sample), pr
	qui gen `phat_D0'=1-`phat_D1' if `touse'
	
	tempvar sw1 
	qui gen `sw1' = `phat_D`dstar'' / `phat_D`dstar'_C' if `dvar'==`dstar' & `touse'
	
	if ("`censor'"!="") {
		qui centile `sw1' if `sw1'!=. & `touse', c(`censor') 
		qui replace `sw1'=r(c_1) if `sw1'<r(c_1) & `sw1'!=. & `touse'
		qui replace `sw1'=r(c_2) if `sw1'>r(c_2) & `sw1'!=. & `touse'
	}
		
	qui replace `sw1' = `sw1' * `sampwts' if `touse'
			
	/***COMPUTE REGRESSION IMPUTATIONS***/
	if ("`yreg'"=="regress") {
	
		di ""
		di "{bf:Model for `yvar' given {cvars `dvar'}:}"
		reg `yvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'

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
		di "{bf:Model for `yvar' given {cvars `dvar' `mvars'}:}"
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

	}

	if ("`yreg'"=="logit") {

		di ""
		di "{bf:Model for `yvar' given {cvars `dvar'}:}"
		glm `yvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse', family(b) link(l)

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
		di "{bf:Model for `yvar' given {cvars `dvar' `mvars'}:}"
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
			
	}
	
	tempname YdMdstar YdMd YdstarMdstar
	qui reg `yhatC`d'M' [pw=`sw1'] if `dvar'==`dstar' & `touse'
	scalar `YdMdstar' = _b[_cons]
	
	qui reg `yhat`d'M`d'' [pw=`sampwts'] if `touse'
	scalar `YdMd' = _b[_cons]

	qui reg `yhat`dstar'M`dstar'' [pw=`sampwts'] if `touse'
	scalar `YdstarMdstar' = _b[_cons]
	
	tempname ate nde nie
	scalar `ate' = `YdMd' - `YdstarMdstar'
	scalar `nde' = `YdMdstar' - `YdstarMdstar'
	scalar `nie' = `YdMd' - `YdMdstar'	
	
	if ("`detail'"!="") {
	
		local ipw_var_names "sw1_r001"
		foreach name of local ipw_var_names {
			capture confirm new variable `name'
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create a weight variable"
				display as error "with the following name: `ipw_var_names', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
			}
		}
		
		qui gen sw1_r001 = `sw1'
	
	}
	
	ereturn clear

	tempname b 
	
	local nde_name = cond(`num_mvars'==1, "NDE",  "MNDE")
	local nie_name = cond(`num_mvars'==1, "NIE",  "MNIE")
	
	matrix `b' = (`ate', `nde', `nie')
	matrix colnames `b' = "ATE" `nde_name' `nie_name'	
	
	ereturn post `b' , esample(`touse') obs(`N')	

end wimpmedbs
