xquery version "3.0";

(: 988 $a authentication no longer requires "@jmu.edu":)
(: 'full-name' suppressed in favor of 'variant-name' to handle 400 :)
(: 'gender' 375 suppressed :)
(: revised beginning 2017-10-09 to meet NACO requirements: added subfield "v" with submission form phrase and date 
to 370/372/373/374; added birth year to 100$d, 400$d, 670$b submission form :)
(: Other revisions: if 024 $2 "orcid""viaf" or "isni" are present, a duplicate 024 with URI encoding is created;
subfield 2 value "naf" added to 373s; 040 added if not present; 510 JMU employer automatically generated if not present;
"Academic Employment" section added to input form; 
changed fixed entry form.html fields to expandable entry fields; added/updated several "hints" and labels; 
spacing of the "variant name" entries in the 670 fixed; justification for 510 employment added to 670; 378 will be generated if 100$q:)

(: Desireable fixes: 670: $b variant names inserted in direct format; fix the cv upload feature; stop generating new 024 URI entries every time the form is saved:)

import module namespace config="http://xdb.lib.jmu.edu:8080/exist/jmunaco/config" at "./modules/config.xqm";

declare namespace marc="http://www.loc.gov/MARC21/slim";

(: use 988 fields for auth :)
declare function local:authenticate-with-xml($email, $password) {
    let $eid := string($email)
   (: let $eid := substring-before($email, '@') :)
    let $doc := xmldb:document($config:data-root || '/' || xmldb:encode($eid) || '.xml')
    
    return if (exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="a" and text()=$email]) and
               exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="b" and text()=$password]))
        then ($doc)
        else (null)
};

(: use LDAP for auth :)
declare function local:authenticate-with-ldap() {
    let $email := xmldb:get-current-user()
    let $eid := substring-before($email, '@')
    let $doc := xmldb:document($config:data-root || '/' || xmldb:encode($eid) || '.xml')
    
    return if (exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="a" and text()=$email]))
        then ($doc)
        else (null)
};

declare function local:authenticate($email, $password) {
    if ($config:use-ldap)
        then local:authenticate-with-ldap()
        else local:authenticate-with-xml($email, $password)
};

declare function local:update($record, $input) {
    let $orcid := string($input/ORCID)
    let $isni := $record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="isni"]]/text()
    let $viaf := $record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="viaf"]]/text()
    let $preferred-name := string($input/preferredName)
    let $q-field-name := $record/marc:datafield[@tag="100"]/marc:subfield[@code="q"]/text()
(:added variant name option :)
    for $variant-names in string($input/variantNames)
(:suppressed full-name :)
  (:  let $full-name := string($input/fullName) :)
    let $birth-date := string($input/birthDate)
    let $cite-birth-year := substring($birth-date,1,4)
    let $birth-year := concat(substring($input/birthDate,1,4),'-')
    let $city := string($input/city)
    let $employment := string($input/professionalFields1)
(: suppressed gender :)
  (:  let $gender := string($input/gender) :)
    let $languages := $input/languages/language/code
    let $other := string($input/other)
(: 'variant-name' substituted for 'full-name':)
 (:   let $cite-names := if (string-length($variant-name) = 0)
        then concat('(', $cite-name, ')')
        else concat('(', $cite-name, ', ', substring-after($variant-name, ', '), ' ', substring-before($variant-name, ','), ')'):) 
    let $cite-name := replace(replace($preferred-name, '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1')
    for $cite-variant-name in replace(replace($variant-names, '( [A-Z])( |$)', '$1.$2'), '^(.*), (.*)$', '$2 $1') 
    let $cite-names := concat($cite-name, $variant-names)
    let $date := format-date(current-date(),'[Y]-[M01]-[D01]')
    
    (: big mess of edits to xml. it's possible that this could be done with a helper function or two, since most of the fields are consistent in structure. :)
    let $updates := (
        update value $record/marc:controlfield[@tag="005"] with format-dateTime(current-dateTime(),'[Y][M01][D01][H01][m][s].[f,1-1]'),
(: suppress full-name :)
    (:    if (exists($record/marc:datafield[@tag="400"]/marc:subfield[@code="a"]))
            then update value $record/marc:datafield[@tag="400"]/marc:subfield[@code="a"] with $full-name
            else update insert <marc:datafield tag="400" ind1="1" ind2=""><marc:subfield code="a">{$full-name}</marc:subfield></marc:datafield> into $record, :)
            
(:adds variant names, one or more, to 400:)
            
        if (exists($record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="orcid"]]))
            then update value $record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="orcid"]] with $orcid
            else update insert <marc:subfield code="a">{$orcid}</marc:subfield> preceding $record/marc:datafield[@tag="024"]/marc:subfield[@code="2" and text()="orcid"], 
        if (exists($record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="orcid"]]))
            then update insert <marc:datafield tag="024" ind1="7" ind2=" "><marc:subfield code="a">http://orcid.org/{$orcid}</marc:subfield><marc:subfield code="2">uri</marc:subfield></marc:datafield> into $record
            else (),
        if (exists($record/marc:datafield[@tag="024"]/marc:subfield[@code="a" and not(starts-with(.,"http://www.isni.org/isni"))][../marc:subfield[@code="2" and text()="isni"]]))
            then update insert <marc:datafield tag="024" ind1="7" ind2=" "><marc:subfield code="a">http://www.isni.org/isni/{$isni}</marc:subfield><marc:subfield code="2">uri</marc:subfield></marc:datafield> into $record
            else (),
        if (exists($record/marc:datafield[@tag="024"]/marc:subfield[@code="a" and not(starts-with(.,"http://viaf.org/viaf"))][../marc:subfield[@code="2" and text()="viaf"]]))
            then update insert <marc:datafield tag="024" ind1="7" ind2=" "><marc:subfield code="a">http://viaf.org/viaf/{$viaf}</marc:subfield><marc:subfield code="2">uri</marc:subfield></marc:datafield> into $record
            else (),
        if (exists($record/marc:datafield[@tag="040"]))
            then ()
            else update insert <marc:datafield tag="040" ind1=" " ind2=" "><marc:subfield code="a">ViHarT</marc:subfield><marc:subfield code="b">eng</marc:subfield><marc:subfield code="e">rda</marc:subfield><marc:subfield code="c">ViHarT</marc:subfield></marc:datafield> into $record,
        if (exists($record/marc:datafield[@tag="046"]/marc:subfield[@code="f"]))
            then update value $record/marc:datafield[@tag="046"]/marc:subfield[@code="f"] with $birth-date
            else if (exists($record/marc:datafield[@tag="046"]))
                then update insert <marc:subfield code="f">{$birth-date}</marc:subfield> into $record/marc:datafield[@tag="046"]
                else update insert <marc:datafield tag="046" ind1=" " ind2=" "><marc:subfield code="f">{$birth-date}</marc:subfield><marc:subfield code="2">edtf</marc:subfield></marc:datafield> into $record,
      (:  if (exists($record/marc:datafield[@tag="370"]/marc:subfield[@code="e"]))
            then update value $record/marc:datafield[@tag="370"]/marc:subfield[@code="e"] with $city
            else update insert <marc:datafield tag="370" ind1=" " ind2=" "><marc:subfield code="e">{$city}</marc:subfield><marc:subfield code="2">naf</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record, :)
        update value $record/marc:datafield[@tag="100"]/marc:subfield[@code="a"] with $preferred-name,
        if (exists($record/marc:datafield[@tag="100"]/marc:subfield[@code="d"]))
            then update value $record/marc:datafield[@tag="100"]/marc:subfield[@code="d"] with $birth-year
            else update insert <marc:subfield code="d">{$birth-year}</marc:subfield> into $record/marc:datafield[@tag="100"],
        if (exists($record/marc:datafield[@tag="100"]/marc:subfield[@code="d" and (starts-with(.,'-'))]))
            then update delete $record/marc:datafield[@tag="100"]/marc:subfield[@code="d"]
            else (),
        update delete $record/marc:datafield[@tag="370"],
        for $city in $input/city[not(empty(text()))]
            return update insert <marc:datafield tag="370" ind1=" " ind2=" "><marc:subfield code="e">{string($city)}</marc:subfield><marc:subfield code="2">naf</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,
(: gender 375 suppressed :)
        (: update value $record/marc:datafield[@tag="375"]/marc:subfield[@code="a"] with $gender, :)
        (: for multiple value fields, clear everything out before adding values back in :)
        update delete $record/marc:datafield[@tag="372"],
        for $field in $input/professionalFields/professionalField[name[not(empty(text()))]]
            return update insert <marc:datafield tag="372" ind1=" " ind2=" "><marc:subfield code="a">{string($field/name)}</marc:subfield><marc:subfield code="2">{string($field/category)}</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,
        update delete $record/marc:datafield[@tag="373"],
        for $department in $input/departments/department[name[not(empty(text()))]]
            return update insert <marc:datafield tag="373" ind1=" " ind2=" "><marc:subfield code="a">James Madison University. {string($department/name)}</marc:subfield><marc:subfield code="s">{string($department/startYear)}</marc:subfield><marc:subfield code="t">{string($department/endYear)}</marc:subfield><marc:subfield code="2">naf</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,
        for $department in $input/institutions/institution[name[not(empty(text()))]]
            return update insert <marc:datafield tag="373" ind1=" " ind2=" "><marc:subfield code="a">{string($department/name)}</marc:subfield><marc:subfield code="s">{string($department/startYear)}</marc:subfield><marc:subfield code="t">{string($department/endYear)}</marc:subfield><marc:subfield code="2">naf</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,
        update delete $record/marc:datafield[@tag="374"],
        for $occupation in $input/occupations/occupation[name[not(empty(text()))]]
            return update insert <marc:datafield tag="374" ind1=" " ind2=" "><marc:subfield code="a">{string($occupation/name)}</marc:subfield><marc:subfield code="2">{string($occupation/category)}</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,
        update delete $record/marc:datafield[@tag="377"],
        for $language in $languages
            return update insert <marc:datafield tag="377" ind1=" " ind2=" "><marc:subfield code="a">{string($language)}</marc:subfield></marc:datafield> into $record,
        if (exists($record/marc:datafield[@tag="100"]/marc:subfield[@code="q"]))
            then update insert <marc:datafield tag="378" ind1=" " ind2=" "><marc:subfield code="a">{replace($q-field-name,'[()]','')}</marc:subfield></marc:datafield> into $record
            else (),
        update delete $record/marc:datafield[@tag="400"],
        for $variant-name in $input/variantNames/variantName[name[not(empty(text()))]]
            return update insert <marc:datafield tag="400" ind1="1" ind2=" "><marc:subfield code="a">{string($variant-name/name)}</marc:subfield><marc:subfield code="d">{$birth-year}</marc:subfield><marc:subfield code="2">{string($variant-name/category)}</marc:subfield><marc:subfield code="v">JMU NACO Online Submission Form, {format-date(xs:date($date),"[MNn] [D], [Y]","en",(),())}</marc:subfield></marc:datafield> into $record,    
        if (exists($record/marc:datafield[@tag="400"]/marc:subfield[@code="d" and (starts-with(.,'-'))]))
            then update delete $record/marc:datafield[@tag="400"]/marc:subfield[@code="d"]
            else (),
        update delete $record/marc:datafield[@tag="510"],
        for $field1 in $input/professionalFields1/professionalField1[name[not(empty(text()))]]
            return update insert <marc:datafield tag="510" ind1="2" ind2=" "><marc:subfield code="i">Employer:</marc:subfield><marc:subfield code="a">{string($field1/name)}</marc:subfield><marc:subfield code="w">r</marc:subfield></marc:datafield> into $record,
        if (exists($record/marc:datafield[@tag="510"]/marc:subfield[@code="a" and starts-with(.,"James Madison University")]))
            then ()
            else update insert <marc:datafield tag="510" ind1="2" ind2=" "><marc:subfield code="i">Employer:</marc:subfield><marc:subfield code="a">James Madison University</marc:subfield><marc:subfield code="w">r</marc:subfield></marc:datafield> into $record, 
        update delete $record/marc:datafield[@tag="670"],
        for $citation in $input/citations/citation[cite[not(empty(text()))]]
            return update insert <marc:datafield tag="670" ind1=" " ind2=" "><marc:subfield code="a">{string($citation/cite)}</marc:subfield><marc:subfield code="b">{string($citation/page)}</marc:subfield></marc:datafield> into $record,
        if (exists($record/marc:datafield[@tag="046"]/marc:subfield[@code="f" and text()='']))
            then update insert <marc:datafield tag="670" ind1=" " ind2=" "><marc:subfield code="a">private communication from author, {$date}:</marc:subfield><marc:subfield code="b">JMU NACO Online Submission Form ({$cite-name, normalize-space($cite-variant-name)}, employed by {normalize-space($employment)})</marc:subfield></marc:datafield> into $record
            else update insert <marc:datafield tag="670" ind1=" " ind2=" "><marc:subfield code="a">private communication from author, {$date}:</marc:subfield><marc:subfield code="b">JMU NACO Online Submission Form ({$cite-name, normalize-space($cite-variant-name)}, employed by {normalize-space($employment)}, birth year {$cite-birth-year})</marc:subfield></marc:datafield> into $record,
 (:           then update insert <marc:datafield tag="670" ind1=" " ind2=" "><marc:subfield code="a">private communication from author, {$date}:</marc:subfield><marc:subfield code="b">JMU NACO Online Submission Form ({normalize-space($cite-names)}, employed by {normalize-space($employment)})</marc:subfield></marc:datafield> into $record
            else update insert <marc:datafield tag="670" ind1=" " ind2=" "><marc:subfield code="a">private communication from author, {$date}:</marc:subfield><marc:subfield code="b">JMU NACO Online Submission Form ({normalize-space($cite-names)}, employed by {normalize-space($employment)}, birth year {$cite-birth-year})</marc:subfield></marc:datafield> into $record,  :)
        if (exists($record/marc:datafield[@tag="987"]/marc:subfield[@code="a"]))
            then update value $record/marc:datafield[@tag="987"]/marc:subfield[@code="a"] with $other
            else update insert <marc:datafield tag="987" ind1=" " ind2=" "><marc:subfield code="a">{$other}</marc:subfield></marc:datafield> into $record
    )
    
    return
        <success>1</success>
};

let $input := request:get-data()/authorityRecord
let $eid := $input/EID
let $groupPassword := $input/groupPassword
let $record := local:authenticate($eid, $groupPassword)

return if (exists($record))
    then (local:update($record/marc:record, $input))
    else (null)