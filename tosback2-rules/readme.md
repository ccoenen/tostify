# Tosback2-Style Configs

This directory takes tosback2's rule files.

* [Tosback rule contribution guide](https://www.eff.org/deeplinks/2013/01/campus-party-hackathon-making-rule-contribution-tosback) Handy guide by the EFF on how to create rules
* [Tosback2 rules](https://github.com/tosdr/tosback2/tree/master/rules) Lots of available rules

They generally have this form, and may contain one or more `docname`-elements:

    <sitename name="Human Readable Site Name">
     <docname name="What part of TOS">
       <url name="http://www.example.com/help/tos" xpath="//td[@class='center-col']">
         <norecurse name="arbitrary"/>
       </url>
     </docname>
    </sitename>
