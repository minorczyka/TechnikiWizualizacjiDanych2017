data = [{
	"year": 1997,
	"wig": 2.4,
	"wig20": 5.5,
	"mWIG40": 0,
	"sWIG80": -1.9
}, {
	"year": 1998,
	"wig": 8.7,
	"wig20": 9,
	"mWIG40": 7.8,
	"sWIG80": 8.5
}, {
	"year": 1999,
	"wig": 15.4,
	"wig20": 14.9,
	"mWIG40": 15.3,
	"sWIG80": 18.4
}, {
	"year": 2000,
	"wig": 9.5,
	"wig20": 11.9,
	"mWIG40": 4.4,
	"sWIG80": 3.2
}, {
	"year": 2001,
	"wig": -0.8,
	"wig20": -3.5,
	"mWIG40": 4.2,
	"sWIG80": -0.8
}, {
	"year": 2002,
	"wig": -2,
	"wig20": -3.6,
	"mWIG40": 0.8,
	"sWIG80": -1.4
}, {
	"year": 2003,
	"wig": 8.3,
	"wig20": 8.6,
	"mWIG40": 5.9,
	"sWIG80": 9.9
}, {
	"year": 2004,
	"wig": 4.8,
	"wig20": 6.5,
	"mWIG40": 2.2,
	"sWIG80": 3.5
}, {
	"year": 2005,
	"wig": 4.9,
	"wig20": 5.1,
	"mWIG40": 4.1,
	"sWIG80": 4.2
}, {
	"year": 2006,
	"wig": 0.4,
	"wig20": 2.1,
	"mWIG40": -3.8,
	"sWIG80": -1.9
},{
	"year": 2007,
	"wig": -1.8,
	"wig20": -2.5,
	"mWIG40": -1.6,
	"sWIG80": -0.8
},{
	"year": 2008,
	"wig": 0.4,
	"wig20": 2.7,
	"mWIG40": -3.2,
	"sWIG80": -4
},{
	"year": 2009,
	"wig": 1,
	"wig20": 1.5,
	"mWIG40": 2.7,
	"sWIG80": 1
},{
	"year": 2010,
	"wig": 4.7,
	"wig20": 5.1,
	"mWIG40": 4.1,
	"sWIG80": 4.2
},{
	"year": 2011,
	"wig": -4.8,
	"wig20": -6.3,
	"mWIG40": 0.1,
	"sWIG80": -2.7
},{
	"year": 2012,
	"wig": 5.4,
	"wig20": 6.7,
	"mWIG40": 1.8,
	"sWIG80": 4.8
},{
	"year": 2013,
	"wig": -6.3,
	"wig20": -7.1,
	"mWIG40": -4.7,
	"sWIG80": -4.5
},{
	"year": 2014,
	"wig": -3.4,
	"wig20": -4.2,
	"mWIG40": -2.2,
	"sWIG80": -1.5
},{
	"year": 2015,
	"wig": -3,
	"wig20": -3.5,
	"mWIG40": -2.4,
	"sWIG80": -1.2
},{
	"year": 2016,
	"wig": 6.4,
	"wig20": 8.3,
	"mWIG40": 2.7,
	"sWIG80": 1.8
}]

data_m = []
for(var i=0;i<data.length;++i) {
	data_m.push({year: data[i].year, name: "WIG", value: data[i].wig});
	data_m.push({year: data[i].year, name: "WIG20", value: data[i].wig20});
	data_m.push({year: data[i].year, name: "mWIG40", value: data[i].mWIG40});
	data_m.push({year: data[i].year, name: "sWIG80", value: data[i].sWIG80});
}

legend = [{
	name: "WIG",
	col: "#1b9e77"
}, {
	name: "WIG20",
	col: "#d95f02"
}, {
	name: "mWIG40",
	col:"#7570b3"
}, {
	name: "sWIG80",
	col: "#e7298a"
}];