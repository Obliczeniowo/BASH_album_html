###############################################################################################
######################################### WSTĘP ###############################################
###############################################################################################
# Program html_gen2.sh jest skryptem stworzonym przez Krzysztofa Zajączkowskiego ##############
# dostępnym na licencji GPL 3.0 <https://www.gnu.org/licenses/gpl-3.0.html> ###################
# program dostępny na stronie obliczeniowo.com.pl/?id=488 #####################################
###############################################################################################
# OSTRZEŻENIE: ################################################################################
# Autor programu dołożył wszelkich starań, aby nie sprawiało ono żadnych kłopotów i nie #######
# wykonywało żadnych działań mających na celu uszkodzenie, zniszczenie lub utratę danych ######
# zawartych na dysku jego użytkownika. Jakkolwiek nie da się wszystkiego przewidzieć ##########
# a oprogramowanie to w trakcie pracy TWORZY i NADPISUJE pliki, w miejscu jego uruchomienia ###
# Program tworzy: #############################################################################
# Folder o nazwie "folder" a w nim miniatury zdjęć i grafik o tej samej nazwie ################
# pliki *.html o kolejnych nazwach html_file$j.html - gdzie $j - oznacza wstawienie kolejnych #
# cyfr indeksów zaczynając od 1 -> n, gdzie n z kolei należy do zbioru liczb całkowitych ######
# W związku z powyższym należy mieć na uwadze fakt, że program ten w trakcie działania ########
# nadpisuje bez ostrzeżenia (jeśli te istnieją) wyżej wymienione pliki, znajdujące się w ######
# lokalizacji, z której skrypt został uruchomiony #############################################
###############################################################################################
# WYŁĄCZENIE ODPOWIEDZIALNOSĆI: ###############################################################
###############################################################################################
# Z wyżej wymienionych względów autor programu NIE PONOSI odpowiedzialności karnej za #########
# niepożądane skutki działania niniejszego skryptu. ###########################################
###############################################################################################

###############################################################################################
# Ten skrypt w celu poprawnego działania wymaga zainstalowania powłoki systemowej BASH w ######
# wersji co najmniej 4+ #######################################################################
###############################################################################################
# Przykład uruchomienia skryptu: ##############################################################
###############################################################################################
# bash html_gen.sh body_color=#ff9955 nav_color=#ffccaa links_color=#c04d00 img_width=250 #####
# files_on_page=50 ############################################################################
###############################################################################################
# W powyższym przykładzie użyto skryptu z opcjami sterującymi wyglądem strony html: ###########
###############################################################################################
# body_color=#ff9955 - oznacza kolor tła znacznika body #######################################
# nav_color=#ffccaa - oznacza kolor tła elementu nav strony ###################################
# links_color=#ffccaa - oznacza kolor tekstu linków ###########################################
# img_width=250 - oznacza szerokość obrazka ###################################################
# files_on_page=50 - określa maksymalną liczbę obrazków na stronie ############################
###############################################################################################

declare -A arguments=() # tablica asocjacyjna

function findSign(){                                        # funkcja zwraca położenie danego znaku w ciągu znaków
                                                            # $1 - przeszukiwany ciąg
                                                            # $2 - szukany znak
    for i in $(seq 1 $((${#1}-1)))                          # przeszukiwanie po zakresie od 0 do liczby znaków zawartych w $1 pomniejszonej o 1
    do
        if [ ${1:i:1} == $2 ]                               # jeżeli pod danym indeksem znaleziono znak to
        then
            echo $i;                                        # dziabaj go na ekran
            return;                                         # wyjście z funkcji
        fi
    done
    echo -1;                                                # a jak nie znaleziono to zwróć -1
}

function setValue(){                                        # ustawia wartość w tablicy asocacyjnej arguments
                                                            # $1 - parametr w formacie "klucz=wartość"
    separator=$(findSign "$1" "=");                         # znajdowanie separatora w podanym na wejście argumencie
    if [ separator != -1 ]                                  # jeżeli znaleziono znak = to
    then
        arguments[${1:0:separator}]=${1:$((separator+1))};  # wydziabuję klucz i wartość z argumentu funkcji $1 i wrzucam je do tablicy asocjacyjnej arguments
    fi
}

# A tutaj ustawiam sobie domyślne parametry

setValue "body_color=black";                                # kolor tła znacznika body
setValue "nav_color=#2f2f2f";                               # kolor tła znacznika nav
setValue "links_color=red";                                 # kolor czcionki odnośników
setValue "files_on_page=100";                               # liczba zdjęć na stronę
setValue "img_width=300";                                   # szerokość zdjęcia w px oczywiście

for arg in "$@"                                             # wczytywanie argumentów skryptu do tablicy asocjacyjnej
do
    setValue $arg                                           # get arguments and add it to table
done

files_on_page=${arguments["files_on_page"]};                # liczba zdjęć na stronie
img_width=${arguments["img_width"]};                        # szerokość zdjęcia w px
#files_list=$(ls *.jpg *.JPG *.gif *.GIF *.png *.PNG); # tworzenie listy plików
files_list=$(ls -R 2>/dev/null *.jpg *.JPG *.gif *.GIF *.png *.PNG); # tworzenie listy plików

links="";                                                   # to będą linki do podstron
val=0;                                                      # zmienna, w której będę przechowywał informację o liczbie pozyskanych plików
for i in $files_list; do
    val=$((val+1));                                         # zliczanie plików
done
echo "Liczba plików: $val";                                 # wyświetlam ile plików znaleziono
nrof=$((val/files_on_page));                                # określam liczbę podstron
echo "Liczba podstron: $nrof";                              # wyświetlam liczbę podstron
if [ $nrof != 0 ]                                           # jak liczba podstron nie jest równa 0 to tworzę listę linków do podstron
then
    links="<nav class=\"links\">";                          # pasek nawigacyjny z linkami
    for i in $(seq 0 $nrof)                                 # od 0 do $nrof tworzę linków pełen stos!
    do
        links="$links<a href=\"html_file$((i+1)).html\">$((i+1))</a> "; # dopisuję linki wnet
    done
    links="$links</nav>"                                    # i zamykam nav też
fi

k=0
j=0
page=""                                                     # zmienna pomocnicza, która będzie zawartość strony zawierała

echo "img{width: "${arguments["img_width"]}"px;}body{width:1000px;text-align:center;margin: auto;background-color: ${arguments[body_color]};}a{text-decoration: none;color:${arguments[links_color]};}.links{background-color:${arguments[nav_color]};padding: 10px;}">style.css

begin="<html><header><meta charset=\"UTF-8\"><link rel=\"stylesheet\" href=\"style.css\"></header><body>"; # a to cały początek strony

folder="folder";                                            # nazwa folderu, w którym utworzone zostaną miniaturki

if [ -d $folder ]                                           # jak folder istnieje to
then
    echo "Folder o podanej nazwie już istnieje, chcesz go nadpisać [t]:" # informuj o tym biednego użytkownika i niezwłocznie go o decyzję pytaj
    read w;
    if [ $w != "t" ]                                        # jak decyzja jego jest by nie nadpisywać
    then
        echo "Podaj nową nazwę folderu:"                    # o nową nazwę trza się zapytywać
        read folder;
        while [ -d $folder ]                                # dopóki podana nazwa folderu istnieje
        do
            echo "Folder o podanej nazwie już istnieje, podaj inną nazwę:" # o nową nazwę pytaj by było weselej
            read folder;
        done
        mkdir $folder                                       # a gdy nazwa folderu będzie ci już znana, to utwórz go sobie do miniatur zapisywania
    fi
else
    mkdir "$folder"                                         # tutaj tworzę folder potrzebny dla wrzucenia tam miniatur
fi

for i in $files_list;                                       # iterowanko po nazwach plików
    do
        convert $i -resize $img_width +profile '*' "$folder/"$i; # zapis miniaturki zdjęcia do folderu folder
        if [ $((k%files_on_page)) = 0 ];                    # jak reszta z dzielenia jest licznika plików k jest równa zero to
        then
            if [ $k != 0 ]                                  # gdy k nie jest równe zero
            then
                echo "$begin$links$page$links</body></html>">"html_file$j.html"; # to zapisuję dane do pliku o indeksie $j
                page="";                                    # i czyszczę zmienną pomocniczą page
            fi
            j=$((j+1))                                      # zwiększam licznik utworzonych stron
            page="$page<a href=\"$i\"><img src=\"$folder/$i\" /></a>"; # dodaję pierwszego linka dla $j-tego pliku html
        else                                                # w przeciwnym przypadku
            page="$page<a href=\"$i\"><img src=\"$folder/$i\" /></a>"; # dodeję kolejne linki dla $j-tego pliku html
        fi
        echo "Przetwarzanie: $((k+1)) z $val; nazwa pliku: $i";
        k=$((k+1))                                          # zwiększam licznik plików graficznych
    done
if [ ${#page} != 0 ]                                        # jak ciąg znaków w zmiennej pomocniczej page nie jest równy 0 to
then
    echo "$begin$links$page$links</body></html>">"html_file$j.html"; # trzeba zapisać jeszcze łostatnią podstronę czy też stronę
fi
