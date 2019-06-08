BEGIN					{ FS=" "; RS="\n" }

                        { if ($5 == "NP") nomes[$2]++;}

END						{ 
    print "<html>" > "index.html" ;
    print "<title> HarryPotter Characters </title> <body>" >> "index.html";
    
    for(i in nomes){
        
        
        print "<p> <a href=" i".html ><b>"i"</b></a></p>" >> "index.html"
        
        print "<html> <body>" > i".html";
        print "<p>" i " -> " nomes[i] "</p>" >> i".html";
        print "</body> </html>" >> i".html";

       
    }

    print "</body> </html>" >> "index.html";

}