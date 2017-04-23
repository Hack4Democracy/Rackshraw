clear
import excel using "population by county MA", firstrow
save "county pop data MA.dta", replace // American Fact Finder DP05 5-year estimates 2011-2015
clear
cd C:\Users\erackstr\Downloads
import excel using "All Group A Arrests MA", firstrow // Group A arrests from https://masscrime.chs.state.ma.us/public/View/dispview.aspx by offense type, county, race
save "arrest data MA.dta", replace 
merge m:1 JurisdictionbyCounty using "county pop data MA" //bring in pop data

*fix string vars
rename NumberofArrestees arrests
encode JurisdictionbyCounty, generate(county)
drop JurisdictionbyCounty
encode OffenseType, generate(offense)
drop OffenseType
encode ArresteeRace, generate(race)
drop ArresteeRace

gen totalwhitearrests=arrests if race==2 & offense==62
gen totalblackarrests=arrests if race==1 & offense==62
gen pctblack=Black*100/Total

*gen population-adjusted arrest rate
gen arrestshare=(arrests*100000)/White if race==2
replace arrestshare=(arrests*100000)/Black if race==1
la var arrestshare "arrests per 100,000 in population"
replace arrestshare=0 if arrestshare==.
gen totalarrestshare=(totalwhitearrests*100000)/White if race==2
replace totalarrestshare=(totalblackarrests*100000)/Black if race==1

collapse (mean) arrestshare pctblack, by(county offense race)
export excel "county arrest shares by race by offense", sheet("Raw") sheetmodify firstrow(var) // move to excel to generate ratio of black arrest likelihood to white arrest likelihood for each county/offense pair
clear

import excel "county arrest shares by race by offense", sheet("Formatted") firstrow
rename RatioBlackWhiteArrestPopula RatioBWArrests
encode Offense, gen(offense)
drop Offense
encode County, gen(county)
drop County

bys county: egen total=sum(RatioBWArrests)
bys offense: egen averageratio=mean(RatioBWArrests)
bys offense: egen highest=max(RatioBWArrests)
bys offense: egen lowest=min(RatioBWArrests)
bys offense: gen range=highest-lowest
