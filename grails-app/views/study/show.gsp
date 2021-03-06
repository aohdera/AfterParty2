    <%@ page import="afterparty.Study" %>
<html>
<head>
    <meta name="layout" content="main.gsp"/>
    <title>Study | ${studyInstance.name}</title>

    %{--set up edit in place. We will grab all elements with class edit_in_place and run the edit in place method on them.
To make a bit of text editable we need to
1. add the edit_in_place tag to it
2. set the name attribute to be the name of the property that the text refers to --}%
    <script type="text/javascript">

        //         set up edit-in-place
        $(document).ready(function() {


            <g:if test="${isOwner}">
            setUpEditInPlace(
                    ${studyInstance.id},
                    "<g:createLink controller="update" action="updateField"/>",
                    'Study'
            );

            </g:if>

            $(':checkbox').change(function() {
                updateButton();
            });

            $('#showContigSetsButton').hide();

            updateButton()


        });

        function showOnly(myClass) {
            $('.compoundSampleRow:not(' + myClass + ')').hide();
            $(myClass).show();
            $('tr:odd').css('background-color', '#F0F0F0');
            return false;
        }

        function updateButton() {
            if ($("input:checked").length == 0) {
                $('.doSomethingButton').slideUp('slow');
                $("#searchForm").slideUp('slow');
                $('#blastForm').slideUp('slow');
                $('#noneSelectedMessage').slideDown('slow');

            }
            if ($("input:checked").length == 1) {
                $('#noneSelectedMessage').slideUp('slow');
                $('.doSomethingButton').slideDown('slow');

                $('#showContigSetsButton').html('<i class="icon-eye-open"></i>&nbsp;view contigs');
            }
            if ($("input:checked").length > 1) {
                $('#noneSelectedMessage').slideUp('slow');
                $('.doSomethingButton').slideDown('slow');

                $('#showContigSetsButton').html('<i class="icon-eye-open"></i>&nbsp;compare contig sets');
            }
        }

        function showSearchBox() {
            $('#blastForm').slideUp('slow');
            $('#searchForm').slideDown('slow');
            return false;
        }
        function showBLASTBox() {
            $("#searchForm").slideUp('slow');
            $('#blastForm').slideDown('slow');
            return false;
        } 


    </script>

</head>

<body>
<div class="row-fluid">
    <div class="span10 offset1 in_a_box study_details_box">
        
        <h3 class="edit_in_place" name="name">
            <g:if test="${isOwner}">
                <i class="icon-pencil"></i>&nbsp;
            </g:if>
            ${studyInstance.name}
        </h3>

        <p class="edit_in_place" name="description">
            <g:if test="${isOwner}">
                <i class="icon-pencil"></i>&nbsp;
            </g:if>
            ${studyInstance.description}
        </p>
        
        <g:if test="${isOwner && !studyInstance.published}">
           
                <g:form action="makePublished" method="get">
                    <g:hiddenField name="id" value="${studyInstance.id}"/>
                    <g:hiddenField name="setting" value="true"/>
                    <button type="submit" class="btn btn-info"><i class="icon-eye-open"></i>&nbsp;publish study</button>
                </g:form>
        </g:if>
        <g:if test="${isOwner && studyInstance.published}">
           
                <g:form action="makePublished" method="get">
                    <g:hiddenField name="id" value="${studyInstance.id}"/>
                    <g:hiddenField name="setting" value="false"/>
                    <button type="submit" class="btn btn-info"><i class="icon-eye-close"></i>&nbsp;unpublish study</button>
                </g:form>
        </g:if>
        <g:if test="${isOwner && !studyInstance.downloadable}">
           
                <g:form action="makeDownloadable" method="get">
                    <g:hiddenField name="id" value="${studyInstance.id}"/>
                    <g:hiddenField name="setting" value="true"/>
                    <button type="submit" class="btn btn-info"><i class="icon-hdd"></i>&nbsp;allow downloads</button>
                </g:form>
        </g:if>
        <g:if test="${isOwner && studyInstance.downloadable}">
           
                <g:form action="makeDownloadable" method="get">
                    <g:hiddenField name="id" value="${studyInstance.id}"/>
                    <g:hiddenField name="setting" value="false"/>
                    <button type="submit" class="btn btn-info"><i class="icon-lock"></i>&nbsp;disallow downloads</button>
                </g:form>
        </g:if>
    </div>
</div>
<div class="row-fluid">
    <div class="span10 offset1 in_a_box compound_samples_box">
            
        <g:if test="${isOwner}">
            <p>
                <g:link class="btn btn-info" controller="study" action="createCompoundSample" params="${[id : studyInstance.id]}">
                    <i class="icon-plus-sign"></i>&nbsp; Add new compound sample
                </g:link>
            </p>
        </g:if>

       <g:if test="${studyInstance.compoundSamples}">

            <table id="compound-sample-table" class="table table-bordered">
                <thead>
                <tr>
                    <th>Compound Sample name</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${studyInstance.compoundSamples.sort({it.name}) }" var="s">
                    <tr>
                        <td><g:link controller="compoundSample" action="show" id="${s.id}"><i class="icon-leaf"></i>&nbsp;${s.name}</g:link></td>
                    </tr>
                </g:each>
                </tbody>
            </table>

            <script type="text/javascript">
                $(document).ready(function() {
                   $('#compound-sample-table').dataTable({
                        "aaSorting": [[ 3, "desc" ]],
                        "asStripeClasses": [],
                        "sPaginationType": "bootstrap",
                        "apple" : "banana",
                        "fnInitComplete": function () {  $('.dataTables_filter input').attr("placeholder", "enter seach terms here");  }   
                   });
                });
            </script>

        </g:if>

        <g:else>
            <h3>Click "ADD NEW" to add a compound sample for this study.</h3>
        </g:else>
    </div>
</div>
<div class="row-fluid">
    <div class="span10 offset1 contigsets_box in_a_box">

        <g:if test="${isOwner}">
                    <g:form action="uploadContigSet" method="post" enctype="multipart/form-data">

                        <label>Create a contig set from a file of contig names</label>
                        <input type="file" name="myFile"/>
                        <span class="help-block">one contig name per line</span>
                    
                        <g:hiddenField name="id" value="${studyInstance?.id}"/>

                        <button type="submit" class="btn btn-info"/><i class="icon-time"></i>&nbsp;Upload and create contig set</button>
                    </g:form>
        </g:if>

        <form id="contigSetForm" method="get"  class="form-search">

            <table id="contig-list-table" class="table table-bordered table-hover">
                <thead>
                <tr>
                    <th>Contig Set name</th>
                    <th>Number of Contigs</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${studyInstance.contigSets.sort({it.name})}" var="contigSet" status="index">
                    <tr class='compoundSampleRow ${contigSet.type}'>
                        <td>
                            <g:checkBox name="check_${contigSet.id}" value="${false}" class="checkbox"/> 
                            <g:link controller="contigSet" action="compareContigSets" params="${[('check_' + contigSet.id)  : 'on']}"> <i class="icon-tags"></i>&nbsp;${contigSet.name}</g:link>
                            <g:if test="${contigSet.type.toString() == 'STUDY'}">
                                <span class="label">study</span>
                            </g:if>

                            <g:if test="${contigSet.type.toString() == 'ASSEMBLY'}">
                                <span class="label label-success">assembly</span>
                            </g:if>

                            <g:if test="${contigSet.type.toString() == 'COMPOUND_SAMPLE'}">
                                <span class="label label-important">compound sample</span>
                            </g:if>

                            <g:if test="${contigSet.type.toString() == 'USER'}">
                                <span class="label label-info">user</span>
                            </g:if>
                        </td>
                        <td>${contigSet.numberOfContigs()}</td>
                    </tr>
                </g:each>
                </tbody>

            </table>

            <script type="text/javascript">
                $(document).ready(function() {
                   $('#contig-list-table').dataTable({
                        "aaSorting": [[ 1, "desc" ]],
                        "asStripeClasses": [],
                        "sPaginationType": "bootstrap"    
                   });
                });
            </script>
            <hr/>
                <p id="noneSelectedMessage">Select some contig sets to view/compare/search them</p>
                <div class="btn-group">
                    <button class="doSomethingButton btn btn-info" id="showContigSetsButton" style="display:none" type="submit" onclick="submitCompare();">
                        <i class="icon-eye-open"></i>&nbsp;view contigs
                    </button>
                    <button class="doSomethingButton btn btn-info" id="searchContigSetAnnotationButton" style="display:none" onclick="showSearchBox(); return false;" type="submit">
                        <i class="icon-search"></i>&nbsp;search contigs
                    </button>
                    <button class="doSomethingButton btn btn-info" id="blastContigSetAnnotationButton" style="display:none" onclick="showBLASTBox(); return false;" type="submit">
                        <i class="icon-zoom-in"></i>&nbsp;blast contigs
                    </button>
                </div>
                <br/><br/>
                
                <div id="searchForm" style="display:none">

                    <div class="input-append">
                        <input name="searchQuery" id="searchQuery" type="text" placeholder="Enter search query..." class="search-query input-xlarge">
                        <button id="submitSearchButton" type="submit" class="btn" onclick="submitSearchForm();">
                            <i class="icon-search"></i>&nbsp;Search
                        </button>    
                    </div>
                    <span class="help-block">Hint: use <b>&amp;</b> for AND,  <b>|</b> for OR, <b>(</b> and <b>)</b> to group.</span>

                    <label>Results to show:</label>
                    <select name="numberOfResults">
                        <option value="10">10</option>
                        <option value="100">100</option>
                        <option value="1000">1000</option>
                        <option value="10000">10000</option>
                    </select>
                    <br/>
                    
                </div>

                <div id="blastForm" style="display:none">
                <label>BLAST query sequence:</label> <br/>
                <textarea name="blastQuery" id="blastQuery" rows="10" class="span8" placeholder="Paste DNA sequence here..."></textarea>
                <br/><br/>
                <label>Program to use:</label>
                <select name="program">
                <option value="blastn">blastn</option>
                <option value="tblastn">tblastn</option>
                <option value="tblastx">tblastx</option>
                </select>
                <br/><br/>
                <label>Expect</label>
                <input name="expect" placeholder="1e-20"></input>
                <br/><br/>
                <button id="submitBLASTButton" type="submit" class="btn btn-info" onclick="submitBLASTForm();">
                        <i class="icon-zoom-in"></i>&nbsp;BLAST
                    </button>
                </div>
            

        </form>


    </div>        
</div>        
    



            


</body>
</html>
