import data from 'data.json';
import _ from 'lodash';
import * as d3 from "d3";

let currentRound = 1;
let thisRound = _.filter(data, (x) => x.round === currentRound);
let playing = false;

function chart() {
    const rowHeight = 30;
    const rowMargin = 5;

    d3.select('text.round')
        .text(() => 'Kolejka ' + currentRound);

    let table = d3.select('svg#table');

    let rows = table.selectAll('g')
        .data(thisRound);

    let groupsEnter = rows.enter().append('g');
    groupsEnter.append('rect')
        .attr('class', 'background')
        .attr('width', 450)
        .attr('height', rowHeight);
    groupsEnter.append('rect')
        .attr('class', 'points')
        .attr('x', 455)
        .attr('y', 5)
        .attr('height', rowHeight - 10);
    groupsEnter.append('text')
        .attr('class', 'name')
        .attr('x', 10)
        .attr('y', 20)
        .text((d, i) => d.name)
        .style("font", "20px monospace");
    groupsEnter.append('text')
        .attr('class', 'points')
        .attr('x', 410)
        .attr('y', 20)
        .style("font", "20px monospace");
    groupsEnter.append('text')
        .attr('class', 'goals')
        .attr('x', 300)
        .attr('y', 20);

    table.selectAll('g')
        .transition()
        .duration(750)
        .attr('transform', (d) => { return 'translate(0,' + (30 + (rowHeight + rowMargin) * (d.place - 1)) +')' });

    table.selectAll('g').selectAll('rect.points')
        .data((d) => [d])
        .transition()
        .duration(750)
        .attr('width', (d) => 20 * d.points);

    table.selectAll('g').selectAll('text.points')
        .data((d) => [d])
        .text((d) => d.points);

    table.selectAll('g').selectAll('text.goals')
        .data((d) => [d])
        .text((d, i) => d.goals_taken + ":" + d.goals_lost);
}

function changeRound(delta) {
    if (currentRound + delta > 18 || currentRound + delta < 1) return;
    currentRound += delta;
    thisRound = _.filter(data, (x) => x.round === currentRound);
    chart();
}

function timer() {
    if (!playing || currentRound === 18) {
        playing = false;
        d3.select('button.play').text('Odtwarzaj');
        return;
    }
    changeRound(1);
    setTimeout(timer, 2000);
}

document.addEventListener('DOMContentLoaded', () => {
    d3.select('svg#table')
        .append('text')
        .attr('class', 'round')
        .attr('x', 10)
        .attr('y', 20)
        .style("font", "20px monospace");

    d3.select('svg#table')
        .append('text')
        .attr('x', 300)
        .attr('y', 20)
        .text('Bramki');

    d3.select('svg#table')
        .append('text')
        .attr('x', 410)
        .attr('y', 20)
        .text('Punkty');

    d3.select('button.next')
        .on('click', () => changeRound(1));

    d3.select('button.prev')
        .on('click', () => changeRound(-1));

    let playButton = d3.select('button.play');
    playButton.on('click', () => {
        if (playing) {
            playButton.text('Odtwarzaj');
            playing = false;
        }
        else {
            playButton.text('Zatrzymaj');
            playing = true;
            timer();
        }
    });

    chart(thisRound);
});
