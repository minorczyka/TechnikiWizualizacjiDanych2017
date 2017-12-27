function formatTime(seconds) {
	function f2d(v) {
		return ("0"+v).slice(-2);
	}
	return f2d(Math.floor(seconds/3600))+":"+
		f2d(Math.floor(seconds/60)%60)+":"+
		f2d(seconds%60);
}

function drawPlot() {
	var canvas = d3.select("svg");
	var width = 10000, 
		height = canvas.attr("height")-30;
	var playSpeed = 50;
	//remove a hero after forgetThreshold seconds
	var forgetThreshold = 300;
	
	d3.json("scenario.json", function(data) {
		data = data.filter(d => d.name !== "!")
			.filter(d => d.start !== 0 && d.end !== 0);
		var scenes = d3.nest().key(d => d.scene)
			.rollup(d => {return {
				start: d3.min(d.map(v => v.start).filter(v => v !== 0)), 
				end: d3.max(d.map(v => v.end)),
				dialogs: d
			}})
			.entries(data);
		var duration = Math.floor(d3.max(data.map(d=>d.end)));
		d3.select("#slider-time")
			.attr("max", duration);
		
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
			
		function update() {
			var time = parseInt(d3.select("#slider-time").property("value"));
			d3.select("#time-hint").text(formatTime(time)+"/"+formatTime(duration));
			
			var scene = scenes[sceneNo(time)];
			var heroes = d3.nest().key(d => d.name)
				.rollup(d => {
					var i;
					for(i=0;i<d.length;++i)
						if(d[i].start > time)
							break;
					--i;
					return i === -1 ? null : d[i];
				}).entries(data)
				.filter(d => d.value != null)
				.filter(d => d.value.end > time-forgetThreshold)
				.map(d => d.value);
			console.log(heroes);
			
			locs.attr("transform", "translate("+(x.bandwidth()+10-x(scene.key))+",0)");
			axis.attr("transform", "translate("+(x.bandwidth()+10-x(scene.key))+","+(height-20)+")");
			
			var dphi = 2*Math.PI/heroes.length;
			var r = height*0.35;
			d3.select("#chars").selectAll("text").remove();
			d3.select("#chars").selectAll("text")
				.data(heroes)
				.enter()
				.append("text")
				.attr("x", (d, i) => 1.5*x.bandwidth() + r*Math.cos(i*dphi))
				.attr("y", (d, i) => height/2 + r*Math.sin(i*dphi))
				.text(d => d.name)
				.attr("text-anchor", "middle")
				.attr("opacity", d => 1 - Math.max(time-d.end, 0)/forgetThreshold);
		}
			
		d3.select("#slider-time").on("input", update);
		update();
		
		var play = null;
		d3.select("#play").on("click", function() {
			if(play == null) {
				play = setInterval(function() {
					var timeSlider = d3.select("#slider-time");
					timeSlider.property("value", parseInt(timeSlider.property("value"))+playSpeed/10);
					update();
				}, 100);
				d3.select("#play").text("⏸");
			} else {
				window.clearInterval(play);
				play = null;
				d3.select("#play").text("▶");
			}
		});
	});
}
