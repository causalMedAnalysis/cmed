*!TITLE: VENTSIM - analysis of interventional effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define ventsimbs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		lvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		mreg(string) ///
		yreg(string) ///
		lregs(string) ///
		[nsim(integer 200)] ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[lxm] 
			
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
		
	local yvar `varlist'

	/***********************************************************
    CHECK IF NUM OF VARS IN LVAR MATCHES NUM OF COMMANDS IN LREG
	************************************************************/
    local numlvars = wordcount("`lvars'")
    local numlregs = wordcount("`lregs'")

    if `numlvars' != `numlregs' {
        di as err "The number of variables in lvars must match the number of commands in lregs."
        exit 198
	}
	
	/**************
	REG TYPE ERRORS
	***************/
	local yregtypes regress logit poisson
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}

	local mregtypes regress logit poisson
	local nmreg : list posof "`mreg'" in mregtypes
	if !`nmreg' {
		display as error "Error: mreg must be chosen from: `mregtypes'."
		error 198		
	}

	local lregtypes regress logit poisson
	
	local i = 0
	foreach l in `lregs' {
		local i = `i' + 1
		local nlreg : list posof "`l'" in lregtypes
		if !`nlreg' {
			display as error "Error: lreg must be chosen from: `lregtypes'."
			error 198		
		}
		else {
			local lreg`i' : word `nlreg' of `lregtypes'
		}		
	}
	
	/*********************
	VARIABLE EXISTS ERRORS
	**********************/
	local hat_var_names "lhat_Ld_r001 lhat_Ldstar_r001 mhat_Md_r001 mhat_Mdstar_r001 yhat_YdMd_r001 yhat_YdstarMdstar_r001 yhat_YdMdstar_r001"
	foreach name of local hat_var_names {
		capture confirm new variable `name'
		if _rc {
				display as error "{p 0 0 5 0}The command needs to create a variable"
				display as error "with the following name: `name', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
		}
	}
	
	foreach stub in Md_r001 Mdstar_r001 YdMd_r001 YdstarMdstar_r001 YdMdstar_r001 {
		forval i=1/`nsim' {
			capture confirm new variable `stub'_`i'
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create a variable"
				display as error "with the following name: `stub'_`i', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
			}
		}
	}

	forval i = 1/`numlvars' {
		foreach stub in L`i'd_r001 L`i'dstar_r001 {
			forval j = 1/`nsim' {
				capture confirm new variable `stub'_`j'
				if _rc {
					display as error "{p 0 0 5 0}The command needs to create a variable"
					display as error "with the following name: `stub'_`j', "
					display as error "but this variable has already been defined.{p_end}"
					error 110
				}
			}
		}
	}

	/*****************************
	GENERATE INTERACTION VARIABLES
	******************************/
	if ("`nointeraction'" == "") {
		tempvar inter
		gen `inter' = `dvar' * `mvar' if `touse'
	}

	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
		}
	}

	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			tempvar mvarX`c'
			gen `mvarX`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  `mvarX`c''
		}
	}

	if ("`lxm'"!="") {	
		foreach l in `lvars' {
			tempvar mvarX`l'
			gen `mvarX`l'' = `mvar' * `l' if `touse'
			local lxm_vars `lxm_vars'  `mvarX`l''
		}
	}
	
	/***************************************
	PLACEHOLDERS FOR ORIGINAL VALUES OF VARS
	****************************************/
	tempvar `dvar'_orig
	qui gen ``dvar'_orig' = `dvar' if `touse'

	tempvar `mvar'_orig
	qui gen ``mvar'_orig' = `mvar' if `touse'

	foreach l in `lvars' {
		tempvar `l'_orig
		qui gen ``l'_orig' = `l' if `touse'
	}

	/*********
	FIT MODELS
	**********/
	local priorVars = ""
	forval i = 1/`numlvars' {
		
		local currentVar = word("`lvars'", `i')
		local currentReg = word("`lregs'", `i')
	
		di ""
		di "Model for `currentVar' conditional on {cvars `dvar' `priorVars'}:"
		`currentReg' `currentVar' `dvar' `cvars' `cxd_vars' `priorVars' [`weight' `exp'] if `touse'
		est store L`i'model_r001
		
		local prioVars "`priorVars' `currentVar'"
    }
	
	di ""
	di "Model for `mvar' conditional on {cvars `dvar'}:" 
	`mreg' `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
	est store Mmodel_r001
	
	di ""
	di "Model for `yvar' conditional on {cvars `dvar' `lvars' `mvar'}:"
	`yreg' `yvar' `mvar' `dvar' `inter' `cvars' `lvars' `cxd_vars' `cxm_vars' `lxm_vars' [`weight' `exp'] if `touse'
	est store Ymodel_r001
	
	/**************************
	SIMULATE POTENTIAL OUTCOMES
	***************************/
	qui forval i=1/`nsim' {
	
		/*****LVARS*****/
		local priorVars = ""
		forval j = 1/`numlvars' {
		
			est restore L`j'model_r001

			local currentVar = word("`lvars'", `j')
			local currentReg = word("`lregs'", `j')
			
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}

			if ("`priorVars'"!="") {	
				local numPred = wordcount("`priorVars'")
				forval k = 1/`numPred' {
					local currentPred = word("`prioVars'", `k')
					replace `currentPred' = L`k'd_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				predict lhat_Ld_r001 if `touse'
				gen L`j'd_r001_`i'=rnormal(lhat_Ld_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				predict lhat_Ld_r001 if `touse', pr
				gen L`j'd_r001_`i'=rbinomial(1,lhat_Ld_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				predict lhat_Ld_r001 if `touse'
				gen L`j'd_r001_`i'=rpoisson(lhat_Ld_r001) if `touse'
			}				
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}

			if ("`priorVars'"!="") {	
				local numPred = wordcount("`priorVars'")
				forval k = 1/`numPred' {
					local currentPred = word("`prioVars'", `k')
					replace `currentPred' = L`k'dstar_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				predict lhat_Ldstar_r001 if `touse'
				gen L`j'dstar_r001_`i'=rnormal(lhat_Ldstar_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				predict lhat_Ldstar_r001 if `touse', pr
				gen L`j'dstar_r001_`i'=rbinomial(1,lhat_Ldstar_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				predict lhat_Ldstar_r001 if `touse'
				gen L`j'dstar_r001_`i'=rpoisson(lhat_Ldstar_r001) if `touse'
			}				

		local prioVars "`priorVars' `currentVar'"
		
		drop lhat_Ld_r001 lhat_Ldstar_r001
        }

		/*****MVAR*****/
		est restore Mmodel_r001
			
		replace `dvar'=`d' if `touse'
			
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}

		if ("`mreg'"=="regress") {
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rnormal(mhat_Md_r001,e(rmse)) if `touse'
		}
		
		if ("`mreg'"=="logit") {
			predict mhat_Md_r001 if `touse', pr
			gen Md_r001_`i'=rbinomial(1,mhat_Md_r001) if `touse'
		}
		
		if ("`mreg'"=="poisson") {
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rpoisson(mhat_Md_r001) if `touse'
		}
			
		replace `dvar'=`dstar' if `touse'
			
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}
			
		if ("`mreg'"=="regress") {
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rnormal(mhat_Mdstar_r001,e(rmse)) if `touse'
		}
		
		if ("`mreg'"=="logit") {
			predict mhat_Mdstar_r001 if `touse', pr
			gen Mdstar_r001_`i'=rbinomial(1,mhat_Mdstar_r001) if `touse'
		}
		
		if ("`mreg'"=="poisson") {
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rpoisson(mhat_Mdstar_r001) if `touse'
		}
	
		drop mhat_Md_r001 mhat_Mdstar_r001
		
		/*****YVAR*****/
		est restore Ymodel_r001
		
		replace `dvar'=`d' if `touse'
		replace `mvar'=Md_r001_`i' if `touse'

		if ("`nointeraction'" == "") {
			replace `inter' = `dvar' * `mvar' if `touse'
		}
				
		forval j = 1/`numlvars' {
			local currentVar = word("`lvars'", `j')
			replace `currentVar' = L`j'd_r001_`i' if `touse'
		}
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			
			
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				replace `mvarX`c'' = `mvar' * `c' if `touse'
			}
		}
				
		if ("`lxm'"!="") {	
			foreach l in `lvars' {
				replace `mvarX`l'' = `mvar' * `l' if `touse'
			}
		}
		
		if ("`yreg'"=="regress") {
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rnormal(yhat_YdMd_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			predict yhat_YdMd_r001 if `touse', pr
			gen YdMd_r001_`i'=rbinomial(1,yhat_YdMd_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rpoisson(yhat_YdMd_r001) if `touse'
		}

		replace `dvar'=`dstar' if `touse'
		replace `mvar'=Mdstar_r001_`i' if `touse'

		if ("`nointeraction'" == "") {
			replace `inter' = `dvar' * `mvar' if `touse'
		}
			
		forval j = 1/`numlvars' {
			local currentVar = word("`lvars'", `j')
			replace `currentVar' = L`j'dstar_r001_`i' if `touse'
		}
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			
			
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				replace `mvarX`c'' = `mvar' * `c' if `touse'
			}
		}
				
		if ("`lxm'"!="") {	
			foreach l in `lvars' {
				replace `mvarX`l'' = `mvar' * `l' if `touse'
			}
		}
		
		if ("`yreg'"=="regress") {
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rnormal(yhat_YdstarMdstar_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			predict yhat_YdstarMdstar_r001 if `touse', pr
			gen YdstarMdstar_r001_`i'=rbinomial(1,yhat_YdstarMdstar_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rpoisson(yhat_YdstarMdstar_r001) if `touse'
		}			
			
		replace `dvar'=`d' if `touse'
		replace `mvar'=Mdstar_r001_`i' if `touse'

		if ("`nointeraction'" == "") {
			replace `inter' = `dvar' * `mvar' if `touse'
		}
			
		forval j = 1/`numlvars' {
			local currentVar = word("`lvars'", `j')
			replace `currentVar' = L`j'd_r001_`i' if `touse'
		}
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			
			
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				replace `mvarX`c'' = `mvar' * `c' if `touse'
			}
		}
				
		if ("`lxm'"!="") {	
			foreach l in `lvars' {
				replace `mvarX`l'' = `mvar' * `l' if `touse'
			}
		}
		
		if ("`yreg'"=="regress") {
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rnormal(yhat_YdMdstar_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			predict yhat_YdMdstar_r001 if `touse', pr
			gen YdMdstar_r001_`i'=rbinomial(1,yhat_YdMdstar_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rpoisson(yhat_YdMdstar_r001) if `touse'
		}
			
		drop yhat_*r001 Md_r001_`i' Mdstar_r001_`i' L*d_r001_`i' L*dstar_r001_`i' 
	
	}
	
	est drop Mmodel_r001 Ymodel_r001 L*model_r001

	qui replace `dvar' = ``dvar'_orig' if `touse'
	qui replace `mvar' = ``mvar'_orig' if `touse'
	
	foreach l in `lvars' {
		qui replace `l' = ``l'_orig' if `touse'
	}
	
	tempvar YdMd_r001
	tempvar YdstarMdstar_r001
	tempvar YdMdstar_r001
	
	qui egen `YdMd_r001'=rowmean(YdMd_r001_*) if `touse'
	qui egen `YdstarMdstar_r001'=rowmean(YdstarMdstar_r001_*) if `touse'
	qui egen `YdMdstar_r001'=rowmean(YdMdstar_r001_*) if `touse'
	
	qui reg `YdMd_r001' [`weight' `exp'] if `touse'
	local Ehat_YdMd=_b[_cons]

	qui reg `YdstarMdstar_r001' [`weight' `exp'] if `touse'
	local Ehat_YdstarMdstar=_b[_cons]

	qui reg `YdMdstar_r001' [`weight' `exp'] if `touse'
	local Ehat_YdMdstar=_b[_cons]

	return scalar ide=`Ehat_YdMdstar'-`Ehat_YdstarMdstar'
	return scalar iie=`Ehat_YdMd'-`Ehat_YdMdstar'	
	return scalar oe=`Ehat_YdMd'-`Ehat_YdstarMdstar'

	drop YdMd_r001_* YdstarMdstar_r001_* YdMdstar_r001_* 
		
end ventsimbs
