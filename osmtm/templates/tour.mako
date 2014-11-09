# -*- coding: utf-8 -*-
<%inherit file="base.mako"/>

<%block name="header">
<style>
.carousel {
  position: relative;
}
.carousel-inner {
  position: relative;
  overflow: hidden;
  width: 100%;
}
.carousel-inner > .item {
  display: none;
  position: relative;
  -webkit-transition: 0.6s ease-in-out left;
  transition: 0.6s ease-in-out left;
}
.carousel-inner > .item > img,
.carousel-inner > .item > a > img {
  display: block;
  line-height: 1;
  margin: auto;
}
.carousel-inner > .active,
.carousel-inner > .next,
.carousel-inner > .prev {
  display: block;
}
.carousel-inner > .active {
  left: 0;
}
.carousel-inner > .next,
.carousel-inner > .prev {
  position: absolute;
  top: 0;
  width: 100%;
}
.carousel-inner > .next {
  left: 100%;
}
.carousel-inner > .prev {
  left: -100%;
}
.carousel-inner > .next.left,
.carousel-inner > .prev.right {
  left: 0;
}
.carousel-inner > .active.left {
  left: -100%;
}
.carousel-inner > .active.right {
  left: 100%;
}
.carousel-control {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  width: 15%;
  opacity: .5;
  filter: alpha(opacity=50);
  font-size: 20px;
  color: #fff;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
}
.carousel-control.left {
  background-image: -webkit-linear-gradient(left, color-stop(rgba(0, 0, 0, 0.5) 0), color-stop(rgba(0, 0, 0, 0.0001) 100%));
  background-image: linear-gradient(to right, rgba(0, 0, 0, 0.5) 0, rgba(0, 0, 0, 0.0001) 100%);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#80000000', endColorstr='#00000000', GradientType=1);
}
.carousel-control.right {
  left: auto;
  right: 0;
  background-image: -webkit-linear-gradient(left, color-stop(rgba(0, 0, 0, 0.0001) 0), color-stop(rgba(0, 0, 0, 0.5) 100%));
  background-image: linear-gradient(to right, rgba(0, 0, 0, 0.0001) 0, rgba(0, 0, 0, 0.5) 100%);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#00000000', endColorstr='#80000000', GradientType=1);
}
.carousel-control:hover,
.carousel-control:focus {
  outline: none;
  color: #fff;
  text-decoration: none;
  opacity: .9;
  filter: alpha(opacity=90);
}
.carousel-control .icon-prev,
.carousel-control .icon-next,
.carousel-control .glyphicon-chevron-left,
.carousel-control .glyphicon-chevron-right {
  position: absolute;
  top: 50%;
  z-index: 5;
  display: inline-block;
}
.carousel-control .icon-prev,
.carousel-control .glyphicon-chevron-left {
  left: 50%;
}
.carousel-control .icon-next,
.carousel-control .glyphicon-chevron-right {
  right: 50%;
}
.carousel-control .icon-prev,
.carousel-control .icon-next {
  width: 20px;
  height: 20px;
  margin-top: -10px;
  margin-left: -10px;
  font-family: serif;
}
.carousel-control .icon-prev:before {
  content: '\2039';
}
.carousel-control .icon-next:before {
  content: '\203a';
}
.carousel-indicators {
  position: relative;
  top: 535px;
  bottom: 10px;
  left: 50%;
  z-index: 15;
  width: 60%;
  margin-left: -30%;
  padding-left: 0;
  list-style: none;
  text-align: center;
}
.carousel-indicators li {
  display: inline-block;
  width: 10px;
  height: 10px;
  margin: 1px;
  text-indent: -999px;
  border: 1px solid rgba(0, 0, 0, 0.6);
  border-radius: 10px;
  cursor: pointer;
  background-color: #000 \9;
  background-color: rgba(0, 0, 0, 0);
}
.carousel-indicators .active {
  margin: 0;
  width: 12px;
  height: 12px;
  background-color: #000;
}
.carousel-caption {
  left: 15%;
  right: 15%;
  bottom: 20px;
  z-index: 10;
  padding-top: 20px;
  padding-bottom: 20px;
  padding-left: 150px;
  padding-right: 150px;
  color: #000;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.6);
}
.carousel-caption .btn {
  text-shadow: none;
}
@media screen and (min-width: 768px) {
  .carousel-control .glyphicon-chevron-left,
  .carousel-control .glyphicon-chevron-right,
  .carousel-control .icon-prev,
  .carousel-control .icon-next {
    width: 30px;
    height: 30px;
    margin-top: -15px;
    margin-left: -15px;
    font-size: 30px;
  }
  .carousel-caption {
    left: 20%;
    right: 20%;
    padding-bottom: 30px;
  }
  .carousel-indicators {
    bottom: 20px;
  }
}
</style>

<script>
$(function(){
    $('#tour').carousel();
});
</script>
</%block>
<%block name="content">

<div id="tour" class="carousel slide" data-ride="carousel">
    <ol class="carousel-indicators">
     	<li data-target="#tour" data-slide-to="0" class="active"></li>
	<li data-target="#tour" data-slide-to="1"></li>
	<li data-target="#tour" data-slide-to="2"></li>
	<li data-target="#tour" data-slide-to="3"></li>
	<li data-target="#tour" data-slide-to="4"></li>
	<li data-target="#tour" data-slide-to="5"></li>
	<li data-target="#tour" data-slide-to="6"></li>
	<li data-target="#tour" data-slide-to="7"></li>
	<li data-target="#tour" data-slide-to="8"></li>
    </ol>
    <div class="carousel-inner" role="listbox">
        <div class="item active">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step1.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
	        <h4>Log into the TM</h4>
                <p>Log into the Tasking Manager through OSM by click on "login to OpenStreetMap".</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step2.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>OpenStreetMap login</h4>
                <p>Log into OpenStreetMap using your OSM username or email (1) and password(2). Click login (3).</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step3.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Authorize TM access</h4>
                <p>Authorize the Tasking Manager to access your OSM user preferences (1) and save changes (2).</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step4.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Select a project</h4>
                <p>Once logged in and back at the Tasking Manager, select the project you wish to work on. You can sort by highest priority, most recently added, and most recently updated. You can also search by name for a particular project.</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step5.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Understand the project workflow</h4>
                <p>Read what the project workflow is, or what needs to be mapped (1); areas to be mapped are visible on the right side (2). Once you understand what to do, click "Contribute" (3).</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step6.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Select a task</h4>
                <p>Either select a particular task on the map (1) or pick a random one (2).</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step7.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Start mapping</h4>
                <p>Once a grid is selected, you can see the history of work completed on that task on the center left side. Click "Start mapping" to begin.</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step8.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Map!</h4>
                <p>Click "Edit with" (1) and select the map editor you wish to use. The editor will load your task to be edited.</p>
            </div>
         </div>
         <div class="item">
            <img src="${request.static_url('osmtm:static/img/tour/tour_step9.JPG')}" alt="" width="590" height="500">
            <div class="carousel-caption">
                <h4>Free the task</h4>
                <p>Once you are finished editing, return to the Tasking Manager and leave a comment if you desire (1). If you did not complete all the items requested in the workflow, unlock the task for more editing (2). Otherwise, mark the task as done (3). You have completed your first task!</p>
            </div>
         </div>

    </div>

    <a class="left carousel-control" href="#tour" role="button" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left"></span>
    </a>
    <a class="right carousel-control" href="#tour" role="button" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right"></span>
    </a>
</div>
<p></p>
</%block>
