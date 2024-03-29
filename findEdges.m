<html>
  <head>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="initial-scale=1,maximum-scale=1,user-scalable=no"
    />
    <!--
  ArcGIS API for JavaScript, https://js.arcgis.com
  For more information about the widgets-directions sample, read the original sample description at developers.arcgis.com.
  https://developers.arcgis.com/javascript/latest/sample-code/widgets-directions/index.html
  -->
<title>Directions widget - 4.12</title>

    <style>
      html,
      body,
      #viewDiv {
        padding: 0;
        margin: 0;
        height: 100%;
        width: 100%;
      }
    </style>

    <link
      rel="stylesheet"
      href="https://js.arcgis.com/4.12/esri/themes/light/main.css"
    />
    <script src="https://js.arcgis.com/4.12/"></script>

    <script>
      require([
        "esri/Map",
        "esri/views/MapView",
        "esri/widgets/Directions"
      ], function(Map, MapView, Directions) {
        var map = new Map({
          basemap: "topo-vector"
        });

        var view = new MapView({
          scale: 123456789,
          container: "viewDiv",
          map: map
        });

        var directionsWidget = new Directions({
          view: view,
          // Point the URL to a valid route service that uses an
          // ArcGIS Online hosted service proxy instead of the default service
          routeServiceUrl:
            "https://utility.arcgis.com/usrsvcs/appservices/srsKxBIxJZB0pTZ0/rest/services/World/Route/NAServer/Route_World"
        });

        // Add the Directions widget to the top right corner of the view
        view.ui.add(directionsWidget, {
          position: "top-right"
        });
      });
    </script>
  </head>

  <body>
    <div id="viewDiv"></div>
  </body>
</html>
