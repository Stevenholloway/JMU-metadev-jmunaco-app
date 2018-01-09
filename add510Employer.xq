xquery version "3.0";

(: inserts 510 'employer' element following the unique 988 in record :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

let $employer := collection("/db/apps/jmunaco/data")//marc:datafield[@tag="988"]
return 
  update insert <marc:datafield tag="510" ind1="2" ind2=""><marc:subfield code="i">Employer:</marc:subfield><marc:subfield code="a">James Madison University</marc:subfield><marc:subfield code="w">r</marc:subfield></marc:datafield> following $employer