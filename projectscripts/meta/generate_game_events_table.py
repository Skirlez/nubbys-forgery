import csv


translation = {}
with open('NNF_Full_LocalizationEN.csv', newline='') as csvfile:
	reader = csv.reader(csvfile)
	for row in reader:
		if len(row) < 2:
			continue
		key = row[0]
		value = row[1]
		translation[key] = value

out = "|Event|English CSV value|\n|-|-|\n"
with open('scr_GameEv.gml', 'r') as file:
	lines = file.read().split('\n')
for line in lines:
	if line.strip().startswith("case"):
		key = line.strip()[6::][:-2]
		value = "No CSV value present"
		if key in translation:
			value = translation[key]

			value = value.replace("\t\t", "")
			value = value.replace("[#ffd500]", "")

			value = value.replace("[spr_ITArrow,0]", "→")
		out += f"|{key}|{value}|\n"

print(out)