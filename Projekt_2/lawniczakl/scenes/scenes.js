function drawPlot() {
	var canvas = d3.select("svg");
	var width = 10000, 
		height = canvas.attr("height");
	var scenes;
	
	d3.json("scenario.json", function(data) {
		scenes = d3.nest().key(d => d.scene)
			.rollup(d => {return {
				start: d3.min(d.map(v => v.start).filter(v => v !== 0)), 
				end: d3.max(d.map(v => v.end)),
				dialogs: d
			}})
			.entries(data);
		
		var x = d3.scaleBand()
			.domain(scenes.map(d => d.key))
			.range([0, width])
			.paddingInner(0.05);
			
		var locs = d3.select("#locations");
		var chars = d3.select("#chars");
		
		locs.selectAll("rect").data(scenes).enter()
			.append("rect")
			.attr("x", d => x(d.key))
			.attr("y", 0)
			.attr("width", x.bandwidth())
			.attr("height", height-30)
			.style("stroke-width", 2)
			.style("stroke", "#000000")
			.style("fill", "#ffffff");
		
		var sceneNo = d3.scaleThreshold()
			.domain(scenes.map(s => s.value.end))
			.range(d3.range(0, scenes.length));
			
		var axis = canvas.append("g")
			.call(d3.axisBottom().scale(x))
			.attr("transform", "translate(0,"+(height-20)+")");
			
		d3.select("#slider-time").on("input", function() {
			console.log("update");
			var time = parseInt(document.getElementById("slider-time").value);
			var scene = scenes[sceneNo(time)];
			locs.attr("transform", "translate("+(x.bandwidth()+10-x(scene.key))+",0)");
			axis.attr("transform", "translate("+(x.bandwidth()+10-x(scene.key))+","+(height-20)+")");
			
			names = [...new Set(scene.value.dialogs.filter(d => d.start < time)
				.map(d => d.name))];
			d3.select("#chars").selectAll("text").remove().data(names)
				.enter()
				.append("text")
				.attr("x", x(scenes[1].key) + 0.5*x.bandwidth())
				.attr("y", (d, i) => 20*i)
				.text(d => d)
				.attr("text-anchor", "middle");
		});
	});
}
