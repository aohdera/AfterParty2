<!DOCTYPE html>

<html lang="en">

<head>

    <meta http-equiv="X-UA-Compatible" content="IE=7"/>

    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

    <title><g:layoutTitle default="Grails"/></title>



    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'bootstrap.js')}"></script>

    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.dataTables.js')}"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.dataTables.bootstrap.js')}"></script>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'jquery.dataTables.css')}"/>

    
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'bootstrap.css')}"/>
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'bootstrapSwitch.css')}"/>


    %{--jquery edit in place plugin--}%
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.editinplace.js')}"></script>

   

    %{--load mask for long running stuff--}%
    <script type="text/javascript" src="${resource(dir: 'js', file: 'jquery.loadmask.min.js')}"></script>
    <link rel="stylesheet" href="${resource(dir: 'js', file: 'jquery.loadmask.css')}"/>


    %{--application-specific scripts--}%
    <g:javascript library="application"/>

    <g:layoutHead/>
        <ga:trackPageview />

</head>


<body>

    <div class="navbar navbar-static-top navbar-inverse">
        <div class="navbar-inner">
            <a class="brand" href="/">AfterParty</a>
            <ul class="nav">

                <li><a href="/"><i class="icon-home icon-white"></i>&nbsp;Home</a></li>
                
                <li class="pull-right">
                    <sec:ifLoggedIn>
                    <g:link controller="logout" action="index"><i class="icon-user icon-white"></i>&nbsp;Logout</g:link>
                    </sec:ifLoggedIn>

                    <sec:ifNotLoggedIn>
                    <g:link controller="login" action="auth"><i class="icon-user icon-white"></i>&nbsp;Click here to log in</g:link>
                    </sec:ifNotLoggedIn>
                </li>
                <sec:ifLoggedIn>
                    <g:include controller="nav" action="showStudies"/>
                </sec:ifLoggedIn>

                <g:if test="${session.studyId}">
                    <g:include controller="nav" action="show"/>
                </g:if>

            </ul>
        </div>
    </div>







<g:if test="${flash.success}">
    <div class="alert alert-success">
    <button type="button" class="close" data-dismiss="alert">x</button>
    ${flash.success}
    </div>
</g:if>

<g:if test="${flash.error}">
    <div class="alert alert-error">
    <button type="button" class="close" data-dismiss="alert">x</button>
    ${flash.error}
    </div>
</g:if>

<p id="log"></p>

<g:layoutBody/>

<!-- <pre><g:profilerOutput/></pre>
 -->
</body>
</html>
