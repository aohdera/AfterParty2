<%@ page import="afterparty.Sample" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main.gsp.bak"/>
    <g:set var="entityName" value="${message(code: 'sample.label', default: 'Sample')}"/>
    <title><g:message code="default.list.label" args="[entityName]"/></title>
</head>

<body>
<div class="nav">
    <span class="menuButton"><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a>
    </span>
    <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label"
                                                                               args="[entityName]"/></g:link></span>
</div>

<div class="body">
    <h1><g:message code="default.list.label" args="[entityName]"/></h1>
    <g:if test="${flash.message}">
        <div class="message">${flash.message}</div>
    </g:if>
    <div class="list">
        <table>
            <thead>
            <tr>

                <g:sortableColumn property="id" title="${message(code: 'sample.id.label', default: 'Id')}"/>

                <g:sortableColumn property="name" title="${message(code: 'sample.name.label', default: 'Name')}"/>

                <g:sortableColumn property="description"
                                  title="${message(code: 'sample.description.label', default: 'Description')}"/>

                <th><g:message code="sample.study.label" default="Study"/></th>

            </tr>
            </thead>
            <tbody>
            <g:each in="${sampleInstanceList}" status="i" var="sampleInstance">
                <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">

                    <td><g:link action="show"
                                id="${sampleInstance.id}">${fieldValue(bean: sampleInstance, field: "id")}</g:link></td>

                    <td>${fieldValue(bean: sampleInstance, field: "name")}</td>

                    <td>${fieldValue(bean: sampleInstance, field: "description")}</td>

                    <td>${fieldValue(bean: sampleInstance, field: "study")}</td>

                </tr>
            </g:each>
            </tbody>
        </table>
    </div>

    <div class="paginateButtons">
        <g:paginate total="${sampleInstanceTotal}"/>
    </div>
</div>
</body>
</html>
