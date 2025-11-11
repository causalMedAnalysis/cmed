*!TITLE: IPWVENT - causal mediation analysis of interventional effects using inverse probability weighting	
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define ipwventbs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		lvar(varname numeric) ///
		mreg(string) ///
		lreg(string) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[cxd] ///
		[lxd] ///
		[sampwts(varname numeric)] ///
		[censor(numlist min=2 max=2)] ///
		[detail]
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	local yvar `varlist'
	
	/*****
	ERRORS
	******/
	local ipw_var_names "sw1_r001 sw2_r001 sw3_r001"
	foreach name of local ipw_var_names {
		capture confirm new variable `name'
		if _rc {
			display as error "{p 0 0 5 0}The command needs to create weight variables"
			display as error "with the following names: `ipw_var_names', "
			display as error "but these variables have already been defined.{p_end}"
			error 110
		}
	}

	local sampwt_var_names "wt_r001 wt_r002 wt_r003"
	foreach name of local sampwt_var_names {
		capture confirm new variable `name'
		if !_rc {
			local wts `name'
			continue, break
		}
	}
	if _rc {
		display as error "{p 0 0 5 0}The command needs to create a weight variable"
		display as error "with one of the following names: `sampwt_var_names', "
		display as error "but these variables have already been defined.{p_end}"
		error 110
	}

	local phat_var_names "phat_D1_C_r001 phat_D0_C_r001 phat_D1_r001 phat_D0_r001 phat_L0_CD1_r001 phat_L0_CD0_r001 phat_L1_CD1_r001 phat_L1_CD0_r001 phat_M_CD1L_r001 phat_M_CD0L_r001 phat_M_CD1L0_r001 phat_M_CD0L0_r001 phat_M_CD1L1_r001 phat_M_CD0L1_r001"
	foreach name of local phat_var_names {
		capture confirm new variable `name'
		if _rc {
			display as error "{p 0 0 5 0}The command needs to create a variable"
			display as error "with the following name: `name', "
			display as error "but this variable has already been defined.{p_end}"
			error 110
		}
	}

	local mhat_var_names "mhat_M_CD1L0_r001 mhat_M_CD0L0_r001 mhat_M_CD1L1_r001 mhat_M_CD0L1_r001"
	foreach name of local mhat_var_names {
		capture confirm new variable `name'
		if _rc {
			display as error "{p 0 0 5 0}The command needs to create a variable"
			display as error "with the following name: `name', "
			display as error "but this variable has already been defined.{p_end}"
			error 110
		}
	}
	
	/**********************************
	GENERATE AND SCALE SAMPLING WEIGHTS
	***********************************/
	qui gen `wts' = 1 if `touse'
	
	if ("`sampwts'" != "") {
		qui replace `wts' = `wts' * `sampwts'
		qui sum `wts'
		qui replace `wts' = `wts' / r(mean)
	}

	/*****************************
	GENERATE INTERACTION VARIABLES
	******************************/
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
		}
	}
	
	if ("`lxd'"!="") {	
		tempvar lxd_var
		qui gen `lxd_var' = `dvar' * `lvar' if `touse'
	}
		
	/***************************************
	PLACEHOLDERS FOR ORIGINAL VALUES OF VARS
	****************************************/
	tempvar `dvar'_orig
	qui gen ``dvar'_orig' = `dvar' if `touse'

	tempvar `lvar'_orig
	qui gen ``lvar'_orig' = `lvar' if `touse'
	
	/*********
	FIT MODELS
	**********/
	/*****DVAR*****/
	di ""
	di "Model for `dvar' conditional on {cvars}:"
	logit `dvar' `cvars' [pw=`wts'] if `touse'
	qui est store Dmodel_given_C_r001
		
	qui logit `dvar' [pw=`wts'] if `touse'
	qui est store Dmodel_r001

	/*****LVAR*****/
	if ("`lreg'"=="logit") {
		di ""
		di "Model for `lvar' conditional on {cvars `dvar'}:"
		logit `lvar' `dvar' `cvars' `cxd_vars' [pw=`wts'] if `touse'
		qui ologit `lvar' `dvar' `cvars' `cxd_vars' [pw=`wts'] if `touse'
		qui est store Lmodel_given_CD_r001
	}
	else {
		di ""
		di "Model for `lvar' conditional on {cvars `dvar'}:"
		`lreg' `lvar' `dvar' `cvars' `cxd_vars' [pw=`wts'] if `touse'
		qui est store Lmodel_given_CD_r001
	}
	
	/*****MVAR*****/
	di ""
	di "Model for `mvar' conditional on {cvars `dvar' `lvar'}:"
	`mreg' `mvar' `dvar' `lvar' `cvars' `cxd_vars' `lxd_var' [pw=`wts'] if `touse'
	qui est store Mmodel_given_CDL_r001
	
	qui `mreg' `mvar' `dvar' [pw=`wts'] if `touse'
	qui est store Mmodel_given_D_r001
	
	/********************
	COMPUTE PROBABILITIES
	*********************/
	qui levelsof `lvar' if `touse', local(levels)
	qui local numLevels: word count `levels'
	
	/*****DVAR*****/
	qui est restore Dmodel_given_C_r001
	qui predict phat_D1_C_r001 if e(sample), pr
	qui gen phat_D0_C_r001=1-phat_D1_C_r001 if `touse'
	
	qui est restore Dmodel_r001
	qui predict phat_D1_r001 if e(sample), pr
	qui gen phat_D0_r001=1-phat_D1_r001 if `touse'
	
	/*****LVAR*****/
	qui est restore Lmodel_given_CD_r001
	
	foreach level in `levels' {
		
		qui replace `dvar'=1 if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}					

		qui predict phat_L`level'_CD1_r001 if e(sample), pr outcome(`level')
			
		qui replace `dvar'=0 if `touse'
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}					

		qui predict phat_L`level'_CD0_r001 if e(sample), pr outcome(`level')
	}
	
	qui replace `dvar' = ``dvar'_orig' if `touse'

	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
	}					

	/*****MVAR*****/
	qui est restore Mmodel_given_CDL_r001
	
	qui gen phat_M_CD1L_r001=. if `touse'
	qui gen phat_M_CD0L_r001=. if `touse'
	
	foreach level in `levels' {
	
		qui replace `lvar'=`level' if `touse'
		
		if ("`mreg'"=="logit") {
		
			qui replace `dvar'=1 if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}
			
			qui predict phat_M1_CD1L`level'_r001 if e(sample), pr 
			
			qui replace `dvar'=0 if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}

			qui predict phat_M1_CD0L`level'_r001 if e(sample), pr 
			
			qui gen phat_M_CD1L`level'_r001=binomialp(1, `mvar', phat_M1_CD1L`level'_r001) if `touse'
			qui gen phat_M_CD0L`level'_r001=binomialp(1, `mvar', phat_M1_CD0L`level'_r001) if `touse'
			
			qui replace phat_M_CD1L_r001=phat_M_CD1L`level'_r001 if ``lvar'_orig'==`level' & `touse'
			qui replace phat_M_CD0L_r001=phat_M_CD0L`level'_r001 if ``lvar'_orig'==`level' & `touse'
		}
		
		if ("`mreg'"=="poisson") {
		
			qui replace `dvar'=1 if `touse'

			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}

			qui predict mhat_M_CD1L`level'_r001 if e(sample)
			
			qui replace `dvar'=0 if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}

			qui predict mhat_M_CD0L`level'_r001 if e(sample)
			
			qui gen phat_M_CD1L`level'_r001=poissonp(mhat_M_CD1L`level'_r001, `mvar') if `touse'
			qui gen phat_M_CD0L`level'_r001=poissonp(mhat_M_CD0L`level'_r001, `mvar') if `touse'
			
			qui replace phat_M_CD1L_r001=phat_M_CD1L`level'_r001 if ``lvar'_orig'==`level' & `touse'
			qui replace phat_M_CD0L_r001=phat_M_CD0L`level'_r001 if ``lvar'_orig'==`level' & `touse'
		}
		
		if ("`mreg'"=="regress") {
		
			qui replace `dvar'=1 if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}

			qui predict mhat_M_CD1L`level'_r001 if e(sample), xb
			
			qui replace `dvar'=0 if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					

			if ("`lxd'"!="") {	
				qui replace `lxd_var' = `dvar' * `lvar' if `touse'
			}

			qui predict mhat_M_CD0L`level'_r001 if e(sample), xb
	
			qui gen phat_M_CD1L`level'_r001=normalden(`mvar', mhat_M_CD1L`level'_r001, e(rmse)) if `touse'
			qui gen phat_M_CD0L`level'_r001=normalden(`mvar', mhat_M_CD0L`level'_r001, e(rmse)) if `touse'
			
			qui replace phat_M_CD1L_r001=phat_M_CD1L`level'_r001 if ``lvar'_orig'==`level' & `touse'
			qui replace phat_M_CD0L_r001=phat_M_CD0L`level'_r001 if ``lvar'_orig'==`level' & `touse'
		}
	}
		
	qui replace `dvar' = ``dvar'_orig' if `touse'
	qui replace `lvar' = ``lvar'_orig' if `touse'
	
	/***********
	COMPUTE IPWs
	************/
	/*****SW1*****/
	qui gen sw1_r001=0 if `dvar'==`dstar' & `touse'
	
	foreach level in `levels' {
		qui replace sw1_r001 = sw1_r001 + (phat_M_CD`dstar'L`level'_r001 * phat_L`level'_CD`dstar'_r001) if `dvar'==`dstar' & `touse'
	}
	
	qui replace sw1_r001 = sw1_r001 / (phat_D`dstar'_C_r001 * phat_M_CD`dstar'L_r001) if `dvar'==`dstar' & `touse'
	qui replace sw1_r001 = sw1_r001 * phat_D`dstar'_r001 if `dvar'==`dstar' & `touse'
	
	/*****SW2*****/
	qui gen sw2_r001=0 if `dvar'==`d' & `touse'
	
	foreach level in `levels' {
		qui replace sw2_r001 = sw2_r001 + (phat_M_CD`d'L`level'_r001 * phat_L`level'_CD`d'_r001) if `dvar'==`d' & `touse'
	}
	
	qui replace sw2_r001 = sw2_r001 / (phat_D`d'_C_r001 * phat_M_CD`d'L_r001) if `dvar'==`d' & `touse'
	qui replace sw2_r001 = sw2_r001 * phat_D`d'_r001 if `dvar'==`d' & `touse' 
	
	/*****SW3*****/
	qui gen sw3_r001=0 if `dvar'==`d' & `touse'
	
	foreach level in `levels' {
		qui replace sw3_r001 = sw3_r001 + (phat_M_CD`dstar'L`level'_r001 * phat_L`level'_CD`dstar'_r001) if `dvar'==`d' & `touse'
	}
	
	qui replace sw3_r001 = sw3_r001 / (phat_D`d'_C_r001 * phat_M_CD`d'L_r001) if `dvar'==`d' & `touse'
	qui replace sw3_r001 = sw3_r001 * phat_D`d'_r001 if `dvar'==`d' & `touse'	
	
	/*************
	CENSOR WEIGHTS
	**************/
	if ("`censor'"!="") {
		foreach i of var sw1_r001 sw2_r001 sw3_r001 {
			qui centile `i' if `i'!=. & `touse', c(`censor') 
			qui replace `i'=r(c_1) if `i'<r(c_1) & `i'!=. & `touse'
			qui replace `i'=r(c_2) if `i'>r(c_2) & `i'!=. & `touse'
		}
	}
	
	/***********************
	COMPUTE EFFECT ESTIMATES
	************************/
	foreach i of var sw1_r001 sw2_r001 sw3_r001 {
		qui replace `i'=`i' * `wts' if `touse'
	}
				
	qui reg `yvar' [pw=sw1_r001] if `dvar'==`dstar' & `touse'
	local Ehat_Y0M0=_b[_cons]
		
	qui reg `yvar' [pw=sw2_r001] if `dvar'==`d' & `touse'
	local Ehat_Y1M1=_b[_cons]
		
	qui reg `yvar' [pw=sw3_r001] if `dvar'==`d' & `touse'
	local Ehat_Y1M0=_b[_cons]

	return scalar oe=`Ehat_Y1M1'-`Ehat_Y0M0'
	return scalar ide=`Ehat_Y1M0'-`Ehat_Y0M0'
	return scalar iie=`Ehat_Y1M1'-`Ehat_Y1M0'
	
	est drop ///
		Dmodel_given_C_r001 Dmodel_r001 ///
		Lmodel_given_CD_r001 ///
		Mmodel_given_CDL_r001 Mmodel_given_D_r001
	
	drop phat*_r001 mhat*_r001 `wts'
	
	if ("`detail'"=="") {
		drop sw1_r001 sw2_r001 sw3_r001
		
	qui reg `yvar' if `touse'
	
	}
	
end ipwventbs
