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


## playbooks 

I playbooks sono dei file YAML che ci consentono eseguire con Ansible un blocco di attività sui server remoti , in maniera da poter automatizzare serie intere di operazioni in maniera replicabile.
I playbooks hanno uno schema e una sintassi predefiniti , di seguito la struttura base di un playbook con le spiegazioni dei vari campi 

    ---

    - name:                 # Nome del playbook
      hosts:                # Gruppo_di_host
      become:               # Imposta su true se hai bisogno di privilegi di amministratore (sudo)
    
      vars:                 # Variabili specifiche del playbook
        variabile1: 
        variabile2:
    
      tasks:
        - name:                 # modulo che utilizza moduli integrati come apt 
          apt:                  # nome del modulo integrato apt (è un oggetto che contiene dentro di se gli elementi indentati)
            update_cache:       # yes per fare update
        
        - name:                 # Task che utilizza le variabili
          debug:
            msg:                # "Valore della variabile1: {{ variabile1 }}, Valore della variabile2: {{ variabile2 }}" 


Puoi vedere il file playbooks/playbooks_example.yml per esempi più completi.

## La clausola when 

All'interno di un playbook possiamo inserire il parametro when che ci permette di usare una qualsiasi condizione (puo essere una variabile o un fattore di raccolta come quelli inclusi in gathering_facts) per eseguire determinate azioni solo sugli host che soddisfano la nostra condizione. 

    - name: install apache2 package  
      apt: 
        name: apache2
        state: absent
      when: ansible_nodename == "mac-03" # clausola che ci permette di effettuare l'operazione solo sul nodo chiamato  mac-03

## Le variabili 

Ansible ci permette di utilizzare delle variabili all'interno dei nostri playbook per poter definire determinate azioni .
Per poter essere utilizzate le variabili necessitano di essere salvate o dentro il file di inventory o dentro ad un file delle variabili o dentro il playbook stesso.
Ci sono varirabili interne di Ansible che possono essere utilizzate universalmente senza il bisogno di crearle e salvarle , come ad esempio la variabile 
'package' che puo essere usata in sostituzione alla specificazione del package_manager da utilizzare , se per esempio avessimo un playbook che effettua 
azioni su server con sistemi operativi diversi possiamo usare per tutti la variabile 'package' per tutti invece di specificare ogni signolo 
pkg_manager per ogni server .

    ---
    - name: playbook 
      hosts: all 
      become: yes
      tasks:
        - name: aggiornamento update
          package: 
            update_cache: yes 

Questo piccolo esempio ci permette di effettuare un aggiornamento dei pacchetti su tutti i server di destinazione anche se questi hanno diversi sistemi operativi 
invece di specificare apt , yum , dnf o pacman ecc... usiamo la variabile package per rappresentare il pkg_manager di riferimento e usare l'azione 'update_cache'
che è usata con una sintassi universale di ansible valida per ogni pkg_manager. 
Inoltre questo ci permette di scrivere un playbook più corto perchè altrimenti dovrei scrivere più task separate e si riduce anche il tempo di esecuzione del playbook stesso. 

