
var BarSeries = extendClass(ColumnSeries, {
	type: 'bar',
	init: function () {
		this.inverted = true;
		ColumnSeries.prototype.init.apply(this, arguments);
	}
});
seriesTypes.bar = BarSeries;

