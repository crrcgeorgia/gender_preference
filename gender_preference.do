clear

use "http://caucasusbarometer.org/downloads/CB2019_Georgia_response_30Jan2020.dta" , clear

set more off


/// weights
 svyset PSU [pweight=INDWT], strata(SUBSTRATUM) fpc(NPSUSS)singleunit(certainty)  || ID, fpc(NHHPSU) || _n, fpc(NADHH)



/// blog 1 - recodes - ideal number of children

recode IDEALNCH (1=1) (2=1) (3=2) (4=3) (5=3) (6=3) (7=3) (8=3) (9=3) (10=3) (11=3)(-5=4)(-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(idealnchREC)
label var idealnchREC "Ideal number of children"

label define idealnchREC 1 "One or two", modify
label define idealnchREC 2 "Three", modify
label define idealnchREC 3 "Four or more", modify
label define idealnchREC 4 "Whatever number the God will give us", modify
label values idealnchREC idealnchREC
fre idealnchREC
svy: tab idealnchREC


/// blog 1 - recodes - If a family has one child, what would be the preferred gender of the child?

recode GNDPREF (1=1) (2=2) (3=3) (-1=.) (-2=.) (4=.) (-3=.) (-7=.) (-9=.) , gen(gndprefREC)
label var gndprefREC "what would be the preferred gender of the child?"

label define gndprefREC 1 "A girl", modify
label define gndprefREC 2 "A boy", modify
label define gndprefREC 3 "Does not matter", modify

label values gndprefREC gndprefREC
fre gndprefREC
svy: tab gndprefREC

/// blog 2 - recodes - Who should inherit the apartment: girl or boy

recode APTINHERT (1=1) (2=2) (3=3) (-1=.) (-2=.) (4=.) (-3=.) (-7=.) (-9=.) , gen(aptinhertREC)
label var aptinhertREC "Who should inherit the apartment: girl or boy"

label define aptinhertREC 1 "A daughter", modify
label define aptinhertREC 2 "A son", modify
label define aptinhertREC 3 "Should be equally distributed", modify

label values aptinhertREC aptinhertREC
svy: tab aptinhertREC

/// blog 2 - recodes - Who should take care of parents more: girl or boy

recode CAREPRNTS (1=2) (2=1) (3=3) (-1=.) (-2=.) (4=.) (-3=.) (-7=.) (-9=.) , gen(careprntsREC)
label var careprntsREC "Who should inherit the apartment: girl or boy"

label define careprntsREC 1 "A daughter should take care", modify
label define careprntsREC 2 "A son should take care", modify
label define careprntsREC 3 "Should take care equally", modify

label values careprntsREC careprntsREC
svy: tab careprntsREC

/// recodes - sett type

recode SUBSTRATUM (1=1) (6=2) (7=2) (8=2) (9=2) (2=3) (3=3) (4=3) (5=3) (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(settypeREC)
label var settypeREC "Settlement type"

label define settypeREC 1 "Capital", modify
label define settypeREC 2 "Other Urban", modify
label define settypeREC 3 "Rural", modify
label values settypeREC settypeREC
svy: tab settypeREC


/// Wealth index

foreach var of varlist  OWNCOTV OWNDIGC OWNWASH OWNFRDG OWNAIRC OWNCARS OWNLNDP OWNCELL OWNCOMP {
recode `var' (-9/-1=0)
}

gen wealth_index = OWNCOTV + OWNDIGC + OWNWASH + OWNFRDG + OWNAIRC + OWNCARS + OWNLNDP + OWNCELL + OWNCOMP


/// recodes - Ethnicity type

recode ETHNIC (3=1) (1=2) (2=2) (4=2) (5=2) (6=2) (7=2) (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(ETHNICREC)
label var ETHNICREC "Ethnicity"

label define ETHNICREC 1 "Ethnic Georgians", modify
label define ETHNICREC 2 "Ethnic Minority", modify

label values ETHNICREC ETHNICREC



/// recodes - education
recode RESPEDU (1=1) (2=1) (3=1) (4=1) (5=2) (6=3) (7=3) (8=3)  (-1=.) (-2=.) (-3=.) (-7=.) (-9=.) , gen(RESPEDUrec)
label var RESPEDUrec "Respondent's education level"

label define RESPEDUrec 1 "Secondary or lower", modify
label define RESPEDUrec 2 "Secondary technical", modify
label define RESPEDUrec 3 "Higher than secondary", modify
label define RESPEDUrec 98 "DKRA", modify
label values RESPEDUrec RESPEDUrec


/// recodes - RESPAGE groups

recode RESPAGE (18/35=1) (36/55=2) (56/130=3) (-3=.) (-7=.) (-9=.) , gen(AGEGROUP)
label var AGEGROUP "Age group of respondent"

label define AGEGROUP 1 "18-35", modify
label define AGEGROUP 2 "36-55", modify
label define AGEGROUP 3 "Older than 55", modify
label values AGEGROUP AGEGROUP


foreach var of varlist _all {
replace `var'=98 if `var'==-1
replace `var'=99 if `var'==-2
replace `var'=95 if `var'==-5
replace `var'=. if `var'==-9
replace `var'=. if `var'==-7
replace `var'=. if `var'==-3
}



//multinominal regression

/// mlogit - ideal number of children

svy: mlogit idealnchREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (4)  
margins, dydx(*) predict(outcome(1)) post
estimates store OneOrTwo

svy: mlogit idealnchREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (4)  
margins, dydx(*) predict(outcome(2)) post
estimates store Three

svy: mlogit idealnchREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (4)  
margins, dydx(*) predict(outcome(3)) post
estimates store FourOrMore

svy: mlogit idealnchREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (4)  
margins, dydx(*) predict(outcome(4)) post
estimates store WhateverNumber


coefplot OneOrTwo || Three || FourOrMore || WhateverNumber, drop(_cons) xline(0) byopts(xrescale) 

/// title("If a family has one child, what would be the preferred gender of the child?" and "Who should inherit the apartment: girl or boy" "By demographic variables and wealth index", color(dknavy*.9) tstyle(size(medium)) span)
/// subtitle("Marginal effects, 95% CIs", color(navy*.8) tstyle(size(msmall)) span)
/// note("CB 2019/CRRC-Georgia, DEC 2019")



/// mlogit - gndprefREC - if one child, gender preference

svy: mlogit gndprefREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (3)  
margins, dydx(*) predict(outcome(1)) post
estimates store Daughter

svy: mlogit gndprefREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (3)  
margins, dydx(*) predict(outcome(2)) post
estimates store Son

svy: mlogit gndprefREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec c.wealth_index , base (3)  
margins, dydx(*) predict(outcome(3)) post
estimates store DoesNotMatter


coefplot Daughter || Son || DoesNotMatter, drop(_cons) xline(0) byopts(xrescale) 
/// title("If a family has one child, what would be the preferred gender of the child?" "By demographic variables and wealth index", color(dknavy*.9) tstyle(size(medium)) span)
/// subtitle("Marginal effects, 95% CIs", color(navy*.8) tstyle(size(msmall)) span)
/// note("CB 2019/CRRC-Georgia, DEC 2019")





/*
/// mlogit

svy: mlogit aptinhertREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec b01.careprntsREC , base (3)  
margins, dydx(*) predict(outcome(1)) post
estimates store Daughter

svy: mlogit aptinhertREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec b01.careprntsREC , base (3)  
margins, dydx(*) predict(outcome(2)) post
estimates store Son

svy: mlogit aptinhertREC i.RESPSEX i.AGEGROUP b03.settypeREC b01.ETHNICREC b03.RESPEDUrec b01.careprntsREC , base (3)  
margins, dydx(*) predict(outcome(3)) post
estimates store Equally


coefplot Daughter || Son || Equally, drop(_cons) xline(0) byopts(xrescale) 

*/
