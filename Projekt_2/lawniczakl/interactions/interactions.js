function drawPlot() {
	var margin = {left: 80, top: 80, right: 0, bottom: 0};
	var svg = d3.select("svg");
	var width = svg.attr("width") - margin.left - margin.right, 
		height = svg.attr("height") - margin.top - margin.bottom;
	
	d3.json("data.json", function(data) {
		var x = d3.scaleBand()
			.domain(data.nodes)
			.range([0, width])
			.paddingInner(0.05);
		var y = d3.scaleBand()
			.domain(data.nodes)
			.range([0, height])
			.paddingInner(0.05);
		var fill = d3.scaleQuantize()
			.domain([0, d3.max(data.links.map(d => d.value))])
			.range(["#fee5d9","#fcbba1","#fc9272","#fb6a4a","#de2d26","#a50f15"]);
		
		var grp = svg.append("g")
			.attr("transform", "translate("+margin.left+","+margin.top+")");
		grp.selectAll("rect").data(data.links)
			.enter().append("rect")
			.attr("x", d => x(d.source))
			.attr("y", d => y(d.target))
			.attr("width", x.bandwidth())
			.attr("height", y.bandwidth())
			.style("fill", d => fill(d.value))
			.style("tooltip", d => d.value);
		
		svg.append("g")
			.attr("transform", "translate("+margin.left+","+margin.top+")")
			.call(d3.axisLeft().scale(x));
		
		svg.append("g")
			.call(d3.axisRight().scale(y))
			.attr("transform", "translate("+margin.left+","+margin.top+")rotate(270)");
	});
}