*!TITLE: MNESIM - analysis of multivariate natural effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define mnesimbs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		mregs(string) ///
		[nsim(integer 200)] ///
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

	/*************************************************************
    CHECK IF NUM OF VARS IN MVARS MATCHES NUM OF COMMANDS IN MREGS
	**************************************************************/
    local numMvars = wordcount("`mvars'")
    local numMregs = wordcount("`mregs'")

    if `numMvars' != `numMregs' {
        di as err "The number of variables in mvars must match the number of commands in mregs."
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

	local mregtypes regress logit ologit poisson
	local i = 0
	foreach l in `mregs' {
		local i = `i' + 1
		local nmreg : list posof "`l'" in mregtypes
		if !`nmreg' {
			display as error "Error: mregs must be chosen from: `mregtypes'."
			error 198		
		}
		else {
			local mreg`i' : word `nmreg' of `mregtypes'
		}		
	}
	
	/*********************
	VARIABLE EXISTS ERRORS
	**********************/
	local hat_var_names "mhat_Md_r001 mhat_Mdstar_r001 yhat_YdMd_r001 yhat_YdstarMdstar_r001 yhat_YdMdstar_r001"
	foreach name of local hat_var_names {
		capture confirm new variable `name'
		if _rc {
				display as error "{p 0 0 5 0}The command needs to create a variable"
				display as error "with the following name: `name', "
				display as error "but this variable has already been defined.{p_end}"
				error 110
		}
	}

	if ("`yreg'"=="ologit") {

		local yhat_var_names "yhat_YdMd_r001 yhat_YdstarMdstar_r001 yhat_YdMdstar_r001"
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

	foreach stub in YdMd_r001 YdstarMdstar_r001 YdMdstar_r001 {
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

	forval i = 1/`numMvars' {
		foreach stub in M`i'd_r001 M`i'dstar_r001 {
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
	local inter = ""
	if ("`nointeraction'"=="") {
		foreach m in `mvars' {
			tempvar Dx_`m'
				if _rc {
					display as error "{p 0 0 5 0}The command needs to create a new variable"
					display as error "with the following name: Dx_`m', "
					display as error "but this variable has already been defined.{p_end}"
					error 110
				}
			qui gen `Dx_`m'' = `dvar' * `m' if `touse'
			local inter `inter' `Dx_`m''
		}
	}
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
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
	
	/***************************************
	PLACEHOLDERS FOR ORIGINAL VALUES OF VARS
	****************************************/
	tempvar `dvar'_orig
	qui gen ``dvar'_orig' = `dvar' if `touse'

	foreach m in `mvars' {
		tempvar `m'_orig
		qui gen ``m'_orig' = `m' if `touse'
	}

	/*********
	FIT MODELS
	**********/
	local priorVars = ""
	forval i = 1/`numMvars' {
		
		local currentVar = word("`mvars'", `i')
		local currentReg = word("`mregs'", `i')
	
		di ""
		di "{bf:Model for `currentVar' conditional on {cvars `dvar' `priorVars'}:}"
		`currentReg' `currentVar' `dvar' `cvars' `cxd_vars' `priorVars' [`weight' `exp'] if `touse'
		est store M`i'model_r001
		
		local priorVars "`priorVars' `currentVar'"
    }
	
	di ""
	di "{bf:Model for `yvar' conditional on {cvars `dvar' `mvars'}:}"
	`yreg' `yvar' `mvars' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
	est store Ymodel_r001
	
	/**************************
	SIMULATE POTENTIAL OUTCOMES
	***************************/
	qui forval i=1/`nsim' {
	
		/*****MVARS*****/
		local priorVars = ""
		forval j = 1/`numMvars' {
		
			est restore M`j'model_r001

			local currentVar = word("`mvars'", `j')
			local currentReg = word("`mregs'", `j')
			
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
					replace `currentPred' = M`k'd_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				qui predict mhat_Md_r001 if `touse'
				qui gen M`j'd_r001_`i'=rnormal(mhat_Md_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				qui predict mhat_Md_r001 if `touse', pr
				qui gen M`j'd_r001_`i'=rbinomial(1,mhat_Md_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				qui predict mhat_Md_r001 if `touse'
				qui gen M`j'd_r001_`i'=rpoisson(mhat_Md_r001) if `touse'
			}				

			if ("`currentReg'"=="ologit") {
				
				qui levelsof `currentVar' if `touse', local(levels)
				qui local maxLevel : word `: word count `levels'' of `levels'
		
				foreach level in `levels' {
					
					capture confirm new variable mhat_Md_r001_`level'
						if _rc {
							display as error "{p 0 0 5 0}The command needs to create a variable"
							display as error "with the following name: mhat_Md_r001_`level', "
							display as error "but this variable has already been defined.{p_end}"
							error 110
						}
					
					qui predict mhat_Md_r001_`level' if `touse', pr outcome(`level')
				}
				
				tempvar sum_of_p unif
				qui gen `sum_of_p' = 0
				qui gen `unif' = uniform()

				qui gen M`j'd_r001_`i'=`maxLevel' if `touse'
			
				foreach level in `levels' {
					replace `sum_of_p' = `sum_of_p' + mhat_Md_r001_`level'
					replace M`j'd_r001_`i' = min(M`j'd_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
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
					replace `currentPred' = M`k'dstar_r001_`i' if `touse'
				}
			}
			
			if ("`currentReg'"=="regress") {
				qui predict mhat_Mdstar_r001 if `touse'
				qui gen M`j'dstar_r001_`i'=rnormal(mhat_Mdstar_r001,e(rmse)) if `touse'
			}
			
			if ("`currentReg'"=="logit") {
				qui predict mhat_Mdstar_r001 if `touse', pr
				qui gen M`j'dstar_r001_`i'=rbinomial(1,mhat_Mdstar_r001) if `touse'
			}

			if ("`currentReg'"=="poisson") {
				qui predict mhat_Mdstar_r001 if `touse'
				qui gen M`j'dstar_r001_`i'=rpoisson(mhat_Mdstar_r001) if `touse'
			}				

			if ("`currentReg'"=="ologit") {
				
				qui levelsof `currentVar' if `touse', local(levels)
				qui local maxLevel : word `: word count `levels'' of `levels'
		
				foreach level in `levels' {
					
					capture confirm new variable mhat_Mdstar_r001_`level'
						if _rc {
							display as error "{p 0 0 5 0}The command needs to create a variable"
							display as error "with the following name: mhat_Mdstar_r001_`level', "
							display as error "but this variable has already been defined.{p_end}"
							error 110
						}
					
					qui predict mhat_Mdstar_r001_`level' if `touse', pr outcome(`level')
				}
				
				tempvar sum_of_p unif
				qui gen `sum_of_p' = 0
				qui gen `unif' = uniform()

				qui gen M`j'dstar_r001_`i'=`maxLevel' if `touse'
			
				foreach level in `levels' {
					replace `sum_of_p' = `sum_of_p' + mhat_Mdstar_r001_`level'
					replace M`j'dstar_r001_`i' = min(M`j'dstar_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
				}
			
				drop `sum_of_p' `unif'
			}	
			
		local priorVars "`priorVars' `currentVar'"
		
		drop mhat_Md_r001* mhat_Mdstar_r001*
        }

		/*****YVAR*****/
		est restore Ymodel_r001
		
		replace `dvar'=`d' if `touse'

		forval j = 1/`numMvars' {
			local currentVar = word("`mvars'", `j')
			replace `currentVar' = M`j'd_r001_`i' if `touse'
		}

		if ("`nointeraction'"=="") {
			foreach m in `mvars' {
				replace `Dx_`m'' = `dvar' * `m' if `touse'
			}
		}		
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			

		local k = 1
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				foreach m in `mvars' {
					replace `mXc`k'' = `m' * `c' if `touse'
					local ++k
				}
			}
		}
	
		if ("`yreg'"=="regress") {
			qui predict yhat_YdMd_r001 if `touse'
			qui gen YdMd_r001_`i'=rnormal(yhat_YdMd_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			qui predict yhat_YdMd_r001 if `touse', pr
			qui gen YdMd_r001_`i'=rbinomial(1,yhat_YdMd_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			qui predict yhat_YdMd_r001 if `touse'
			qui gen YdMd_r001_`i'=rpoisson(yhat_YdMd_r001) if `touse'
		}

		if ("`yreg'"=="ologit") {
			
			qui levelsof `yvar' if `touse', local(levels)
			qui local maxLevel : word `: word count `levels'' of `levels'
		
			foreach level in `levels' {
				qui predict yhat_YdMd_r001_`level' if `touse', pr outcome(`level')
			}
				
			tempvar sum_of_p unif
			qui gen `sum_of_p' = 0
			qui gen `unif' = uniform()

			qui gen YdMd_r001_`i'=`maxLevel' if `touse'
			
			foreach level in `levels' {
				replace `sum_of_p' = `sum_of_p' + yhat_YdMd_r001_`level'
				replace YdMd_r001_`i' = min(YdMd_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
			}
		
			drop `sum_of_p' `unif'
		}	
		
		replace `dvar'=`dstar' if `touse'

		forval j = 1/`numMvars' {
			local currentVar = word("`mvars'", `j')
			replace `currentVar' = M`j'dstar_r001_`i' if `touse'
		}		
		
		if ("`nointeraction'"=="") {
			foreach m in `mvars' {
				replace `Dx_`m'' = `dvar' * `m' if `touse'
			}
		}		
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			

		local k = 1
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				foreach m in `mvars' {
					replace `mXc`k'' = `m' * `c' if `touse'
					local ++k
				}
			}
		}		
		
		if ("`yreg'"=="regress") {
			qui predict yhat_YdstarMdstar_r001 if `touse'
			qui gen YdstarMdstar_r001_`i'=rnormal(yhat_YdstarMdstar_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			qui predict yhat_YdstarMdstar_r001 if `touse', pr
			qui gen YdstarMdstar_r001_`i'=rbinomial(1,yhat_YdstarMdstar_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			qui predict yhat_YdstarMdstar_r001 if `touse'
			qui gen YdstarMdstar_r001_`i'=rpoisson(yhat_YdstarMdstar_r001) if `touse'
		}			

		if ("`yreg'"=="ologit") {
			
			qui levelsof `yvar' if `touse', local(levels)
			qui local maxLevel : word `: word count `levels'' of `levels'
		
			foreach level in `levels' {
				qui predict yhat_YdstarMdstar_r001_`level' if `touse', pr outcome(`level')
			}
				
			tempvar sum_of_p unif
			qui gen `sum_of_p' = 0
			qui gen `unif' = uniform()

			qui gen YdstarMdstar_r001_`i'=`maxLevel' if `touse'
			
			foreach level in `levels' {
				replace `sum_of_p' = `sum_of_p' + yhat_YdstarMdstar_r001_`level'
				replace YdstarMdstar_r001_`i' = min(YdstarMdstar_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
			}
		
			drop `sum_of_p' `unif'
		}	
		
		replace `dvar'=`d' if `touse'
		
		forval j = 1/`numMvars' {
			local currentVar = word("`mvars'", `j')
			replace `currentVar' = M`j'dstar_r001_`i' if `touse'
		}		
		
		if ("`nointeraction'"=="") {
			foreach m in `mvars' {
				replace `Dx_`m'' = `dvar' * `m' if `touse'
			}
		}		
		
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			

		local k = 1
		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				foreach m in `mvars' {
					replace `mXc`k'' = `m' * `c' if `touse'
					local ++k
				}
			}
		}	
		
		if ("`yreg'"=="regress") {
			qui predict yhat_YdMdstar_r001 if `touse'
			qui gen YdMdstar_r001_`i'=rnormal(yhat_YdMdstar_r001,e(rmse)) if `touse'
		}

		if ("`yreg'"=="logit") {
			qui predict yhat_YdMdstar_r001 if `touse', pr
			qui gen YdMdstar_r001_`i'=rbinomial(1,yhat_YdMdstar_r001) if `touse'
		}

		if ("`yreg'"=="poisson") {
			qui predict yhat_YdMdstar_r001 if `touse'
			qui gen YdMdstar_r001_`i'=rpoisson(yhat_YdMdstar_r001) if `touse'
		}

		if ("`yreg'"=="ologit") {
			
			qui levelsof `yvar' if `touse', local(levels)
			qui local maxLevel : word `: word count `levels'' of `levels'
		
			foreach level in `levels' {
				qui predict yhat_YdMdstar_r001_`level' if `touse', pr outcome(`level')
			}
				
			tempvar sum_of_p unif
			qui gen `sum_of_p' = 0
			qui gen `unif' = uniform()

			qui gen YdMdstar_r001_`i'=`maxLevel' if `touse'
			
			foreach level in `levels' {
				replace `sum_of_p' = `sum_of_p' + yhat_YdMdstar_r001_`level'
				replace YdMdstar_r001_`i' = min(YdMdstar_r001_`i',`level') if `unif' < `sum_of_p' & `touse'
			}
		
			drop `sum_of_p' `unif'
		}	
		
		drop yhat_*r001* M*d_r001_`i' M*dstar_r001_`i' 
	
	}
	
	est drop Ymodel_r001 M*model_r001

	qui replace `dvar' = ``dvar'_orig' if `touse'
	
	foreach m in `mvars' {
		qui replace `m' = ``m'_orig' if `touse'
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

	return scalar mnde=`Ehat_YdMdstar'-`Ehat_YdstarMdstar'
	return scalar mnie=`Ehat_YdMd'-`Ehat_YdMdstar'	
	return scalar ate=`Ehat_YdMd'-`Ehat_YdstarMdstar'

	drop YdMd_r001_* YdstarMdstar_r001_* YdMdstar_r001_* 
		
end mnesimbs
