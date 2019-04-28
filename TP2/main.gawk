#!/usr/bin/gawk -f

BEGIN					{ FS="[ ]+((-[ ]){2,})?"; RS="(- - - -\n)|\n"; n=0; extratos = 0}

NF==8 { if($5 == "NP" && getCurrentFileName()~"harrypotter.+") nomesProprios[$2]++;
		switch(getPos($6)){
			case "verb": verbos[$2]; break;
			case "noun": nomes[$2]; break;
			case "adverb": adverbios[$2]; break;
			case "adjective": adjetivos[$2]; break;
			default: break;
		};
		dicionario[$2" "getPos($6)" "$3]
	  }
#Apenas usado no ficheiro fl0
NF == 6 {
		switch(getGroup($4)){
			case "verb": verbos[$2]; break;
			case "noun": nomes[$2]; break;
			case "adverb": adverbios[$2]; break;
			case "adjective": adjetivos[$2]; break;
			default: break;
		}
		dicionario[$2" "getGroup($4)" "$3]
		}
#Caso encontre um registo não previsto	
NF != 6 && NF != 8 && NF != 0 {n++; print $0}	

#Quando existe uma mudança de Extrato
NF == 0 {extratos ++}

END						{ 
						  print "numero de registos não filtrados: ", n
						  createIndexHTML();	
						  createPersonagensHTML()
						  createVerbosHTML()
						  createNomesHTML()
						  createAdverbiosHTML()
						  createAdjetivosHTML()
						  createDicionarioHTML()
						  createReverseDicionarioHTML()
						}

function getGroup(sigla){
	firstChar = substr(sigla, 0, 1)
	switch(firstChar){
		case "N" : return "noun";
		case "V" : return "verb";
		case "R" : return "adverb";
		case "A" : return "adjective";
		case "F" : return "punctuation";
		case "W" : return "date";
		case "S" : return "adposition";
		case "D" : return "determiner";
		case "C" : return "conjunction";
		case "Z" : return "number";
		case "P" : return "pronoun";
		case "I" : return "interjection";
		default : print firstChar, sigla;
	}
}

function getPos(carateristicas){
	split(carateristicas, car, "|");
	split(car[1], pos, "=");
	return pos[2];
}
function getCurrentFileName() {
	fileName = FILENAME;
    gsub(".*/", "", fileName);
    return fileName;
  }

function cmp_num_val(i1, v1, i2, v2){
    return (v2 - v1);
}

function cmp_str_ind(i1, v1, i2, v2){
	if(i1 > i2) return 1;
	if(i1 < i2) return -1;
	return 0;
}

function cmp_str_partOfSpeech(i1, v1, i2, v2){
	split(i1, lema1, " ")
	split(i2, lema2, " ")
	if(lema1[2] > lema2[2]) return 1;
	if(lema1[2] < lema2[2]) return -1;
	return 0;
}

function createIndexHTML(){
	file = "./html/index.html"
	title = "Index"
	BEGIN_HTML(file,title);

	print "<h1> <a href=\"./verbos.html\"> Verbos </a></h1>" > file
	print "<h1> <a href=\"./nomes.html\"> Nomes </a></h1>" > file
	print "<h1> <a href=\"./adverbios.html\"> Adverbios </a></h1>" > file
	print "<h1> <a href=\"./adjetivos.html\"> Adjetivos </a></h1>" > file
	print "<h1> <a href=\"./personagens.html\"> Personagens </a></h1>" > file
	print "<h1> <a href=\"./dicionario.html\"> Dicionario </a></h1>" > file
	print "<h1> <a href=\"./partOfSpeech.html\"> Part of Speech </a></h1>" > file
	print "<h1> Numero de extratos: "extratos"</h1>" > file

	END_HTML(file);
}

function createPersonagensHTML(){
	file = "./html/personagens.html"
	title = "Personagens"
	BEGIN_HTML(file,title)

	PROCINFO["sorted_in"] = "cmp_num_val"
	for(pers in nomesProprios) 
		print "<h1>" pers, "-" , nomesProprios[pers] "</h1>" > file

	END_HTML(file)
}

function createVerbosHTML(){
	file = "./html/verbos.html"
	title = "Verbos"
	BEGIN_HTML(file, title)

	print "<h1>Verbos :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(verb in verbos){
		print "<h1>"verb"</h1>" > file
	}

	END_HTML(file)
}

function createNomesHTML(){
	file = "./html/nomes.html"
	title = "Nomes"
	BEGIN_HTML(file,title)

	print "<h1>Nomes :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(nome in nomes){
		print "<h1>"nome"</h1>" > file
	}

	END_HTML(file)
}

function createAdverbiosHTML(){
	file = "./html/adverbios.html"
	title = "Adverbios"
	BEGIN_HTML(file,title)

	print "<h1>Adverbios :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(adv in adverbios){
		print "<h1>"adv"</h1>" > file
	}

	END_HTML(file)
}

function createAdjetivosHTML(){
	file = "./html/adjetivos.html"
	title = "Adjetivos"
	BEGIN_HTML(file,title)

	print "<h1>Adjetivos :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(adj in adjetivos){
		print "<h1>"adj"</h1>" > file
	}

	END_HTML(file)
}

function createDicionarioHTML(){
	file = "./html/dicionario.html"
	title = "Dicionario"
	BEGIN_HTML(file,title)

	firstChar = "aaa"
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(dic in dicionario){
			if(firstChar != substr(dic,0,1)){
			firstChar = substr(dic,0,1)
			if(firstChar == "\"") firstChar = "aspas"
			wordsFile = "./html/dicionario/"firstChar".html"
			print "<h1> <a href=\"./dicionario/"firstChar".html\">" firstChar "</a></h1>" > file	
		}
		print "<h1>" dic "</h1>" > wordsFile
	}

	END_HTML(file)
}

function createReverseDicionarioHTML(){
	file = "./html/partOfSpeech.html"
	title = "PartOfSpeech"
	BEGIN_HTML(file,title)

	currentLema = ""
	PROCINFO["sorted_in"] = "cmp_str_partOfSpeech"
	for(dic in dicionario){
		split(dic, partOfSpeech, " ")
		if(currentPos != partOfSpeech[2]){
			currentPos = partOfSpeech[2]
			print "<h1> <a href=\"./pos/"currentPos".html\">" currentPos "</a></h1>" > file
		}
		partOfSpeechFile =  "./html/pos/"currentPos".html"
		print "<h1>"partOfSpeech[1]": "partOfSpeech[3]"</h1>" > partOfSpeechFile
		
	}
	END_HTML(file)
}

function BEGIN_HTML(file, title){
	print "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title>" > file
	print title > file
	print "</title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" content=\"" > file
	print title > file
	print "\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(230, 230, 230);padding-right: 1%;padding-left: 1%\" >\n" > file
}

function END_HTML(file){
	print "\n\t</body>\n</html>" > file
}