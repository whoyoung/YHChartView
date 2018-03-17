
import React, { Component } from 'react';
import {
  View,
  Dimensions,
  Button
} from 'react-native';
const window = Dimensions.get('window');
import LineChartViewIOS from '../chartsIOSManager/LineChartViewIOS'
const dict = {
  "axis":["Mon","Tues","Wed","Thu","Fri","Sat","Sun"],
  "datas":[
          ["9883.6","580.2","980.3","-3330.4","1340.5","330.6","-170.7"],
          ["2222","12533.6","-158.7","91.9","1066.12","250.13","-6033.14"]
          ],
  "groupMembers":["zhang","yang"],
  "groupDimension":"成交人",
  "axisTitle":"星期",
  "dataTitle":"成交量",
  "valueInterval": "3",
  "referenceLineWidth": 2,
  "referenceLineColor": "dddddd",
  "axisTextColor": "000000",
  "dataTextColor": "000000",
  "axisTextFontSize":10,
  "showLoadAnimation": true,
  "loadAnimationTime": 0.8,
  "animationType": 2,
  "styles": {
          "lineStyle": {
                  "lineWidth":"1",
                  "showAxisDashLine":true,
                  "circleBorderWidth":2,
                  "originType": 1
                  }
          }
  };
export default class RNLineChart extends React.Component {
  static navigationOptions = {
    title: 'RNLineChart',
  };
  
  handleSelect(event) {
    console.log(event.nativeEvent)
  }
  removeToastView() {
    this.view.setNativeProps({
      hideTipView: true
    });
  }
  render() {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'flex-start',paddingLeft:20,paddingTop:20 }}>
        <LineChartViewIOS
            style={{width:window.width-40,height:window.height-40-64-40,marginBottom:20}}
            onSelect={(event) => this.handleSelect(event)}
            data={JSON.stringify(dict)}
            ref={view=>this.view = view}
        />
        <Button title='remove toast view' onPress={()=>this.removeToastView()} />
      </View>
    );
  }
}


