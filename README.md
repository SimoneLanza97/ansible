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

Per quello che rigurda le variabili create da noi invece , nel caso più semplice possimo salvarle dentro al playbook in questione , ma nel caso in cui volessimo tenere fisse delle variabili per riutilizzarle allo stesso modo in playbook diversi , possiamo invece salvarle dentro al file inventory.
Dentro il file inventory le variabili vengono assegnate direttamente agli host (o ai gruppi di host ma questo lo vedremo tra poco), ecco un esempio di come le variabili vengono assegnate ai singoli host nel file inveontory 

     192.168.56.10 apache_package=apache2 
     192.168.56.11 apache_package=apache2 
     192.168.56.12 apache_package=apache    #su server con distribuzioni diverse il pacchetto puo avere nomi diversi 

In questo semplicissimo esempio andiamo a definire per i nostri host che la variabile apache_package verrà usata per delineare il pacchetto apache2/apache che sono due nomi differenti per definire il pacchetto contenente apache2 su diverse distruzioni linux , e ora potremmo usare per tutti i nostri server differenti il nome apache_package al posto di dover scrivere un nome differente del pacchetto per ogni server differente.

## gestione dei gruppi di nodi 

Dentro al file inventory possiamo avere una grande quantità di nodi registrati , e potremmo avere esigenze diverse riguardo ai diversi nodi in base a diverse variabili , per esempio potremmo avere dei db_servers , dei file_servers , web_servers e cosi via .. e su questi server necessiteranno da parte nostra diversi interventi .
Per affrontare questa problematica senza dover eseguire più playbook , ansible ci da la possibilità di creare dei gruppi e dividere tra questi gli host in maniera molto semplice.
Per farlo ci basta andare nel file inventory creare i gruppi dichiarandoli tra parentesi [] e inserire al di sotto del gruppo gli indirizzi dei nodi che ne faranno parte .

    [servers_ubuntu]
    192.168.1.1
    192.168.1.2
    192.168.1.3
    192.168.1.4
    [servers_centOS]
    192.168.1.11
    192.168.1.12
    192.168.1.13
    192.168.1.14
    
In questo modo poi potremmo scrivere un playbook che vada a svolgere azioni mirate ai nodi di un determinato gruppo e per farlo ci basta inserire il nome del gruppo nella voce 'hosts:'
del playbook, in questo modo 

    
    ---
    - name: playbook 
      become: yes
      tasks:
        - name: aggiornamento update
          hosts: servers_ubuntu  
          package: 
            update_cache: yes 
        - name: aggiornamento update
          hosts: servers_centOS  
          package: 
            update_only: yes 
Inoltre , come annunciato precedentemente , possiamo salvare variabili per l'intero gruppo di host invece di specificare variabili uguali per ogni nodo , per farlo ci basta andare a definire nel file inventory un gruppo di variabili in questo modo 


    [servers_ubuntu]
    192.168.1.1
    192.168.1.2
    192.168.1.3
    192.168.1.4

    [servers_ubuntu.vars]
    apache_package=apache2

In questo modo andiamo a definire una variabile valida per un intero gruppo di host dichiarandola una sola volta 


## utilizzo dei tags 

I tags non sono altro che delle etichette arbitrarie che diamo a determinati task o interi playbook , questo perchè vogliamo eseguire solamente determinati task o playbooks presenti del nostro file yaml e allora possiamo richiamare determinati tags  nel momento in cui andiamo ad eseguire un playbook per poter eseguire solo i task che hanno quel tag  

    ---
      - name: tags explaination
      become: yes
      hosts: all
      tasks:
          - name: update 
          package:
            update_cache: yes
          tags: update  

    - name: installing nginx with tags 
      become: yes
      hosts: all
      tasks:

        - name: install nginx  
          package:
            name: nginx
            state: latest 
          tags: nginx 
  
se eseguiamo questo playbook possiamo andare a definire i tag che vogliamo seguire ed eseguire solo i task con i tag indicati, in questo modo:

    ansible-playbook -b tag_playbook.yml -t nginx

questo comando farà in modo che venga eseguito solamente l'utimo task, quello con il tag nginx. 
Possiamo usare i tag sui singoli task come nell'esempio , oppure possiamo usare tag su interi playbook nel caso in cui ci fossero più playbook con diversi blocchi di istruzioni nel file.yml .
