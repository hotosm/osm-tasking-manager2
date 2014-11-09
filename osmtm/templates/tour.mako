<%inherit file="/base.mako"/>
<%def name="id()">tour</%def>
<%def name="title()">Tour</%def>
<script type="text/javascript"
    src="${request.static_url('OSMTM:static/bootstrap/js/bootstrap-transition.js')}"></script>
<script type="text/javascript"
    src="${request.static_url('OSMTM:static/bootstrap/js/bootstrap-carousel.js')}"></script>
<style type="text/css">
</style>
<div class="container">
    <div class="row">
        <div class="span1"></div>
        <div class="span10">
            <div id="myCarousel" class="carousel slide">
                <div class="carousel-inner">
                    <div class="item active">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step1.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Log into the TM</h4>
                            <p>Log into the Tasking Manager through OSM by clicking on "login to OpenStreetMap".</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step2.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>OpenStreetMap login</h4>
                            <p>Log into OpenStreetMap using your OSM username or email (1) and password (2). Click login (3).</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step3.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Authorize TM access</h4>
                            <p>Authorize the Tasking Manager to access your OSM user preferences (1) and save changes (2).</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step4.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Select a project</h4>
                            <p>Once logged in and returned to the Tasking Manager, select the project you want to work on.</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step5.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Understand the project</h4>
                            <p>Read what the project is about and what needs to be mapped (1); the view of tasks is visible on the right side (2). Once you understand what to do, click "Contribute" (3).</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step6.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Select a task</h4>
                            <p>Either choose a task by selecting a section on the map (1) or picking one at random (2).</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step7.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Start mapping</h4>
                            <p>Once a grid is selected, you can see the history of work done on that grid at the bottom left. Click "Start mapping" to begin.</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step8.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Map</h4>
                            <p>Click "Edit with" (1) and select the editor you wish to use. The editor will load the grid to be edited.</p>
                        </div>
                    </div>
                    <div class="item">
                        <img src="${request.static_url('OSMTM:static/img/tour/tour_step9.jpg')}" alt="">
                        <div class="carousel-caption">
                            <h4>Free the task</h4>
                            <p>Once you are finished editing, return to the Tasking Manager and leave a comment if you desire (1). If you did not complete all the items requested, unlock the tile for others to work on it (2). Otherwise, mark the task as done (3). You're finished with editing your first task!</p>
                        </div>
                    </div>
                </div>
                <a class="left carousel-control" href="#myCarousel" data-slide="prev">‹</a>
                <a class="right carousel-control" href="#myCarousel" data-slide="next">›</a>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    $('.carousel').carousel({
        interval: 20000,
        pills: true
    });
</script>
