#!/usr/bin/gawk -f

BEGIN					{ FS="[ ]+|([ ]+[-]+)+([ ])?"; RS="\n"; }

NF==8 { if($5 == "NP") nomesProprios[$2]++;
		switch(getPos($6)){
			case "verb": verbos[$2]; break;
			case "noun": nomes[$2]; break;
			case "adverb": adverbios[$2]; break;
			case "adjective": adjetivos[$2]; break;
			default: break;
		};
		dicionario[$2" "getPos($6)" "$3]
		#lemas[$3] = getPos($6)
		#pos[getPos($6)] = $2
		#palavra[$2];
	  }
NF!=8 {}	  

END						{ 
						  createIndexHTML();	
						  print "-------------------\nNUMERO REGISTOS/EXTRATOS\n-------------------"
						  print NR; 
						  print "-------------------\nPERSONAGENS/NOMES_PROPRIOS\n-------------------"
						  
						  #PROCINFO["sorted_in"] = "cmp_num_val";
						  #for(pers in nomesProprios) print pers, "-" , nomesProprios[pers];
						  createVerbosHTML()
						  createNomesHTML()
						  createAdverbiosHTML()
						  createAdjetivosHTML()
						  createDicionarioHTML()
						}


function getPos(carateristicas){
	split(carateristicas, car, "|");
	split(car[1], pos, "=");
	return pos[2];
}

function cmp_num_cal(i1, v1, i2, v2){
    return (v2 - v1);
}

function cmp_str_ind(i1, v1, i2, v2){
	if(i1 > i2) return 1;
	if(i1 < i2) return -1;
	return 0;
}

function createIndexHTML(){
	file = "./html/index.html"
	BEGIN_HTML(file);

	print "<h1> <a href=\"./verbos.html\"> Verbos </a></h1>" > file
	print "<h1> <a href=\"./nomes.html\"> Nomes </a></h1>" > file
	print "<h1> <a href=\"./adverbios.html\"> Adverbios </a></h1>" > file
	print "<h1> <a href=\"./adjetivos.html\"> Adjetivos </a></h1>" > file

	END_HTML(file);
}

function createVerbosHTML(){
	file = "./html/verbos.html"
	BEGIN_HTML(file)

	print "<h1>Verbos :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(verb in verbos){
		print "<h1>"verb"</h1>" > file
	}

	END_HTML(file)
}

function createNomesHTML(){
	file = "./html/nomes.html"
	BEGIN_HTML(file)

	print "<h1>Verbos :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(nome in nomes){
		print "<h1>"nome"</h1>" > file
	}

	END_HTML(file)
}

function createAdverbiosHTML(){
	file = "./html/adverbios.html"
	BEGIN_HTML(file)

	print "<h1>Adverbios :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(adv in adverbios){
		print "<h1>"adv"</h1>" > file
	}

	END_HTML(file)
}

function createAdjetivosHTML(){
	file = "./html/adjetivos.html"
	BEGIN_HTML(file)

	print "<h1>Verbos :</h1></br>" > file
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(adj in adjetivos){
		print "<h1>"adj"</h1>" > file
	}

	END_HTML(file)
}

function createDicionarioHTML(){
	file = "./html/dicionario.html"
	BEGIN_HTML(file)

	firstChar = "aaa"
	PROCINFO["sorted_in"] = "cmp_str_ind"
	for(dic in dicionario){
			if(firstChar != substr(dic,0,1)){
			print substr(dic,0,1)
			firstChar = substr(dic,0,1)
			if(firstChar == "\"") firstChar = "aspas"
			wordsFile = "./html/dicionario/"firstChar".html"
			print "<h1> <a href=\"./dicionario/"firstChar".html\">" firstChar "</a></h1>" > file	
		}
		print "<h1>" dic "</h1>" > wordsFile
	}

	END_HTML(file)
}

function BEGIN_HTML(file){
	print "<head> <meta charset="UTF-8"> </head> <body>" > file
}

function END_HTML(file){
	print "</body>" > file
}