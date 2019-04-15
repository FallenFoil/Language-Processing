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
	  }
NF!=8 {}	  

END						{ print "-------------------\nNUMERO REGISTOS/EXTRATOS\n-------------------"
						  print NR; 
						  print "-------------------\nPERSONAGENS/NOMES_PROPRIOS\n-------------------"
						  PROCINFO["sorted_in"] = "cmp_num_val";
						  for(pers in nomesProprios) print pers, "-" , nomesProprios[pers];
						  print "-------------------\nVERBOS\n-------------------"
						  for(verb in verbos) print verb;
						  print "-------------------\nNOMES\n-------------------"
						  for(nome in nomes) print nome;
						  print "-------------------\nADVERBIOS\n-------------------"
						  for(adv in adverbios) print adv;
						  print "-------------------\nADJETIVOS\n-------------------"
						  for(adj in adjetivos) print adj;
						  } 

function getPos(carateristicas){
	split(carateristicas, car, "|");
	split(car[1], pos, "=");
	return pos[2];
}

function cmp_num_val(i1, v1, i2, v2)
{
     # numerical index comparison, ascending order
     return (v2 - v1);
}