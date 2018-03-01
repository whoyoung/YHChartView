/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
import { StackNavigator } from 'react-navigation';
import RNLineChart from './charts/RNLineChart'
import RNHorizontalBar from './charts/RNHorizontalBar'
import RNVerticalBar from './charts/RNVerticalBar'

class HomeScreen extends React.Component {
  static navigationOptions = {
    title: 'RNHome',
  };
  render() {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'flex-start' }}>
        <Button
          title="RN Line Chart"
          onPress={() => this.props.navigation.navigate('RNLineChart')}
        />
        <Button
          title="RN Horizontal Bar"
          onPress={() => this.props.navigation.navigate('RNHorizontalBar')}
        />
         <Button
          title="RN Vertical Bar"
          onPress={() => this.props.navigation.navigate('RNVerticalBar')}
        />
      </View>
    );
  }
}

const RootStack = StackNavigator(
  {
    Home: {
      screen: HomeScreen,
    },
    RNLineChart: {
      screen: RNLineChart,
    },
    RNHorizontalBar: {
      screen: RNHorizontalBar
    },
    RNVerticalBar: {
      screen: RNVerticalBar
    }
  },
  {
    initialRouteName: 'Home',
    navigationOptions: {
      headerStyle: {
        backgroundColor: '#f4511e',
      },
      headerTintColor: '#fff',
      headerTitleStyle: {
        fontWeight: 'bold',
      },
    },
  }
);

export default class YHChartViewDemoRN extends Component {
  render() {
    return <RootStack />;
  }
}

AppRegistry.registerComponent('YHChartViewDemoRN', () => YHChartViewDemoRN);
