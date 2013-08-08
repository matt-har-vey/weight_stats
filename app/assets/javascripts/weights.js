(function($) {
  $(function() {
    Highcharts.setOptions({
        global: { useUTC: false }
    });
    
    var dateTimeLabelFormats = {
      millisecond: '%H:%M:%S.%L',
      second: '%H:%M:%S',
      minute: '%H:%M',
      hour: '%H:%M',
      day: '%b %e',
      week: '%b %e',
      month: '%b %y',
      year: '%Y'
    };

    $('.datepicker').datepicker({autoclose: true, format: 'yyyy-mm-dd', clearBtn: true});

    $('.highchart-scatterline').each(function() {
      var chartDiv = $(this);
      var title = chartDiv.data('title');
      var weights = chartDiv.data('weights');
      var eps = weights.fit.endpoints;
      var rmse = weights.fit.rmse;

      $(this).highcharts({
        title: { text: title },
        legend: { enabled: false },
        xAxis: { type: 'datetime', dateTimeLabelFormats: dateTimeLabelFormats },
        yAxis: { title: { text: null } },
        tooltip: { formatter: function() {
          var yform = Math.round(100 * this.y) / 100;
          return Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', new Date(this.x)) + '<br/>' + yform;
        } },
        plotOptions: { series: { animation: false },
                       line: { enableMouseTracking: false, lineWidth:1, marker:{enabled:false} },
                       scatter: { marker: {symbol: 'diamond', fillColor: '#96b5ce', lineColor: '#5087ba', lineWidth: 1} }},
        series: [
          { type: 'line', name: title, color: '#cccccc', data: [[eps[0][0],eps[0][1] + rmse / 4],[eps[2][0],eps[2][1] + rmse / 4]] },
          { type: 'line', name: title, color: '#cccccc', data: [[eps[0][0],eps[0][1] - rmse / 4],[eps[2][0],eps[2][1] - rmse / 4]] },
          { type: 'line', name: title, color: 'black', data: eps.slice(0,2) },
          { type: 'line', name: title, color: 'black', dashStyle: 'LongDash', data: eps.slice(1,3) },
          { type: 'scatter', name: title, data: weights.data}
        ]
      });
    });
  });
})(jQuery);
