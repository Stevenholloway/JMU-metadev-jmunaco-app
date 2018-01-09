xquery version "3.0";

(: replace @ind2" " with @ind2"", since spaceing in blank indicators throw validation errors :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

for $ind2 in collection("/db/apps/jmunaco/data")//marc:datafield

return
    
update replace $ind2[@ind2=' ']/@ind2 with attribute code {''}

