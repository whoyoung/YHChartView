import { PropTypes } from 'react';
import { requireNativeComponent, View } from 'react-native';

var iface = {
    name: 'BarChartViewIOS',
    propTypes: {
        data: PropTypes.string,
        onSelect: PropTypes.func,
        hideTipView:PropTypes.bool,
        ...View.propTypes // 包含默认的View的属性
    },
};

module.exports = requireNativeComponent('BarChartViewIOS', iface);