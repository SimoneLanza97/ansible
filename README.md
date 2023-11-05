# THIS IS MY REPO TO LEARN ANSIBLE 

Per usare ansible su dei server remoti abbiamo la necessità di creare una chiave ssh e condividere la chiave pubblica sui server di destinazione .

#creiamo la chiave 

    ssh-keygen -t ed25519 -C "ansible" -> salviamo la chiave con il nome che preferiamo al path /home/utente/.ssh/<nome_chiave>

#condividiamo la chiave     

    ssh-copy-id -i /home/lanza/.ssh/<nome_chiave>.pub <nome_utente>@<ip del server>


#inventory file

il file "inventory" contiene gli indirizzi delle macchine a cui ci connettiammo con ansible 

Una volta condivisa la chiave ai server e inseriti gli indirizzi di tali server nel file inventory possiamo provare a lanciare un comando per verificare che tutto funzioni.
Quando lanciamo un comando con ansible dobbiamo specificare il file di inventory e la chiave ssh da utilizzare, in questo modo :

    ansible all --key-file ~/.ssh/ansible -i inventory -m ping 



#ansible.cfg file

Il file ansible.cfg potrebbe già esistere nel path /etc/ansible , ma in ogni caso scrivendolo in locale lo andiamo a sovrascrivere , ovvero il file locale ha la priorità su quello in /etc/ansible 

Nel file ansible.cfg andiamo ad inserire alcune specifiche come il path del file inventory e il path della chiave ssh , in questo modo non dovremmo specificare ogni volta quale file inventory usare e quale chiave usare.

Lo stesso comando usato in precedenza ora possiamo utilizzarlo cosi :

    ansible all -m ping 
