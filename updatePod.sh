#!/bin/sh
cd /Users/yanghu/YHChartView
git tag '0.3.12'
git push --tags
pod trunk push YHChartView.podspec --allow-warnings
pod search YHChartView