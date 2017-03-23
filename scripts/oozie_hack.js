// ==UserScript==
// @name        Hue Graph Visibility
// @namespace   hueblocker
// @description hides Hue workflow graph and adds an action filter
// @include     http://*/oozie/list_oozie_workflow/*
// @version     2
// @grant       none
// @run-at      document-start
// @author      Uwe Jugel (uwe.jugel@lovoo.com)
// ==/UserScript==

(function(){
  function array(o){ return [].slice.apply(o,[0]) }
  function echo()  { return console.log.apply(  console, array(arguments)) }
  function error() { return console.error.apply(console, array(arguments)) }
  function $(x)    { return document.querySelector(x) }
  function html(h) { var p = document.createElement("div"); p.innerHTML = h; return p.firstChild }

  var tabs, graph, timer, workflowMatch, action_filter, status_filter
  var time = 1
  
  oozie_href_ex = new RegExp("/oozie/list_oozie_workflow_action/.*")
  
  function getTableRows() { return tabs.querySelectorAll("#actions > table > tbody > tr") }
  
  function removeGraph() { $("#graph").innerText="Graph removed, since workflow matches: " + workflowMatch }
 
  function filterAction(){ 
    var name_val = ("" + action_filter.value).trim()
    var name_ex = new RegExp("^.*@.*" + name_val + ".*$", "i")

    var status_val = ("" + status_filter.value).trim()
    var status_ex = new RegExp("^.*" + status_val + ".*$", "i")

    echo("filtering by name:", name_val, name_ex)
    echo("and       by status:", status_val, status_ex)

    for(var row of getTableRows()) {
      var visible = true                                                     // default: show all
      if (visible && name_val != "") {                                       // unless we enter some filter text
        visible = false                                                      // then the filter must apply!
        for(var a of row.querySelectorAll("a[href]")) {
          if( oozie_href_ex.test(a.href) && name_ex.test(a.innerText) ) {
            visible = true; break                                            // OK: we found a filter match the row may be shown
          }
        }
      }
      if (visible && status_val != "") {                                     // the row should ne visible now
        visible = false                                                      // but the next filter must also apply!  
        for(var a of row.querySelectorAll("span.label")) {
          if( status_ex.test(a.innerText) ) {
            visible = true; break                                            // OK: the next filter also matched
          }
        }
      }
      (visible)? showRow(row): hideRow(row)
    }
  }
  
  function showRow(row){
    window.requestAnimationFrame( function() {
      row.style.display = ""
    })
  }
  function hideRow(row){
    window.requestAnimationFrame( function() {
      row.style.display = "none"
    })
  }
  
  function addFilter(name){
    // find target container and old filter input
    var tab = $("a[href='#actions']")
    if (!tab) { error("cannot find target tab: actions"); return false; }

    // setup new filter input
    var elem = html('<span id="' + name + '_filter"> ' + name + ':</span>')
    var input = html('<input style="height:10px; width:60px; margin-left:3px"></input>')
    input.addEventListener("keyup", filterAction)
    elem.appendChild(input)

    // replace/add filter input
    var old = tab.querySelector("#" + name)
    if (old) { old.parentElement.remove() }
    tab.appendChild(elem)
    return input
  }  
  
  function waitForUI() {
    tabs = $("#workflow-tab-content")
    if(!tabs) {
      if (time > 120 * 1000 ) {
        echo("stopping to wait for UI")
        return
      }
      timer = setTimeout(waitForUI, time = time * 2)
      echo("waiting for tabs to appear after ",time,"ms")
      return
    }
    var title = $(".card-heading")
    if (!title) {
      error("this is not a workflow view")
      clearTimeout(timer)
      return
    }
    if (workflowMatch.test(title.innerHTML)) {
       echo("removing matched graph")
       removeGraph()
    }
    action_filter = addFilter("action")
    status_filter = addFilter("status")
    echo("graph hack finished")
  }
  
  workflowMatch = /structure_events/i 
  waitForUI()
  
})()


