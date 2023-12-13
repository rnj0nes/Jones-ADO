program define sim1

* sim1
* generate one or two new variables with specificed correlation

* Contact:
*  Rich Jones
*  jones@hrca.harvard.edu
*


version 8

program drop sim1



syntax , r(string) [var1(string) obs(string) sample(string) ///
                    savex(string) savey(string) rank howell ]

if "`var1'"~="" & "`savex'"~="" {
  di in red "error, cannot specify both var1 and savex"
}

if "`obs'"=="" {
  local obs = 1000
}
tempvar id
qui gen `id' = _n
qui su `id'
if r(N)==0 {
   qui set obs `obs'
   qui replace `id' = _n
}


tempvar y

if "`var1'"=="" {
   tempvar x
   qui gen `x' = invnorm(uniform())
	local sdx = 1
}
if "`var1'"~="" {
   local x = "`var1'"
	su `x'
	local sdx = `r(sd)'
}




if lower("`howell'")=="howell" {
   qui gen `y' = ((`r'/`sdx')*(1-`r'^2)^-.5)*`x'+invnorm(uniform())
}
else {
qui gen `y' = (`r'/`sdx')*`x'+sqrt((1-`r'^2))*invnorm(uniform())
}



qui su `x'
qui replace `y' = (`y'-r(mean))/r(sd)

if "`rank'"=="rank" {
   blom `y' , replace
}


if "`sample'" ~= "" {
   qui sample `sample'
}



* SAVE OUTPUT VARIBLES
* y varialble
if "`savey'"~="" {
   gen `savey' = `y' 
   di in green "variable `savey' created"
   local ycreated = "`savey'"
}
else if "`var1'"~="" {
   gen `var1'_y = `y' 
   di in green "variable `var1'_y created"
   local ycreated = "`var1'_y"
}
else {
   gen y = `y' 
   di in green "variable y created"
   local ycreated = "y"
}


* x varialbe
if "`var1'"~="" {
   exit
   }
else {
   if "`savex'"~="" {
      capture confirm variable `savex'
      if _rc==111 {
         gen `savex' = `x' 
         di in green "variable `savex' created"
         exit
      }
      else {
         di in red "`savex' already defined"
         di in green "variable `ycreated' removed"
         drop `ycreated'
      }
   }
   capture confirm variable x
   if _rc==111 {
      gen x = `x'
      di in green "variable x created"
   }
   else {
      di in red "x already defined"
      di in green "variable `ycreated' removed"
      drop `ycreated'
   }
}


end


program define blom
version 8
capture program drop blom
* generate new x that is x_blom, a blom-transformed version of x
syntax varlist [if]  , [replace]
marksample touse
capture drop `1'_blom
egen `1'_blom = rank(`1') if `touse'
qui summarize `1' if `touse'
qui replace `1'_blom  = invnorm((`1'_blom - 3/8)/(r(N)+.25))
if "`replace'"=="replace" {
   drop `1'
   rename `1'_blom `1'
}
end


pro def standardize
capture program drop standardize
syntax varlist [if] [in] [, replace]
marksample touse , novarlist
tokenize `varlist'
while "`1'"~="" {
   if "`replace'"~="replace" {
      capture drop z`1'
   }
   qui summarize `1' if `touse'
   if "`replace'"=="replace" {
      local cmd="replace"
   }
   else {
      local cmd="gen"
      local stub="z"
   }
   qui `cmd' `stub'`1' = (`1'-r(mean))/r(sd)
   local mean=round(`r(mean)',.001)
   local sd=round(`r(sd)',.001)
   if "`replace'"=="replace" {
      * label commands for replace
   }
   else {
      label variable `stub'`1' "`1' standardized with mean `mean' and sd `sd'"
   }
   qui su `stub'`1' 
   local valid=r(N)
   tempvar v1
   qui gen `v1' = 1
   qui su `v1'
   local sam = r(N)
   local ifin = "`if'"+"`in'"
   if "`ifin'"~="" {
      local text1 = ", the mean and sd of the group defined by `ifin'"
   }   
   di in gr "`stub'`1' generated as `1' standardized with " _c
   di in gr %5.3f "mean(sd)" `mean' "(" `sd' ")"  _c
   display ", with " `sam'-`valid' " missing values" _c
   display "`text1'"
   mac shift 1
}
end

