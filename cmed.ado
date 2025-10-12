*! version 0.3.0  12oct2025
program cmed
    
    version 16.1
    
    nobreak {
        
        version `=_caller()' : Define_globals
        
        capture noisily break Cmed `0'
        local rc = _rc
        
        Drop_globals
        
    }
    
    exit `rc'
    
end




/*  _________________________________________________________________________
                                                                     main  */

program Cmed
    
    syntax anything(id="subcommand" equalok) [ if ] [ in ] [ pweight ] [ , * ]
    
    gettoken subcommand modelspecifications : anything , quotes
    
    Parse_subcommand `subcommand'
    
    Parse_modelspecifications `modelspecifications'
    
    // !! fixme: do we need -svymarkout-?
    
    marksample touse
    Markout `touse'
    
    Parse_options , `options'
    
    Estimate [`weight' `exp']
    
end




/*  _________________________________________________________________________
                                                                  parsing  */




    /*  _____________________________________________________________________
                                                         parse subcommand  */

program Parse_subcommand 
    
    global Cmed__subcommand : copy local 0
    
    capture syntax name(name=subcommand)
    if ( _rc ) ///
        Error_unknown_subcommand
        // NotReached
    
    local 0 , `subcommand'
    capture syntax  ///
    [ ,             ///
        LINear      ///
        SIMulate    ///
        ipw         ///
        IMPute      ///
        mr          ///
    ]
    if ( _rc ) ///
        Error_unknown_subcommand
        // NotReached
    
    global Cmed__subcommand ///
        `linear'            ///
        `simulate'          ///
        `ipw'               ///
        `impute'            ///
        `mr'
    
end


    /*  _____________________________________________________________________
                                               parse model specifications  */

program Parse_modelspecifications
    
    Split_models_and_parse_cvars `0'
    
    Parse_modelspecification "d"
    Parse_modelspecification "l"
    Parse_modelspecification "m"
    Parse_modelspecification "y"
    
end


        /*  _________________________________________________________________
                                               split model specifications  */

program Split_models_and_parse_cvars
    
    gettoken models cvars : 0 , parse("=") qed(quoted0) bind
    
    gettoken (global) Cmed__yspec models : models ///
        , parse(" (") qed(quoted1) match(open_parenthesis)
    gettoken (global) Cmed__mspec models : models ///
        , parse(" (") qed(quoted2) match(open_parenthesis)
    gettoken (global) Cmed__dspec models : models ///
        , parse(" (") qed(quoted3) match(open_parenthesis)
    gettoken (global) Cmed__spec4 models : models ///
        , parse(" (") qed(quoted4) match(open_parenthesis)
    
    if ( inlist(1,`quoted0',`quoted1',`quoted2',`quoted3',`quoted4') ) ///
        Error_syntax_diagram
        // NotReached
    
    if (ustrtrim(`"`models'"') != "") {
        
        display as err `"invalid model specification `models'"'
        Error_syntax_diagram
        // NotReached
        
    }
    
    if (`"${Cmed__spec4}"' != "") {
        
        global Cmed__lspec : copy global Cmed__dspec
        global Cmed__dspec : copy global Cmed__spec4
        global Cmed__spec4 // void
        
    }
    
    gettoken equals 0 : cvars , parse("=")
    Parse_cvars `0'
    
end


        /*  _________________________________________________________________
                                                parse baseline covariates  */

program Parse_cvars
    
    syntax [ varlist(default=none numeric) ]
    if ( _rc ) {
        
        display as err "invalid baseline covariate specification"
        exit _rc
        
    }
    
    global Cmed__cvars : copy local varlist
    
end


        /*  _________________________________________________________________
                                            parse one model specification  */

program Parse_modelspecification
    
    args letter
    
    local modelspec : copy global Cmed__`letter'spec
    
    local n_specs 0
    
    while (`"`modelspec'"' != "") {
        
        local ++n_specs
        
        gettoken model vars : modelspec , match(open_parenthesis) quotes
        if ("`open_parenthesis'" == "(") {
            
            Parse_model `letter' `n_specs' `model'
            
            local modelspec : copy local vars
            
        }
        
        gettoken 0 modelspec : modelspec , parse("(") quotes
        capture noisily syntax varlist(numeric)
        if ( _rc ) ///
            Error_invalid_specification `letter' _rc
            // NotReached
        
        global Cmed__`letter'vars`n_specs' : copy local varlist
        global Cmed__`letter'vars ${Cmed__`letter'vars} `varlist'
        
    }
    
    global Cmed__`letter'_n_specs : copy local n_specs
    global Cmed__`letter'_n_vars  : word count ${Cmed__`letter'vars}
    
    capture noisily Confirm_min_max_var `letter'
    if ( _rc ) ///
        Error_syntax_diagram
        // NotReached
    
end


        /*  _________________________________________________________________
                                         parse model / estimation command  */

program Parse_model
    
    gettoken letter  0 : 0
    gettoken n_specs 0 : 0
    
    capture noisily syntax name(name=model id="estimation command")
    if ( _rc ) ///
        Error_invalid_specification `letter' 198
        // NotReached
    
    local 0 , `model'
    capture syntax  ///
    [ ,             ///
        REGress     ///
        logit       ///
        poisson     ///
        ologit      ///
    ]
    if ( _rc ) {
        
        display as err "invalid estimation command {bf:`model'}"
        Error_invalid_specification `letter' 198
        // NotReached
        
    }
    
    global Cmed__`letter'model`n_specs' ///
        `regress'                       ///
        `logit'                         ///
        `poisson'                       ///
        `ologit'
    
end


    /*  _____________________________________________________________________
                                                              mark sample  */

program Markout
    
    args touse
    
    markout `touse'     ///
        ${Cmed__yvars}  /// 
        ${Cmed__mvars}  ///
        ${Cmed__lvars}  ///
        ${Cmed__dvars}  ///
        ${Cmed__cvars}
    
    quietly count if `touse'
    if (r(N) < 2) ///
        error 2000+r(N)
    
    global Cmed__touse `touse'
    
end


    /*  _____________________________________________________________________
                                                            parse options  */

program Parse_options
    
    syntax                      ///
     [ ,                        ///
        PATHSpecific            ///
        Mvalue(numlist max=1)   ///
        d(numlist max=1)        ///
        dstar(numlist max=1)    ///
        *                       ///
    ]
    
    if ("`mvalue'" != "") {
        
        if ("`pathspecific'" != "") {
            
            display as err ///
                "only one of options {bf:pathspecific} or {bf:mvalue()} is allowed"
            exit 198
            
        }
        
        if (${Cmed__m_n_vars} > 1) ///
            Option_not_allowed "mvalue()" "" "with multiple ${Cmed__m_id}s"
            // NotReached
        
    }
    
    if ( ("`d'"=="") | ("`dstar'"=="") ) {
        
        tempname levels
        Levelsof_dvar `levels'
        
        if ("`d'" == "") ///
            local d = `levels'[2,1]
        
        if ("`dstar'" == "") ///
            local dstar = `levels'[1,1]
        
    }
    
    global Cmed__options        ///
        dvar(${Cmed__dvars})    ///
        d(`d')                  ///
        dstar(`dstar')          ///
        cvars(${Cmed__cvars})   ///
        `pathspecific'          ///
        mvalue(`mvalue')        ///
        `options'
    
end


        /*  _________________________________________________________________
                                          levels of dichotomous treatment  */

program Levelsof_dvar
    
    args levels
    
    capture tabulate ${Cmed__dvars} if ${Cmed__touse} , matrow(`levels')
    if ( (_rc==134) | (r(r)>2) ) {
        
        display as err "${Cmed__d_id} ${Cmed__dvars} has too many levels"
        display as err _col(5) "options {bf:d()} and {bf:dstar()} required"
        exit 459
        
    }
    else if (r(r) < 2) {
        
        display as err "${Cmed__d_id} ${Cmed__dvars} has too few levels"
        exit 459
        
    }
    else if ( _rc ) {
        
        display as err "{bf:cmed} unexpected error"
        error _rc
        
    }
    
    capture confirm integer number `=`levels'[1,1]'
    if ( !_rc ) ///
        capture confirm integer number `=`levels'[2,1]'
    
    if ( _rc ) {
        
        display as err "${Cmed__d_id} ${Cmed__dvars} contains noninteger values"
        display as err _col(5) "options {bf:d()} and {bf:dstar()} required"
        
        exit 459
        
    }
    
end




/*  _________________________________________________________________________
                                                               estimation  */




program Estimate
    
    syntax [ pweight ]
    
    if ("`weight'" != "") ///
        global Cmed__pweight [`weight' `exp']
    
    preserve
    
    quietly keep if ${Cmed__touse} 
    
    // !! fixme     can we keep only the required variables?
    // !!           remember that data is possibly  -svyset-
    
    Cmed_${Cmed__subcommand} , ${Cmed__options}
    
    restore
    
end




    /*  _____________________________________________________________________
                                                              cmed linear  */

program Cmed_linear
    
    /*
        Map to
        
            linmed
            linpath
            lincd
            
            rwrlite
    */
    
    syntax [ , pathspecific mvalue(string) * ]
    
    Confirm_model "d" ("")
    Confirm_model "y" ("","regress") , default("regress")
    
    if ( ${Cmed__l_n_specs} ) {
        
        // !! fixme: is mvalue() really required?
        
        syntax , mvalue(string) [ * ]
        
        Confirm_model "l" ("")
        
    }
    
    if ("`mvalue'" != "") {
        
        Confirm_model "m" ("")
        
        local options `options' mvar(${Cmed__mvars}) m(`mvalue')
        
        if ( ${Cmed__l_n_specs} )   ///
            local cmd "rwrlite"
        else                        ///
            local cmd "lincde"
        
    }
    else {
        
        Confirm_model "m" ("","regress") , default("regress")
        
        local mvars : copy global Cmed__mvars
        
        if ("`pathspecific'" == "pathspecific") ///
            local cmd "linpath"
        else ///
            local cmd "linmed"
        
    }
    
    `cmd' ${Cmed__yvars} `mvars' ${Cmed__lvars} ${Cmed__pweight} , `options'
    
end


    /*  _____________________________________________________________________
                                                            cmed simulate  */

program Cmed_simulate
    
    /*
        Map to
        
            medsim
            ventsim
    */
    
    syntax [ , pathspecific mvalue(string) * ]
    
    Option_not_allowed "`pathspecific'" "" "with {bf:cmed simulate}"
    
    Confirm_min_max_var "m" , max(1)
    
    Confirm_model "d" ("")
    Confirm_model "m" ("","regress","logit","poisson") , default("regress")
    Confirm_model "y" ("","regress","logit","poisson") , default("regress")
    
    if ( ${Cmed__l_n_specs} ) {
        
        // !! fixme: is mvalue() really required?
        
        syntax , mvalue(string) [ * ]
        
        Confirm_model "l" ("","regress","logit","poisson") , default("regress")
        
        local options `options' m(`mvalue')
        
        forvalues i = 1/${Cmed__l_n_specs} {
            
            foreach lvar of global Cmed__lvars`i' {
                
                local lvars `lvars' `lvar'
                local lregs `lregs' ${Cmed__lmodel`i'}
                
            }
            
        }
        
        local options `options' lvars(`lvars') lregs(`lregs')
        
        local cmd "ventsim"
        
    }
    else {
        
        Option_not_allowed "`mvalue'" "mvalue()"
        
        local cmd "medsim"
        
    }
    
    local options `options'     ///
        yreg(${Cmed__ymodel1})  ///
        mvar(${Cmed__mvars})    ///
        mreg(${Cmed__mmodel1})
    
    `cmd' ${Cmed__yvars} ${Cmed__pweight} , `options'
    
end


    /*  _____________________________________________________________________
                                                                 cmed ipw  */

program Cmed_ipw
    
    /*
        Map to
        
            ipwmed
            ipwpath
            ipwcde
            ipwvent
    */
    
    syntax [ , pathspecific mvalue(string) * ]
    
    Confirm_binary "d"
    
    Confirm_model "d" ("","logit") , default("logit")
    Confirm_model "y" ("")
    
    if ("${Cmed__lmodel1}" != "") {
        
        // !! fixme: is mvalue() really required?
        
        syntax , mvalue(string) [ * ]
        
        Confirm_min_max_var "l" , max(1)
        
        Confirm_model "l" ("logit","ologit")
        Confirm_model "m" ("","regress","logit","poisson") , default("regress")
        
        local options `options'     ///
           mvar(${Cmed__mvars})     ///
           lvar(${Cmed__lvars})     ///
           mreg(${Cmed__mmodel1})   ///
           lreg(${Cmed__lmodel1})   ///
           m(`mvalue')
           
        local cmd "ipwvent"
        
    }
    else if ("`mvalue'" != "") {
        
        Confirm_binary "m"
        
        Confirm_model "l" ("")
        Confirm_model "m" ("logit")
        
        local options `options'     ///
            mvar(${Cmed__mvars})    ///
            lvars(${Cmed__lvars})   ///
            m(`mvalue')
            
        local cmd "ipwcde"
        
    }
    else {
        
        Confirm_min_max_var "l" , max(0)
        
        Confirm_model "m" ("")
        
        if ("`pathspecific'" == "pathspecific") ///
            local cmd "ipwpath"
        else                                    ///
            local cmd "ipwmed"
        
        local mvars : copy global Cmed__mvars
        
    }
    
    // !! fixme: we should allow standard pweighs in syntax
    
    if ("${Cmed__pweight}" != "") {
        
        tempvar sampwts
        Sampwts `sampwts'
        
        local options `options' sampwts(`sampwts') 
        
    }
    
    `cmd' ${Cmed__yvars} `mvars' , `options'
    
end


    /*  _____________________________________________________________________
                                                              cmed impute  */

program Cmed_impute
    
    /*
        Map to
        
            impmed
            pathimp
            impcde
            wimpmed
            pathwimp
    */
    
    syntax [ , pathspecific mvalue(string) * ]
    
    Confirm_min_max_var "l" , max(0)
    
    Confirm_model "d" ("","logit")
    Confirm_model "m" ("")
    
    if ("${Cmed__dmodel1}" == "") {
        
        if ("`mvalue'" != "") {
            
            Confirm_model "y" ("regress","logit","poisson") , default("regress")
            
            local options `options' mvar(${Cmed__mvars}) m(`mvalue')
            
            local cmd "impcde"
            
        }
        else {
            
            Confirm_model "y" ("regress","logit") , default("regress")
            
            local mvars : copy global Cmed__mvars
            
            if ("`pathspecific'" == "pathspecific") ///
                local cmd "pathimp"
            else                                    ///
                local cmd "impmed"
            
        }
        
        local pweight : copy global Cmed__pweight
        
    }
    else {
        
        Option_not_allowed "`mvalue'" "mvalue()"
        
        Confirm_binary "d"
        
        Confirm_model "y" ("","regress","logit") , default("regress")
        
        local mvars : copy global Cmed__mvars
        
        // !! fixme: we should allow standard pweighs in syntax
        
        if ("${Cmed__pweight}" != "") {
            
            tempvar sampwts
            Sampwts `sampwts'
            
            local options `options' sampwts(`sampwts') 
            
        }
        
        if ("`pathspecific'" == "pathspecific") ///
            local cmd "pathwimp"
        else                                    ///
            local cmd "wimpmed"
        
    }
    
    local options `options' yreg(${Cmed__ymodel1})
    
    `cmd' ${Cmed__yvars} `mvars' `pweight' , `options'
    
end


    /*  _____________________________________________________________________
                                                                  cmed mr  */

program Cmed_mr
    
    /*
        Map to
        
            mrmed
            mrpath
            dmlmed
            dmlpath
    */
    
    syntax [ , pathspecific mvalue(string) dml(string asis) * ]
    
    if ("${Cmed__pweight}" != "") {
        
        display "weights not allowed with {bf:cmed mr}"
        exit 101
        
    }
    
    Option_not_allowed "`mvalue'" "mvalue()" "with {bf:cmed mr}"
    
    Confirm_min_max_var "l" , max(0)
    
    Confirm_binary "d"
    
    Confirm_model "d" ("","logit") , default("logit")
    Confirm_model "y" ("","regress") , default("regress")
    
    if (`"`dml'"' != "") {
        
        Parse_dml `dml'
        
        local options `options' model(${Cmed__dml_model}) ${Cmed__dml_options}
        
        local cmd "dml"
        
    }
    else    local cmd "mr"
    
    if ("${Cmed__mmodel1}" != "") {
        
        Confirm_min_max_var "m" , max(1)
        
        Confirm_binary "m"
        
        Confirm_model "m" ("logit")
        
        local options `options' type(mr1)
        
        local cmd "`cmd'med"
        
    }
    else {
        
        Confirm_model "m" ("")
        
        if ("`pathspecific'" != "pathspecific") {
            
            local options `options' type(mr2)
            
            local cmd "`cmd'med"
            
        }
        else    local cmd "`cmd'path"
        
    }
    
    `cmd' ${Cmed__yvars} ${Cmed__mvars} , `options'
    
end


    /*  _____________________________________________________________________
                                               de-biased machine learning  */

program Parse_dml
    
    capture noisily syntax name(name=model id="model") [ , * ]
    if ( !_rc ) {
        
        if ( inlist("`model'","rforest","lasso") ) {
            
            global Cmed__dml_model   : copy local model
            global Cmed__dml_options : copy local options
            
            exit
            
        }
        
        display as err `"{it:dmlmodel} must be one of {bf:rforest} or {bf:lasso}"'
        
    }
    
    display as err "option {bf:dml()} invalid"
    exit 198
    
end




/*  _________________________________________________________________________
                                                                auxillary  */




program Sampwts
    
    syntax name [ pweight ]
    
    quietly generate double `namelist' `exp'
    
end




    /*  _____________________________________________________________________
                                                             confirmation  */

program Confirm_binary
    
    args letter
    
    foreach var of global Cmed__`letter'vars {
        
        capture assert inlist(`var',0,1) if ${Cmed__touse} , fast
        if ( _rc ) {
            
            display as err "`var' not binary 0/1"
            Error_invalid_specification `letter' 450
            // NotReached
            
        }
        
    }
    
end


program Confirm_min_max_var
    
    gettoken letter 0 : 0 , parse(" ,")
    syntax [ , MIN(numlist) MAX(numlist) ]
    
    if ("`min'" == "") ///
        local min : copy global Cmed__`letter'_minvar
    
    if ("`max'" == "") ///
        local max : copy global Cmed__`letter'_maxvar
    
    if ( inrange(${Cmed__`letter'_n_vars},`min',`max') ) ///
        exit
    
    if (${Cmed__`letter'_n_vars} < `min') {
        
        if (`min' == 1) ///
            display as err "${Cmed__`letter'_id} required"
        else ///
            capture noisily error 102
        
        local rc 102
        
    }
    
    if (${Cmed__`letter'_n_vars} > `max') {
        
        if (`max' == 0) ///
            display as err "${Cmed__`letter'_id}s not allowed"
        else ///
            capture noisily error 103
        
        local rc 103
        
    }
    
    Error_invalid_specification `letter' `rc'
    // NotReached
    
end


program Confirm_model
    
    gettoken letter 0 : 0
    
    syntax anything(id=models) [ , default(string) ]
    
    gettoken models : anything , match(open_parenthesis)
    
    forvalues i = 1/${Cmed__`letter'_n_specs} {
        
        if ("${Cmed__`letter'model`i'}" == "") ///
            global Cmed__`letter'model`i' "`default'"
        
        if ( !inlist("${Cmed__`letter'model`i'}",`models') ) ///
            Error_model_must_be `letter' `models'
            // NotReached
        
    }
    
end


program Option_not_allowed
    
    args option opname message
    
    if (`"`option'"' == "") ///
        exit
    
    if (`"`opname'"' == "") ///
        args opname
    
    display as err `"option {bf:`opname'} not allowed `message'"'
    
    exit 198
    
end





    /*  _____________________________________________________________________
                                                                   errors  */

program Error_invalid_specification
    
    args letter rc
    
    display as err ///
        `"invalid ${Cmed__`letter'_id} model specification ${Cmed__`letter'spec}"'
    
    exit `rc'
    
end


program Error_model_must_be
    
    gettoken letter models : 0
    
    local models : subinstr local models "," " " , all
    local models : list clean models
    
    local n_models : word count `models'
    if (`n_models' > 0) {
        
        if (`n_models' > 2) {
            
            local _one_of " one of" // sic!
            local comma ","
            
        }
        
        forvalues i = 3/`n_models' {
            local models : subinstr local models " " "{sf:,}"
        }
        
        local models : subinstr local models " " "{sf:`comma' or }"
        local models : subinstr local models "{sf:,}" "{sf:, }" , all
        
        local message "must be`_one_of' {bf:`models'}"
        
    }
    else    local message "not allowed"
    
    display as err `"${Cmed__`letter'_id} model `message'"'
    Error_invalid_specification `letter' 198
    // NotReached
    
end


program Error_syntax_diagram
    
    display as err "invalid syntax"
    display as err
    display as err "{pstd}"
    display as err "Syntax is"
    display as err "{p_end}"
    display as err
    display as err "{phang2}"
    display as err "{bf:cmed}"
    display as err " {it:subcommand}"
    display as err " {bf:(}{it:yspec}{bf:)}"
    display as err " {bf:(}{it:mspec}{bf:)}"
    display as err " [ {bf:(}{it:lspec}{bf:)} ]"
    display as err " {bf:(}{it:dspec}{bf:)}"
    display as err " {it:...}"
    display as err "{p_end}"
    display as err 
    display as err "{pstd}"
    display as err "{it:yspec} is [{bf:(}{it:model}{bf:)}] {it:depvar}"
    display as err "{break}"
    display as err "{it:mspec} is [{bf:(}{it:model}{bf:)}] {it:mvars}"
    display as err " [ {bf:(}{it:model}{bf:)} {it:mvars ...} ]"
    display as err "{break}"
    display as err "{it:yspec} is [{bf:(}{it:model}{bf:)}] {it:lvars}"
    display as err " [ {bf:(}{it:model}{bf:)} {it:lvars ...} ]"
    display as err "{break}"
    display as err "{it:yspec} is [{bf:(}{it:model}{bf:)}] {it:dvar}"
    display as err "{p_end}" _newline
    
    exit 198
    
end


program Error_unknown_subcommand
    
    display as err `"subcommand {bf:cmed ${Cmed__subcommand}} is unrecognized"'
    exit 199
    
end




    /*  _____________________________________________________________________
                                                 global macro managaement  */

program Define_globals
    
    version 16.1
    
    local gmnames : all globals "Cmed__*"
    
    if ("`gmnames'" != "") {
        
        display as err "global macro `: word 1 of `gmnames'' already defined"
        exit 110
        
    }
    
    global Cmed__caller_version "version `=_caller()' :"
    
    global Cmed__d_id           "treatment"
    global Cmed__d_minvar       1
    global Cmed__d_maxvar       1    
    
    global Cmed__l_id           "post-treatment covariate"
    global Cmed__l_minvar       0
    global Cmed__l_maxvar       .
    
    global Cmed__m_id           "mediator"
    global Cmed__m_minvar       1
    global Cmed__m_maxvar       .
    
    global Cmed__y_id           "outcome"
    global Cmed__y_minvar       1
    global Cmed__y_maxvar       1
    
end


program Drop_globals
    
    local gmnames : all globals "Cmed__*"
    
    foreach gmname of local gmnames {
        
        global `gmname' // void
        
    }
    
end




exit