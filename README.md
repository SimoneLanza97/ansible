# THIS IS MY REPO TO LEARN ANSIBLE 

Per usare ansible su dei server remoti abbiamo la necessità di creare una chiave ssh e condividere la chiave pubblica sui server di destinazione .

## creiamo la chiave 

    ssh-keygen -t ed25519 -C "ansible" #salviamo la chiave con il nome che preferiamo al path /home/utente/.ssh/<nome_chiave>

## condividiamo la chiave     

    ssh-copy-id -i /home/lanza/.ssh/<nome_chiave>.pub <nome_utente>@<ip del server>


## inventory file

il file "inventory" contiene gli indirizzi delle macchine a cui ci connettiammo con ansible 

Una volta condivisa la chiave ai server e inseriti gli indirizzi di tali server nel file inventory possiamo provare a lanciare un comando per verificare che tutto funzioni.
Quando lanciamo un comando con ansible dobbiamo specificare il file di inventory e la chiave ssh da utilizzare, in questo modo :

    ansible all --key-file ~/.ssh/ansible -i inventory -m ping 



## ansible.cfg file

Il file ansible.cfg potrebbe già esistere nel path /etc/ansible , ma in ogni caso scrivendolo in locale lo andiamo a sovrascrivere , ovvero il file locale ha la priorità su quello in /etc/ansible 

Nel file ansible.cfg andiamo ad inserire alcune specifiche come il path del file inventory e il path della chiave ssh , in questo modo non dovremmo specificare ogni volta quale file inventory usare e quale chiave usare.

Lo stesso comando usato in precedenza ora possiamo utilizzarlo cosi :

    ansible all -m ping 


## sudo mode 

Molti dei comandi che potremmo voler eseguire sui server potrebbero richiedere di essere eseguiti con privilegi di amministratore, come ad esempio un semplice "apt update".
Di fatti , se noi eseguiamo un aggiornamento dei pacchetti sui server in questo modo

    ansible all -m apt -a update_cache=true 
il comando fallirà perchè non avremo i privilegi per eseguire quel tipo di comando.
Per poter eseguire un comando con privilegi di amministratore usiamo l'opzione "--become" che serve per eseguire il comando come amministratore, in questo modo :

    ansible all -m apt -a update_cache=true --become 

In questo modo si potrà eseguire il comando con i privilegi di ammistratore senza dover inserire la password, se invece volessimo inserire la password di amministratore per eseguire i comandi allora digiteremmo il seguente comando: 

    ansible all -m apt -a update_cache=true --become --ask-become-pass

--ask-become-pass ci obbliga ad inserire la password di amministratore dei server a cui vogliamo connetterci per eseguire il comando con privilegi, attenzione però che se su diversi server abbiamo diverse password di ammistratore , il comando fallirà , il consiglio è quello di tenere le stesse password di amministratore per il gruppo di server su cui vogliamo eseguire i nostri comandi 


