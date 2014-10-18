$(document).ready(function() {
  
  //draw the world map

  //only draw it once
  if ($('.jvectormap-container').length > 0) {
  var parent = document.getElementById('worldmap');
  parent.removeChild(parent.childNodes[0]);
  }
$(function(){
    var map;
    map = new jvm.WorldMap({
    container: $('#worldmap'),
    map: 'world_mill_en',
    zoomAnimate: true,
    regionsSelectable: true,
    regionsSelectableOne: true,
    regionStyle: {
      initial: {
    fill: '#252537',
    "fill-opacity": 1,
    stroke: '#000',
    "stroke-width": 0.7,
    "stroke-opacity": 1
      },
      selected: {
        fill: '#E6E600'
      }
    },
  series: {
    regions: [{
      values: applyingData,
      scale: ['#ffc9d3', '#37bc9b'],
      normalizeFunction: 'polynomial'
    }]
  },
  onRegionLabelShow: function(e, el, code){
    el.html(el.html());
  },
    backgroundColor: 'transparent',
      onRegionSelected: function(){
        var region = map.getSelectedRegions();
        $.get( "map/" +region+ "")
    }});
});
});