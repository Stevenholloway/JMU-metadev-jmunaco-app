xquery version "3.0";

(: 988 $a authentication no longer requires "@jmu.edu":)
(: script can edit either MARC collection or record files :)

import module namespace config="http://xdb.lib.jmu.edu:8080/exist/jmunaco/config" at "./modules/config.xqm";

declare namespace marc="http://www.loc.gov/MARC21/slim";



declare function local:get-authority-record-data($doc) {
    let $record := $doc/marc:record
    
    return
        <authorityRecord authenticated="true">
            <EID>{string($record/marc:datafield[@tag="988"]/marc:subfield[@code="a"])}</EID>
            <groupPassword>{string($record/marc:datafield[@tag="988"]/marc:subfield[@code="b"])}</groupPassword>
            <ORCID>{string($record/marc:datafield[@tag="024"]/marc:subfield[@code="a"][../marc:subfield[@code="2" and text()="orcid"]])}</ORCID>
            <preferredName>{string($record/marc:datafield[@tag="100"]/marc:subfield[@code="a"])}</preferredName>
            <!-- fullName suppressed in favor of variantName -->
        <!--    <fullName>{string($record/marc:datafield[@tag="400"]/marc:subfield[@code="a"])}</fullName> -->
            <birthDate>{string($record/marc:datafield[@tag="046"]/marc:subfield[@code="f"])}</birthDate>
            <city>{string($record/marc:datafield[@tag="370"]/marc:subfield[@code="e"])}</city>
        <!--    <gender>{string($record/marc:datafield[@tag="375"]/marc:subfield[@code="a"])}</gender> -->
        <!-- added variant names for 400 -->                
       <variantNames>
                {if (exists($record/marc:datafield[@tag="400"]/marc:subfield[@code="a" and text() != ""]))
                 then for $variantName in $record/marc:datafield[@tag="400"]
                    return
                        for $variantName-entry in $variantName/marc:subfield[@code="a"]
                            return
                            <variantName>
                                <name>{string($variantName-entry)}</name>
                                <category>{string($variantName/marc:subfield[@code="2"])}</category>
                            </variantName>
                 else
                    <variantName><name/></variantName>
                 }
            </variantNames> 
            <languages>
                {if (exists($record/marc:datafield[@tag="377"]/marc:subfield[@code="a" and text() != '']))
                 then for $language in $record/marc:datafield[@tag="377"]/marc:subfield[@code="a"]
                    return
                    <language>
                        <code>{string($language)}</code>
                    </language>
                 else 
                    <language>
                        <code>eng</code>
                    </language>
                 }
            </languages>
            <departments>
                {if (exists($record/marc:datafield[@tag="373"]/marc:subfield[@code="a" and starts-with(., 'James Madison University. ')]))
                 then for $department in $record/marc:datafield[@tag="373" and marc:subfield[@code="a" and starts-with(., 'James Madison University. ')]]
                    return
                        for $department-entry in $department/marc:subfield[@code="a"]
                            return
                            <department>
                                <name>{substring-after(string($department-entry), 'James Madison University. ')}</name>
                                <category>{string($department/marc:subfield[@code="2"])}</category>
                                <startYear>{string($department/marc:subfield[@code="s"])}</startYear>
                                <endYear>{string($department/marc:subfield[@code="t"])}</endYear>
                            </department>
                 else
                    <department>
                        <name/>
                        <startYear/>
                        <endYear/>
                    </department>
                 }
            </departments>
            <institutions>
                {if (exists($record/marc:datafield[@tag="373"]/marc:subfield[@code="a" and not(starts-with(., 'James Madison University. '))]))
                 then for $department in $record/marc:datafield[@tag="373" and marc:subfield[@code="a" and not(starts-with(., 'James Madison University. '))]]
                    return
                        for $department-entry in $department/marc:subfield[@code="a"]
                            return
                            <institution>
                                <name>{string($department-entry)}</name>
                                <category>{string($department/marc:subfield[@code="2"])}</category>
                                <startYear>{string($department/marc:subfield[@code="s"])}</startYear>
                                <endYear>{string($department/marc:subfield[@code="t"])}</endYear>
                            </institution>
                 else
                    <institution>
                        <name/>
                        <startYear/>
                        <endYear/>
                    </institution>
                 }
            </institutions>
      <!--      <academicWorks>
                {if (exists($record/marc:datafield[@tag="510"]/marc:subfield[@code="a" and text() != ""]))
                 then for $employed in $record/marc:datafield[@tag="510"]
                    return
                        for $employed-entry in $employed/marc:subfield[@code="a"]
                            return
                            <academicWork>
                                <name>{string($employed-entry)}</name>
                            </academicWork>
                 else
                    <academicWork><name/></academicWork>
                 }
            </academicWorks>  -->
            <professionalFields>
                {if (exists($record/marc:datafield[@tag="372"]/marc:subfield[@code="a" and text() != ""]))
                 then for $field in $record/marc:datafield[@tag="372"]
                    return
                        for $field-entry in $field/marc:subfield[@code="a"]
                            return
                            <professionalField>
                                <name>{string($field-entry)}</name>
                                <category>{string($field/marc:subfield[@code="2"])}</category>
                            </professionalField>
                 else
                    <professionalField><name/></professionalField>
                 }
            </professionalFields>
            <professionalFields1>
                {if (exists($record/marc:datafield[@tag="372"]/marc:subfield[@code="a" and text() != ""]))
                 then for $field1 in $record/marc:datafield[@tag="510"]
                    return
                        for $field1-entry in $field1/marc:subfield[@code="a"]
                            return
                            <professionalField1>
                                <name>{string($field1-entry)}</name>
                                <category>{string($field1/marc:subfield[@code="2"])}</category>
                            </professionalField1>
                 else
                    <professionalField1><name/></professionalField1>
                 }
            </professionalFields1>
            <occupations>
                {if (exists($record/marc:datafield[@tag="374"]/marc:subfield[@code="a" and text() != ""]))
                 then for $occupation in $record/marc:datafield[@tag="374"]
                    return
                        for $occupation-entry in $occupation/marc:subfield[@code="a"]
                            return
                            <occupation>
                                <name>{string($occupation-entry)}</name>
                                <category>{string($occupation/marc:subfield[@code="2"])}</category>
                            </occupation>
                 else
                    <occupation><name/></occupation>
                 }
            </occupations>
            <citations>
                {if (exists($record/marc:datafield[@tag="670" and not(marc:subfield[@code="a" and starts-with(., "private communication from author, ")])]))
                 then for $citation in $record/marc:datafield[@tag="670" and not(marc:subfield[@code="a" and starts-with(., "private communication from author, ")])]
                    return
                    <citation>
                        <cite>{string($citation/marc:subfield[@code="a"])}</cite>
                        <page>{string($citation/marc:subfield[@code="b"])}</page>
                    </citation>
                 else
                    <citation>
                        <cite/>
                        <page/>
                    </citation>
                 }
            </citations>
            <other>{string($record/marc:datafield[@tag="987"]/marc:subfield[@code="a"])}</other>
        </authorityRecord>
};

(: use 988 field for auth :)
declare function local:authenticate-with-xml-and-get-data($email, $password) {
    let $eid := string($email)
  (:  let $eid := substring-before($email, '@') :)
    let $doc := xmldb:document($config:data-root || '/' || xmldb:encode($eid) || '.xml')
    
    return if (exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="a" and text()=$email]) and
               exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="b" and text()=$password]))
        then (local:get-authority-record-data($doc))
        else
            <authorityRecord authenticated="false"></authorityRecord>
};

(: use LDAP for auth :)
declare function local:authenticate-with-ldap-and-get-data() {
    let $email := xmldb:get-current-user()
    let $eid := substring-before($email, '@')
    let $doc := xmldb:document($config:data-root || '/' || xmldb:encode($eid) || '.xml')
    
    return if (exists($doc//marc:datafield[@tag="988"]/marc:subfield[@code="a" and text()=$email]))
        then (local:get-authority-record-data($doc))
        else
            <authorityRecord authenticated="false"></authorityRecord>
};

declare function local:authenticate-and-get-data($email, $password) {
    if ($config:use-ldap)
        then local:authenticate-with-ldap-and-get-data()
        else local:authenticate-with-xml-and-get-data($email, $password)
};

let $data := request:get-data()/credentials
let $eid := $data/EID
let $password := $data/group-password

return if ($eid and $password)
    then (local:authenticate-and-get-data($eid, $password))
    else
        <authorityRecord authenticate="false"></authorityRecord>