#!/usr/local/bin/python
# coding: utf-8

import fileinput
import re

sentence_id = 0
words = []

print ('name,sentence_id,order_id,word')
for line in fileinput.input():
	if (re.search("\w.+:.*",line) != None):
		m = re.search("^(?P<name>\w[^:]+):(?P<words>.*)<br>$",line)
		if (m == None):
			continue
		name = m.group("name");
		wordstring = m.group("words");
		sentence_id = sentence_id+1;
		wordstring = wordstring.replace('.',' ').replace('-','').replace(',','').replace('!','').replace('?','').replace('(','').replace(')','').replace('<i>','').replace('</i>','').replace('<a>','').replace('</a>','').replace('\t','').replace(':','')
		words = wordstring.split(" ");
		
		name = name.replace('\’','').replace('\'','')	
		#obcinanie do pierwszego czlonu imienia, bo inaczej jest bardzo ciezko uzyskac dobry format
		#jedyna wazna postac, ktora trzeba poprawic w ramce danych to HIGH -> HIGH SPARROW
		if (re.search('^\w+[^\w]',name) != None):
			m = re.search('^(?P<clearname>\w+)[^\w]',name)
			name = m.group("clearname")
		
		#usuwanie czegos co nie jest slowami:
		words = filter((lambda x: re.search("\w",x)!= None),words)
		#nowe wiersze na wyjsciu:
		for i in range(0,len(words)):
			print ("{},{},{},{}".format(name, sentence_id, i, words[i])); 
		
