*!TITLE: MEDSIM - causal mediation analysis using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define medsimbs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		mreg(string) ///
		yreg(string) ///
		nsim(integer) ///
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
			tempvar `mvar'X`c'
			gen ``mvar'X`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  ``mvar'X`c''
		}
	}
	
	tempvar `dvar'_orig_r001
	qui gen ``dvar'_orig_r001' = `dvar' if `touse'

	tempvar `mvar'_orig_r001
	qui gen ``mvar'_orig_r001' = `mvar' if `touse'

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
	
	if (("`mreg'"=="regress") & ("`yreg'"=="regress")) {
		
		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		regress `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		regress `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
			
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}

			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rnormal(mhat_Md_r001,e(rmse)) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rnormal(mhat_Mdstar_r001,e(rmse)) if `touse'
			
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}

			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rnormal(yhat_YdMd_r001,e(rmse)) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}
				
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rnormal(yhat_YdstarMdstar_r001,e(rmse)) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rnormal(yhat_YdMdstar_r001,e(rmse)) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
			
		est drop Mmodel_r001 Ymodel_r001
	
	}

	if (("`mreg'"=="logit") & ("`yreg'"=="regress")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		logit `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		regress `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'

			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}
				
			predict mhat_Md_r001 if `touse', pr
			gen Md_r001_`i'=rbinomial(1,mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}
				
			predict mhat_Mdstar_r001 if `touse', pr
			gen Mdstar_r001_`i'=rbinomial(1,mhat_Mdstar_r001) if `touse'

			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'

			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rnormal(yhat_YdMd_r001,e(rmse)) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'

			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}			
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rnormal(yhat_YdstarMdstar_r001,e(rmse)) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rnormal(yhat_YdMdstar_r001,e(rmse)) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
				
	}

	if (("`mreg'"=="poisson") & ("`yreg'"=="regress")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		poisson `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		regress `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rpoisson(mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rpoisson(mhat_Mdstar_r001) if `touse'
		
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}			
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rnormal(yhat_YdMd_r001,e(rmse)) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}			

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}			
				
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rnormal(yhat_YdstarMdstar_r001,e(rmse)) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}						
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rnormal(yhat_YdMdstar_r001,e(rmse)) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
		
	}

	if (("`mreg'"=="regress") & ("`yreg'"=="logit")) {
		
		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		regress `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		logit `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
			
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}						
			
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rnormal(mhat_Md_r001,e(rmse)) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}						
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rnormal(mhat_Mdstar_r001,e(rmse)) if `touse'
			
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'

			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}						

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}		
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rbinomial(1,yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}						

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}					
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rbinomial(1,yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}				
				
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rbinomial(1,yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
			
		est drop Mmodel_r001 Ymodel_r001
	
	}

	if (("`mreg'"=="logit") & ("`yreg'"=="logit")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		logit `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		logit `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}				
				
			predict mhat_Md_r001 if `touse', pr
			gen Md_r001_`i'=rbinomial(1,mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict mhat_Mdstar_r001 if `touse', pr
			gen Mdstar_r001_`i'=rbinomial(1,mhat_Mdstar_r001) if `touse'

			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}					
			
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rbinomial(1,yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}								
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rbinomial(1,yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rbinomial(1,yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
		
	}

	if (("`mreg'"=="poisson") & ("`yreg'"=="logit")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		poisson `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		logit `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rpoisson(mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rpoisson(mhat_Mdstar_r001) if `touse'
		
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}				
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rbinomial(1,yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}				
				
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rbinomial(1,yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}										
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rbinomial(1,yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
		
	}


	if (("`mreg'"=="regress") & ("`yreg'"=="poisson")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		regress `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		poisson `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
			
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
				
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rnormal(mhat_Md_r001,e(rmse)) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}										
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rnormal(mhat_Mdstar_r001,e(rmse)) if `touse'
			
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'

			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}										

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}				
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rpoisson(yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}										

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}							
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rpoisson(yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rpoisson(yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
			
		est drop Mmodel_r001 Ymodel_r001
	
	}

	if (("`mreg'"=="logit") & ("`yreg'"=="poisson")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		logit `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001

		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		poisson `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict mhat_Md_r001 if `touse', pr
			gen Md_r001_`i'=rbinomial(1,mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict mhat_Mdstar_r001 if `touse', pr
			gen Mdstar_r001_`i'=rbinomial(1,mhat_Mdstar_r001) if `touse'

			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
					}
				}							

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}									
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rpoisson(yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}											
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rpoisson(yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d' if `touse'

			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}								
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rpoisson(yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
		
	}

	if (("`mreg'"=="poisson") & ("`yreg'"=="poisson")) {

		di ""
		di "Model for `mvar' conditional on {cvars `dvar'}:"
		poisson `mvar' `dvar' `cvars' `cxd_vars' [`weight' `exp'] if `touse'
		est store Mmodel_r001
				
		di ""
		di "Model for `yvar' conditional on {cvars `dvar' `mvar'}:"
		poisson `yvar' `mvar' `dvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		est store Ymodel_r001
		
		qui forval i=1/`nsim' {
		
			est restore Mmodel_r001
		
			replace `dvar'=`d' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}					
				
			predict mhat_Md_r001 if `touse'
			gen Md_r001_`i'=rpoisson(mhat_Md_r001) if `touse'
		
			replace `dvar'=`dstar' if `touse'
			
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}								
			
			predict mhat_Mdstar_r001 if `touse'
			gen Mdstar_r001_`i'=rpoisson(mhat_Mdstar_r001) if `touse'
		
			est restore Ymodel_r001
			
			replace `dvar'=`d' if `touse'
			replace `mvar'=Md_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}								

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}								
				
			predict yhat_YdMd_r001 if `touse'
			gen YdMd_r001_`i'=rpoisson(yhat_YdMd_r001) if `touse'
					
			replace `dvar'=`dstar' if `touse'
			replace `mvar'=Mdstar_r001_`i' if `touse'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}								

			if ("`cxm'"!="") {	
				foreach c in `cvars' {
					replace ``mvar'X`c'' = `mvar' * `c' if `touse'
				}
			}									
			
			predict yhat_YdstarMdstar_r001 if `touse'
			gen YdstarMdstar_r001_`i'=rpoisson(yhat_YdstarMdstar_r001) if `touse'
			
			replace `dvar'=`d'
			
			if ("`nointeraction'" == "") {
				replace `inter' = `dvar' * `mvar' if `touse'
			}
				
			if ("`cxd'"!="") {	
				foreach c in `cvars' {
					replace ``dvar'X`c'' = `dvar' * `c' if `touse'
				}
			}							
			
			predict yhat_YdMdstar_r001 if `touse'
			gen YdMdstar_r001_`i'=rpoisson(yhat_YdMdstar_r001) if `touse'
					
			drop mhat_*r001 yhat_*r001 Md_r001_`i' Mdstar_r001_`i' 
		
		}
		
		est drop Mmodel_r001 Ymodel_r001
	
	}

	qui replace `dvar' = ``dvar'_orig_r001' if `touse'
	qui replace `mvar' = ``mvar'_orig_r001' if `touse'

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

	return scalar ate=`Ehat_YdMd'-`Ehat_YdstarMdstar'
	return scalar nde=`Ehat_YdMdstar'-`Ehat_YdstarMdstar'
	return scalar nie=`Ehat_YdMd'-`Ehat_YdMdstar'	

	drop YdMd_r001_* YdstarMdstar_r001_* YdMdstar_r001_* 
		
end medsimbs
