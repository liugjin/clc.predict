###
* File: stream-test-directive
* User: David
* Date: 2020/04/13
* Desc:
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define ['../base-directive','text!./style.css', 'text!./view.html', 'underscore', "moment","echarts"], (base, css, view, _, moment,echarts) ->
  class StreamTestDirective extends base.BaseDirective
    constructor: ($timeout, $window, $compile, $routeParams, commonService)->
      @id = "stream-test"
      super $timeout, $window, $compile, $routeParams, commonService

    setScope: ->

    setCSS: ->
      css

    setTemplate: ->
      view

    show: (scope, element, attrs) =>
      rABS= false
      chartelement = element.find('#stream-chart')
      scope.mychart = echarts.init chartelement[0]
      scope.streamDataAnalysis = (obj)=>
        newArr = ''
        #        console.log XLSX
        reads = new FileReader()
        f=document.getElementById(obj.id).files[0]
        #        reads.readAsDataURL(f);
        reads.onload= (e)=>
          data = e.target.result
          if rABS
            wb = XLSX.read(btoa(fixdata(data)), {
              type: 'base64'
            })
          else
            wb = XLSX.read(data, {
              type: 'binary'
            })
          #          读取文件里的数据为json数据
          testStr = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]])
          #           testStr =  XLSX.utils.sheet_to_txt(wb.Sheets[wb.SheetNames[0]])
#          newStrs = jsonToStringData(testStr)
          newArr = jsonToStringData(testStr)
          createOption(newArr)
        if rABS
          reads.readAsArrayBuffer(f)
        else
          reads.readAsBinaryString(f)

      jsonToStringData = (obj)=>
        arr = []
        data = {
          xData: []
          yData: []
        }
        for item,index in obj
          if index < 2000
            arr.push(item)
            data.xData.push(index+1)
        console.log arr
        for item in arr
          for k,v of item
            num = Number(k)
            if !isNaN(num)
              data.yData.push(Number(v))
        return data
      createOption = (opts)=>
        opts.start = 0
        opts.end = 2
        colors = [['#1A45A2','#00E7EE'],['#90D78A','#1CAA9E'],['#F9722C','#FF085C']]
        series = []
        legends = ['测试数据']
        series.push({
          name:legends[0]
          type:'line'
          symbol: "none"
          smooth:true
          data:opts.yData
          lineStyle:
            width:2
            color: {
              type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [{
                offset: 0, color: colors[0][0]
              }, {
                offset: 1, color: colors[0][1]
              }]
            }
        })
        _legendData = _.map(legends, (d,i) => {name:d,icon:"image://" + @getComponentPath('image/color'+(i+1)+'.svg')})
        option =
          title:
            text: '流数据原始数据'
            textStyle:
              color: '#fff'
            left: 'center'
            top: 0
          tooltip:
            show: true
            trigger: "axis"
            axisPointer: {
              type: 'cross'
            }
          legend:
            show: true
            right: '2%'
            orient: "horizontal"
            textStyle:
              fontSize: 14
              color: "#FFFFFF"
            data: _legendData
          grid:
            right: 20
          toolbox:
            show: true
            right: 20
            feature:
              dataZoom:
                show: false
              dataView:
                show: false
              magicType:
                show:false
#                type: ['line', 'bar']
              restore:
                show: false
              saveAsImage:
                show: false
          dataZoom: [
            {
              type: 'inside',
              realtime: true,
              xAxisIndex: 0,
              start: opts.start,
              end: opts.end,
            },{
              type: 'inside',
              realtime: true,
              yAxisIndex: 0
            },
            {
              show: true,
              realtime: true,
              xAxisIndex: 0,
              type: 'slider',
              height: 20
              borderColor: 'rgba(2,62,116,1)'
              dataBackground:{
                lineStyle: {
                  width: 3
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
                areaStyle:{
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
              },
              handleStyle:
                color: 'rgba(0,167,255,1)'
              textStyle:
                fontSize: 14
                color: "#FFFFFF"
              fillerColor:"rgba(2,62,116,0.8)",
              bottom: 10
            },{
              show: true,
              realtime: true,
              yAxisIndex: 0,
              type: 'slider',
              left: 20
              borderColor: 'rgba(2,62,116,1)'
              dataBackground:{
                lineStyle: {
                  width: 3
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
                areaStyle:{
                  color: {
                    type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                    colorStops: [{
                      offset: 0, color: '#1A45A2'
                    }, {
                      offset: 1, color: '#00E7EE'
                    }]
                  }
                }
              },
              handleStyle:
                color: 'rgba(0,167,255,1)'
              textStyle:
                fontSize: 14
                color: "#FFFFFF"
              fillerColor:"rgba(2,62,116,0.8)",
            }
          ],
          xAxis:
            show: false
            nameTextStyle:
              color: '#fff'
            data : opts.xData
            type: 'category'
            boundaryGap: false
            nameLocation: "middle"
            axisLine:
              onZero: false
              lineStyle:
                color: "#204BAD"
            axisLabel:
              show: false
              textStyle:
                color: "#fff"
          yAxis:
            type : 'value'
            axisLine:
              lineStyle:
                color: "#204BAD"
            axisLabel:
              textStyle:
                color: "rgba(156,165,193,1)"
            splitLine:
              lineStyle:
                color: ["#204BAD"]
          series: series
        scope.mychart.setOption(option)

    resize: (scope)->
      @$timeout =>
        scope.mychart?.resize()
      ,0
    dispose: (scope)->


  exports =
    StreamTestDirective: StreamTestDirective