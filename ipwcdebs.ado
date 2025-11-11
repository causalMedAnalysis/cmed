*!TITLE: IPWCDE - analysis of controlled direct effects using inverse probability weighting	
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define ipwcdebs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		mreg(string) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		[cvars(varlist numeric)] ///
		[lvars(varlist numeric)] ///
		[NOINTERaction] ///
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
	local phat_var_names "phat_M_D_r001 phat_M_CDL_r001 phat_D1_r001 phat_D0_r001 phat_D1_C_r001 phat_D0_C_r001"
	foreach name of local phat_var_names {
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
	tempvar wts
	qui gen `wts' = 1 if `touse'
	
	if ("`sampwts'" != "") {
		qui replace `wts' = `wts' * `sampwts'
		qui sum `wts'
		qui replace `wts' = `wts' / r(mean)
	}

	/*****************************
	GENERATE INTERACTION VARIABLES
	******************************/
	if ("`nointeraction'" == "") {
		tempvar inter
		qui gen `inter' = `dvar' * `mvar' if `touse'
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
		}
	}
	
	if ("`lvars'"!="") & ("`lxd'"!="") {	
		foreach l in `lvars' {
			tempvar `dvar'X`l'
			qui gen ``dvar'X`l'' = `dvar' * `l' if `touse'
			local lxd_vars `lxd_vars'  ``dvar'X`l''
		}
	}
	
	/*********
	FIT MODELS
	**********/	
	/*****DVAR*****/
	di ""
	di "Model for `dvar' conditional on {`cvars'}:"
	logit `dvar' `cvars' [pw=`wts'] if `touse'
	qui est store Dmodel_given_C_r001
		
	qui logit `dvar' [pw=`wts'] if `touse'
	qui est store Dmodel_r001
	
	/*****MVAR*****/
	di ""
	di "Model for `mvar' conditional on {`cvars' `dvar' `lvars'}:"
	`mreg' `mvar' `dvar' `lvars' `cvars' `cxd_vars' `lxd_vars' [pw=`wts'] if `touse'
	qui est store Mmodel_given_CDL_r001
	
	qui `mreg' `mvar' `dvar' [pw=`wts'] if `touse'
	qui est store Mmodel_given_D_r001
	
	/********************
	COMPUTE PROBABILITIES
	*********************/
	/*****DVAR*****/
	qui est restore Dmodel_given_C_r001
	qui predict phat_D1_C_r001 if e(sample), pr
	qui gen phat_D0_C_r001=1-phat_D1_C_r001 if `touse'
	
	qui est restore Dmodel_r001
	qui predict phat_D1_r001 if e(sample), pr
	qui gen phat_D0_r001=1-phat_D1_r001 if `touse'
	
	/*****MVAR*****/
	qui est restore Mmodel_given_CDL_r001	
	tempvar mhat_M_CDL_r001
	
	if ("`mreg'"=="logit") {
		qui predict `mhat_M_CDL_r001' if e(sample), pr 
		qui gen phat_M_CDL_r001=binomialp(1, `mvar', `mhat_M_CDL_r001') if `touse'
	}
		
	if ("`mreg'"=="poisson") {
		qui predict `mhat_M_CDL_r001' if e(sample)
		qui gen phat_M_CDL_r001=poissonp(`mhat_M_CDL_r001', `mvar') if `touse'
	}
		
	if ("`mreg'"=="regress") {
		qui predict `mhat_M_CDL_r001' if e(sample), xb
		qui gen phat_M_CDL_r001=normalden(`mvar', `mhat_M_CDL_r001', e(rmse)) if `touse'
	}	
	
	qui est restore Mmodel_given_D_r001
	tempvar mhat_M_D_r001
	
	if ("`mreg'"=="logit") {
		qui predict `mhat_M_D_r001' if e(sample), pr 
		qui gen phat_M_D_r001=binomialp(1, `mvar', `mhat_M_D_r001') if `touse'
	}
		
	if ("`mreg'"=="poisson") {
		qui predict `mhat_M_D_r001' if e(sample)
		qui gen phat_M_D_r001=poissonp(`mhat_M_D_r001', `mvar') if `touse'
	}
		
	if ("`mreg'"=="regress") {
		qui predict `mhat_M_D_r001' if e(sample), xb
		qui gen phat_M_D_r001=normalden(`mvar', `mhat_M_D_r001', e(rmse)) if `touse'
	}
	
	/***********
	COMPUTE IPWs
	************/
	tempvar sw4
	qui gen `sw4' = . if `touse'
	
	qui replace `sw4' = (phat_M_D_r001 * phat_D`dstar'_r001) / (phat_M_CDL_r001 * phat_D`dstar'_C_r001) if `dvar'==`dstar' & `touse'

	qui replace `sw4' = (phat_M_D_r001 * phat_D`d'_r001) / (phat_M_CDL_r001 * phat_D`d'_C_r001) if `dvar'==`d' & `touse'
	
	/*************
	CENSOR WEIGHTS
	**************/
	if ("`censor'"!="") {
		qui centile `sw4' if `sw4'!=. & `touse', c(`censor') 
		qui replace `sw4' = r(c_1) if `sw4'<r(c_1) & `sw4'!=. & `touse'
		qui replace `sw4' = r(c_2) if `sw4'>r(c_2) & `sw4'!=. & `touse'
	}
	
	/***********************
	COMPUTE EFFECT ESTIMATES
	************************/	
	di ""
	di "Model for Y(d,m) fit using IPWs:"
	reg `yvar' `dvar' `mvar' `inter' [pw=`sw4'] if `touse'		
	return scalar cde=(_b[`dvar']+(_b[`inter']*`m'))*(`d'-`dstar')
		
	if ("`detail'"!="") {
		local ipw_var_names "sw4_r001"
		foreach name of local ipw_var_names {
			capture confirm new variable `name'
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create a weight variable"
				display as error "with the following name: `ipw_var_names', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
			}
		}
		qui gen sw4_r001 = `sw4'
	}
	
	est drop ///
		Dmodel_given_C_r001 Dmodel_r001 ///
		Mmodel_given_CDL_r001 Mmodel_given_D_r001
		
	drop phat*_r001

end ipwcdebs
