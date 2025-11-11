*!TITLE: PATHWIMP - path-specific effects using an imputation-based weighting estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define pathwimpbs, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
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
	
	local num_mvars = wordcount("`mvars'")
	
	local i = 1
	foreach v of local mvars {
		local mvar`i' `v'
		local ++i
	}
	
	if (`num_mvars' == 1) {
	
		mpathwimp `yvar' `mvars' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
	
		return scalar nde=r(nde)
		return scalar nie=r(nie)
		return scalar ate=r(ate)
	
	}

	if (`num_mvars' == 2) {
	
		mpathwimp `yvar' `mvar1' `mvar2' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
	
		qui scalar mnde_M1M2=r(nde)

		mpathwimp `yvar' `mvar1' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
		
		qui scalar mnde_M1=r(nde)
		
		return scalar pse_DY=mnde_M1M2
		return scalar pse_DM2Y=mnde_M1-mnde_M1M2
		return scalar pse_DM1Y=r(nie)
		return scalar ate=r(ate)
		
	}

	if (`num_mvars' == 3) {
	
		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
	
		qui scalar mnde_M1M2M3=r(nde)

		mpathwimp `yvar' `mvar1' `mvar2' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
		
		qui scalar mnde_M1M2=r(nde)
		
		mpathwimp `yvar' `mvar1' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
		
		qui scalar mnde_M1=r(nde)
		
		return scalar pse_DY=mnde_M1M2M3
		return scalar pse_DM3Y=mnde_M1M2-mnde_M1M2M3
		return scalar pse_DM2Y=mnde_M1-mnde_M1M2
		return scalar pse_DM1Y=r(nie)
		return scalar ate=r(ate)
		
	}

	if (`num_mvars' == 4) {
	
		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' `mvar4' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
	
		qui scalar mnde_M1M2M3M4=r(nde)

		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
		
		qui scalar mnde_M1M2M3=r(nde)
		
		mpathwimp `yvar' `mvar1' `mvar2' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
		
		qui scalar mnde_M1M2=r(nde)
		
		mpathwimp `yvar' `mvar1' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
		
		qui scalar mnde_M1=r(nde)
		
		return scalar pse_DY=mnde_M1M2M3M4
		return scalar pse_DM4Y=mnde_M1M2M3-mnde_M1M2M3M4
		return scalar pse_DM3Y=mnde_M1M2-mnde_M1M2M3
		return scalar pse_DM2Y=mnde_M1-mnde_M1M2
		return scalar pse_DM1Y=r(nie)
		return scalar ate=r(ate)
		
	}
	
	if (`num_mvars' == 5) {

		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' `mvar4' `mvar5' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
	
		qui scalar mnde_M1M2M3M4M5=r(nde)

		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' `mvar4' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
	
		qui scalar mnde_M1M2M3M4=r(nde)

		mpathwimp `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
		
		qui scalar mnde_M1M2M3=r(nde)
		
		mpathwimp `yvar' `mvar1' `mvar2' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor')
		
		qui scalar mnde_M1M2=r(nde)
		
		mpathwimp `yvar' `mvar1' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') censor(`censor') `detail'
		
		qui scalar mnde_M1=r(nde)
		
		return scalar pse_DY=mnde_M1M2M3M4M5
		return scalar pse_DM5Y=mnde_M1M2M3M4-mnde_M1M2M3M4M5
		return scalar pse_DM4Y=mnde_M1M2M3-mnde_M1M2M3M4
		return scalar pse_DM3Y=mnde_M1M2-mnde_M1M2M3
		return scalar pse_DM2Y=mnde_M1-mnde_M1M2
		return scalar pse_DM1Y=r(nie)
		return scalar ate=r(ate)
		
	}

end pathwimpbs
