*!TITLE: SIMCDE - estimate controlled direct effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define simcdebs, eclass properties(svyb)
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight iweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		lvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
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
	local yregtypes regress logit ologit poisson
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}

	local lregtypes regress logit ologit poisson
	
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
	local hat_var_names "lhat_Ld_r001 lhat_Ldstar_r001 yhat_Ydm_r001 yhat_Ydstarm_r001"
	foreach name of local hat_var_names {
		capture confirm new variable `name'
		if _rc {
				display as error "{p 0 0 5 0}The command needs to create a variable"
				display as error "with the following name: `name', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
		}
	}
	
	foreach stub in Ydm_r001 Ydstarm_r001 {
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

	if ("`yreg'"=="ologit") {

		local yhat_var_names "yhat_Ydm_r001 yhat_Ydstarm_r001"
		qui levelsof `yvar' if `touse', local(levelsY)

		foreach name of local yhat_var_names {
			foreach level in `levelsY' {
				capture confirm new variable `name'_`level'
				if _rc {
					display as error "{p 0 0 5 0}The command needs to create a variable"
					display as error "with the following name: `name'_`level', "
					display as error "but this variable has already been defined.{p_end}"
					error 110
				}
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
		qui gen `inter' = `dvar' * `mvar' if `touse'
	}

	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
		}
	}

	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			tempvar mvarX`c'
			qui gen `mvarX`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  `mvarX`c''
		}
	}

	if ("`lxm'"!="") {	
		foreach l in `lvars' {
			tempvar mvarX`l'
			qui gen `mvarX`l'' = `mvar' * `l' if `touse'
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
		di "{bf:Model for `currentVar' conditional on {cvars `dvar' `priorVars'}:}"
		`currentReg' `currentVar' `dvar' `cvars' `cxd_vars' `priorVars' [`weight' `exp'] if `touse'
		est store L`i'model_r001
		
		local priorVars "`priorVars' `currentVar'"
    }
	
	di ""
	di "{bf:Model for `yvar' conditional on {cvars `dvar' `lvars' `mvar'}:}"
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
					local currentPred = word("`priorVars'", `k')
					replace `currentPred' = L`k'd_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				qui predict lhat_Ld_r001 if `touse'
				qui gen L`j'd_r001_`i'=rnormal(lhat_Ld_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				qui predict lhat_Ld_r001 if `touse', pr
				qui gen L`j'd_r001_`i'=rbinomial(1,lhat_Ld_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				qui predict lhat_Ld_r001 if `touse'
				qui gen L`j'd_r001_`i'=rpoisson(lhat_Ld_r001) if `touse'
			}				

			if ("`currentReg'"=="ologit") {
				
				qui levelsof `currentVar' if `touse', local(levels)
				qui local maxLevel : word `: word count `levels'' of `levels'
		
				foreach level in `levels' {
					
					capture confirm new variable lhat_Ld_r001_`level'
						if _rc {
							display as error "{p 0 0 5 0}The command needs to create a variable"
							display as error "with the following name: lhat_Ld_r001_`level', "
							display as error "but this variable has already been defined.{p_end}"
							error 110
						}
					
					qui predict lhat_Ld_r001_`level' if `touse', pr outcome(`level')
				}
				
				tempvar sum_of_p unif
				qui gen `sum_of_p' = 0
				qui gen `unif' = uniform()

				qui gen L`j'd_r001_`i'=`maxLevel' if `touse'
			
				foreach level in `levels' {
					replace `sum_of_p' = `sum_of_p' + lhat_Ld_r001_`level'
					replace L`j'd_r001_`i' = min(L`j'd_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
				}
			
				drop `sum_of_p' `unif'
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
					local currentPred = word("`priorVars'", `k')
					replace `currentPred' = L`k'dstar_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				qui predict lhat_Ldstar_r001 if `touse'
				qui gen L`j'dstar_r001_`i'=rnormal(lhat_Ldstar_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				qui predict lhat_Ldstar_r001 if `touse', pr
				qui gen L`j'dstar_r001_`i'=rbinomial(1,lhat_Ldstar_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				qui predict lhat_Ldstar_r001 if `touse'
				qui gen L`j'dstar_r001_`i'=rpoisson(lhat_Ldstar_r001) if `touse'
			}				

			if ("`currentReg'"=="ologit") {
				
				qui levelsof `currentVar' if `touse', local(levels)
				qui local maxLevel : word `: word count `levels'' of `levels'
		
				foreach level in `levels' {
					
					capture confirm new variable lhat_Ldstar_r001_`level'
						if _rc {
							display as error "{p 0 0 5 0}The command needs to create a variable"
							display as error "with the following name: lhat_Ldstar_r001_`level', "
							display as error "but this variable has already been defined.{p_end}"
							error 110
						}
					
					qui predict lhat_Ldstar_r001_`level' if `touse', pr outcome(`level')
				}
				
				tempvar sum_of_p unif
				qui gen `sum_of_p' = 0
				qui gen `unif' = uniform()

				qui gen L`j'dstar_r001_`i'=`maxLevel' if `touse'
			
				foreach level in `levels' {
					replace `sum_of_p' = `sum_of_p' + lhat_Ldstar_r001_`level'
					replace L`j'dstar_r001_`i' = min(L`j'dstar_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
				}
			
				drop `sum_of_p' `unif'
			}	
	
		local priorVars "`priorVars' `currentVar'"
		
		drop lhat_Ld_r001* lhat_Ldstar_r001*
        }

		/*****YVAR*****/
		est restore Ymodel_r001
		
		replace `dvar'=`d' if `touse'
		replace `mvar'=`m' if `touse'

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
			qui predict yhat_Ydm_r001 if `touse'
			qui gen Ydm_r001_`i'=rnormal(yhat_Ydm_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			qui predict yhat_Ydm_r001 if `touse', pr
			qui gen Ydm_r001_`i'=rbinomial(1,yhat_Ydm_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			qui predict yhat_Ydm_r001 if `touse'
			qui gen Ydm_r001_`i'=rpoisson(yhat_Ydm_r001) if `touse'
		}

		if ("`yreg'"=="ologit") {
			
			qui levelsof `yvar' if `touse', local(levels)
			qui local maxLevel : word `: word count `levels'' of `levels'
		
			foreach level in `levels' {
				qui predict yhat_Ydm_r001_`level' if `touse', pr outcome(`level')
			}
				
			tempvar sum_of_p unif
			qui gen `sum_of_p' = 0
			qui gen `unif' = uniform()

			qui gen Ydm_r001_`i'=`maxLevel' if `touse'
			
			foreach level in `levels' {
				replace `sum_of_p' = `sum_of_p' + yhat_Ydm_r001_`level'
				replace Ydm_r001_`i' = min(Ydm_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
			}
		
			drop `sum_of_p' `unif'
		}	
		
		replace `dvar'=`dstar' if `touse'

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
			
		if ("`yreg'"=="regress") {
			qui predict yhat_Ydstarm_r001 if `touse'
			qui gen Ydstarm_r001_`i'=rnormal(yhat_Ydstarm_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			qui predict yhat_Ydstarm_r001 if `touse', pr
			qui gen Ydstarm_r001_`i'=rbinomial(1,yhat_Ydstarm_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			qui predict yhat_Ydstarm_r001 if `touse'
			qui gen Ydstarm_r001_`i'=rpoisson(yhat_Ydstarm_r001) if `touse'
		}

		if ("`yreg'"=="ologit") {
			
			qui levelsof `yvar' if `touse', local(levels)
			qui local maxLevel : word `: word count `levels'' of `levels'
		
			foreach level in `levels' {
				qui predict yhat_Ydstarm_r001_`level' if `touse', pr outcome(`level')
			}
				
			tempvar sum_of_p unif
			qui gen `sum_of_p' = 0
			qui gen `unif' = uniform()

			qui gen Ydstarm_r001_`i'=`maxLevel' if `touse'
			
			foreach level in `levels' {
				replace `sum_of_p' = `sum_of_p' + yhat_Ydstarm_r001_`level'
				replace Ydstarm_r001_`i' = min(Ydstarm_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
			}
		
			drop `sum_of_p' `unif'
		}	
		
		drop yhat_*r001* L*d_r001_`i' L*dstar_r001_`i' 
	
	}
	
	est drop Ymodel_r001 L*model_r001

	qui replace `dvar' = ``dvar'_orig' if `touse'
	qui replace `mvar' = ``mvar'_orig' if `touse'
	
	foreach l in `lvars' {
		qui replace `l' = ``l'_orig' if `touse'
	}
	
	tempvar Ydm_r001 Ydstarm_r001
	
	qui egen `Ydm_r001'=rowmean(Ydm_r001_*) if `touse'
	qui egen `Ydstarm_r001'=rowmean(Ydstarm_r001_*) if `touse'

	drop Ydm_r001_* Ydstarm_r001_* 
	
	qui reg `Ydm_r001' [`weight' `exp'] if `touse'
	local Ehat_Ydm=_b[_cons]

	qui reg `Ydstarm_r001' [`weight' `exp'] if `touse'
	local Ehat_Ydstarm=_b[_cons]
	
	tempname cde
	scalar `cde' = `Ehat_Ydm' - `Ehat_Ydstarm'

	ereturn clear

	tempname b 
	
	matrix `b' = (`cde')
	matrix colnames `b' = "CDE"	
	
	ereturn post `b' , esample(`touse') obs(`N')
		
end simcdebs
