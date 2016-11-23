# $ ->
#   'use strict'
#   salesChartCanvas = $('#salesChart').get(0).getContext('2d')
#   salesChart = new Chart(salesChartCanvas)
#   salesChartData =
#     labels: [
#       '周一'
#       '周二'
#       '周三'
#       '周四'
#       '周五'
#       '周六'
#       '周日'
#     ]
#     datasets: [
#       {
#         label: 'Electronics'
#         fillColor: 'rgb(210, 214, 222)'
#         strokeColor: 'rgb(210, 214, 222)'
#         pointColor: 'rgb(210, 214, 222)'
#         pointStrokeColor: '#c1c7d1'
#         pointHighlightFill: '#fff'
#         pointHighlightStroke: 'rgb(220,220,220)'
#         data: [
#           65
#           59
#           80
#           81
#           56
#           55
#           40
#         ]
#       }
#       {
#         label: 'Digital Goods'
#         fillColor: 'rgba(60,141,188,0.9)'
#         strokeColor: 'rgba(60,141,188,0.8)'
#         pointColor: '#3b8bba'
#         pointStrokeColor: 'rgba(60,141,188,1)'
#         pointHighlightFill: '#fff'
#         pointHighlightStroke: 'rgba(60,141,188,1)'
#         data: [
#           28
#           48
#           40
#           19
#           86
#           27
#           90
#         ]
#       }
#     ]
#
#   salesChart.Line salesChartData