xquery version "3.0";

(: replace @ind1" " with @ind1"", since spaceing in blank indicators throw validation errors :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

for $ind1 in collection("/db/apps/jmunaco/data")//marc:datafield

return
    
update replace $ind1[@ind1=' ']/@ind1 with attribute code {''}

