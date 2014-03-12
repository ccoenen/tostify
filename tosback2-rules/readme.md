This directory takes tosback2's rules files. Those can be found here:
https://github.com/tosdr/tosback2/tree/master/rules



They generally have this form, and may contain more attributes:

    <sitename name="Human Readable Site Name">
     <docname name="What part of TOS">
       <url name="http://www.example.com/help/tos" xpath="//td[@class='center-col']">
         <norecurse name="arbitrary"/>
       </url>
     </docname>
    </sitename>
