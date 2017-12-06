h = 500
x0 = 25
x1 = 450

var y = d3.scale.linear()
	.domain([d3.min(data_m.map(d => 100+d.value)), d3.max(data_m.map(d => 100+d.value))])
	.range([h-30, 10]);

createPlot = function() {
	
	
}

updatePlot = function() {
	year = parseInt(document.getElementById("slider-time").value);
	
	d3.select("#xaxis")
		.call(d3.svg.axis().scale(y).orient("right"))
		.attr("transform", "translate("+(x1+10)+", 0)");
		
	d3.select("#yaxis")
		.call(d3.svg.axis().scale(d3.scale.ordinal()
			.domain(["30.11", "31.12"])
			.range([x0, x1])))
		.attr("transform", "translate(0, "+(h-24)+")");
	
	d3.select("#plot").selectAll("line")
		.data(data_m.filter(d => d.year === year))
		.attr("x1", x0)
		.attr("y1", y(100))
		.attr("x2", x1)
		.attr("y2", (d, i) => y(100+d.value))
		.style("stroke", (d, i) => legend.filter(l => l.name === d.name)[0].col)
		.style("stroke-width", 2);
	
	d3.select("#year text").text(year);
	
	d3.select("#legend").selectAll("rect")
		.data(legend)
		.enter()
		.append("rect")
		.attr("x", 10)
		.attr("y", (d, i) => 30*i+10)
		.attr("width", 20)
		.attr("height", 20)
		.style("fill", (d, i) => d.col);
		
	d3.select("#legend").selectAll("text")
		.data(legend)
		.enter()
		.append("text")
		.attr("x", 40)
		.attr("y", (d, i) => 30*i+25)
		.text((d, i) => d.name);
}
