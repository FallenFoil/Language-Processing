mkdir -p html/
mkdir -p html/pos/
mkdir -p html/dicionario/

exec="./main.gawk $@"
echo $exec
$exec