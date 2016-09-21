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

files_on_page=100;  # liczba zdjęć na stronie
img_width=300;      # szerokość zdjęcia w px
#files_list=$(ls *.jpg *.JPG *.gif *.GIF *.png *.PNG); # tworzenie listy plików
files_list=$(ls -R 2>/dev/null *.jpg *.JPG *.gif *.GIF *.png *.PNG); # tworzenie listy plików

links=""; # to będą linki do podstron
val=0; # zmienna, w której będę przechowywał informację o liczbie pozyskanych plików
for i in $files_list; do
    val=$((val+1)); # zliczanie plików
done
echo "Liczba plików: $val"; # wyświetlam ile plików znaleziono
nrof=$((val/files_on_page)); # określam liczbę podstron
echo "Liczba podstron: $nrof"; # wyświetlam liczbę podstron
if [ $nrof != 0 ] # jak liczba podstron nie jest równa 0 to tworzę listę linków do podstron
then
    links="<nav class=\"links\">"; # pasek nawigacyjny z linkami
    for i in $(seq 0 $nrof) # od 0 do $nrof tworzę linków pełen stos!
    do
            links="$links<a href=\"html_file$((i+1)).html\">$((i+1))</a> "; # dopisuję linki wnet
        done
    links="$links</nav>" # i zamykam nav też
fi

k=0
j=0
page="" # zmienna pomocnicza, która będzie zawartość strony zawierała

begin="<html><header><meta charset=\"UTF-8\"><style>img{width: "$img_width"px;}body{width:1000px;text-align:center;margin: auto;background-color: black}a{text-decoration: none;color:red}.links{background-color:#2f2f2f;padding: 10px;}</style></header><body>"; # a to cały początek strony

folder="folder";

if [ -d $folder ]
then
    echo "Folder o podanej nazwie już istnieje, chcesz go nadpisać [t]:"
    read w;
    if [ $w != "t" ]
    then
        echo "Podaj nową nazwę folderu:"
        read folder;
        while [ -d $folder ]
        do
            echo "Folder o podanej nazwie już istnieje, podaj inną nazwę:"
            read folder;
        done
        mkdir $folder
    fi
else
    mkdir "$folder" # tutaj tworzę folder potrzebny dla wrzucenia tam miniatur
fi

for i in $files_list; # iterowanko po nazwach plików
    do
        convert $i -resize $img_width +profile '*' "$folder/"$i; # zapis miniaturki zdjęcia do folderu folder
        if [ $((k%files_on_page)) = 0 ]; # jak reszta z dzielenia jest licznika plików k jest równa zero to
        then
            if [ $k != 0 ] # gdy k nie jest równe zero
            then
                echo "$begin$links$page$links</body></html>">"html_file$j.html"; # to zapisuję dane do pliku o indeksie $j
                page=""; # i czyszczę zmienną pomocniczą page
            fi
            j=$((j+1)) # zwiększam licznik utworzonych stron
            page="$page<a href=\"$i\"><img src=\"$folder/$i\" /></a>"; # dodaję pierwszego linka dla $j-tego pliku html
        else # w przeciwnym przypadku
            page="$page<a href=\"$i\"><img src=\"$folder/$i\" /></a>"; # dodeję kolejne linki dla $j-tego pliku html
        fi
        echo "Przetwarzanie: $((k+1)) z $val; nazwa pliku: $i";
        k=$((k+1)) # zwiększam licznik plików graficznych
    done
if [ ${#page} != 0 ] # jak ciąg znaków w zmiennej pomocniczej page nie jest równy 0 to
then
    echo "$begin$links$page$links</body></html>">"html_file$j.html"; # trzeba zapisać jeszcze łostatnią podstronę czy też stronę
fi

