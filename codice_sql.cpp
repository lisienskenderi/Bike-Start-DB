#include <cstdio>
#include <iostream>
#include <fstream>
#include "dependencies/include/libpq-fe.h"

#define PG_HOST "127.0.0.1"
#define PG_USER "postgres"
#define PG_DB "postgres"
#define PG_PASS "password"
#define PG_PORT 5432


using namespace std;

void checkResults(PGresult * res, const PGconn* conn){
    if(PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Risultati inconsistenti" << PQerrorMessage(conn);
        PQclear(res);
        exit(1);
    }
}

void printLine(int campi, int* maxChar) {
    for (int j = 0; j < campi; ++j) {
        cout << '+';
        for (int k = 0; k < maxChar[j] + 2; ++k)
            cout << '-';
    }
    cout << "+\n";
}

void printQuery(PGresult* res) {
    // Preparazione dati
    const int tuple = PQntuples(res), campi = PQnfields(res);
    string v[tuple + 1][campi];

    for (int i = 0; i < campi; ++i) {
        string s = PQfname(res, i);
        v[0][i] = s;
    }
    for (int i = 0; i < tuple; ++i)
        for (int j = 0; j < campi; ++j) {
            if (string(PQgetvalue(res, i, j)) == "t" || string(PQgetvalue(res, i, j)) == "f")
                if (string(PQgetvalue(res, i, j)) == "t")
                    v[i + 1][j] = "si";
                else
                    v[i + 1][j] = "no";
            else
                v[i + 1][j] = PQgetvalue(res, i, j);
        }

    int maxChar[campi];
    for (int i = 0; i < campi; ++i)
        maxChar[i] = 0;

    for (int i = 0; i < campi; ++i) {
        for (int j = 0; j < tuple + 1; ++j) {
            int size = v[j][i].size();
            maxChar[i] = size > maxChar[i] ? size : maxChar[i];
        }
    }

    // Stampa effettiva delle tuple
    printLine(campi, maxChar);
    for (int j = 0; j < campi; ++j) {
        cout << "| ";
        cout << v[0][j];
        for (int k = 0; k < maxChar[j] - v[0][j].size() + 1; ++k)
            cout << ' ';
        if (j == campi - 1)
            cout << "|";
    }
    cout << endl;
    printLine(campi, maxChar);

    for (int i = 1; i < tuple + 1; ++i) {
        for (int j = 0; j < campi; ++j) {
            cout << "| ";
            cout << v[i][j];
            for (int k = 0; k < maxChar[j] - v[i][j].size() + 1; ++k)
                cout << ' ';
            if (j == campi - 1)
                cout << "|";
        }
        cout << endl;
    }
    printLine(campi, maxChar);
}

int main ( int argc, char *argv[]) {
    
    char conninfo [250];
    sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

    
    PGconn * conn = PQconnectdb(conninfo);
    if (PQstatus(conn) != CONNECTION_OK) {
        cout << "Errore di connsessione\n" << PQerrorMessage(conn);
        PQfinish(conn);
        exit(1);
    }
    
    cout << "Connessione avvenuta correttamente" << endl;
    
    PGresult * res1 = PQexec(conn, "SELECT  matricola,stipendio, nome, cognome, email FROM impiegato WHERE stipendio <= (SELECT avg(stipendio) from impiegato)");
    PGresult * res2 = PQexec(conn, "SELECT count(i.nome) as nr_impiegati, c.targa,c.citta,c.nome FROM impiegato I , carsede c WHERE i.nr_patenta IS NOT NULL AND c.citta = i.sede GRoup by c.targa, c.citta, c.nome");
    PGresult * res3 = PQexec(conn, "SELECT citta, nome, cognome, email FROM sede LEFT JOIN impiegato ON citta = sede_responsabilita");
    PGresult * res4 = PQexec(conn, "SELECT  I.matricola, I.nome, I.cognome, I.stipendio, I.email,  count(C.matricola) as Numero_di_caricamenti FROM impiegato I, caricamento C WHERE I.matricola = C.matricola GROUP BY I.matricola HAVING count(C.matricola) >= 2 ORDER BY Numero_di_caricamenti DESC");
    PGresult * res5 = PQexec(conn, "SELECT count(np.id), c.matricola FROM noleggio_passato NP, cliente C WHERE c.matricola = np.matricola GROUP BY c.matricola");
    PGresult * res6 = PQexec(conn, "SELECT count(M.id), C.matricola, c.tipo FROM cliente C, metodo_di_pagamento M WHERE c.matricola = m.matricola GROUP BY c.matricola");
    PGresult * res7 = PQexec(conn, "SELECT s.citta, count(t.matricola) FROM sede S, tottal T WHERE s.citta = t.citta group by s.citta");
                                                                
    bool cycle = true;
    int i = 0;
    while(cycle){
        switch(i){
            case 0:
                cout << "Tutte le tabele possibile per dimostrare.\n";
                cout << "Per dimostrare le tabelle sotto , premi il numero e poi premi enter.\n";
                cout << "Per usire dal programa premi qualsiasi altro numero.\n";
                cout << "NON premi un altro input trane che numero!\n";
                cout << "0 - Per mostrare questo testo.\n";
                cout << "1 - Dimostra tutti i impiegati con stipendio piu basso della media.\n";
                cout << "2 - Dimostra i veicoli, dove si trovano e il suo nome, e da quanti impiegati possono essere usati.\n";
                cout << "3 - Dimostra i dipendenti delle sede e anche quelle sede che non hanno hanno un dipendente.\n";
                cout << "4 - Dimostra chi dai impiegati ha fatto almeno 2 caricamenti.\n";
                cout << "5 - Dimostra quante volta hanno usatto una bici o scooter i clienti attivi.\n";
                cout << "6 - Dimostra i utenti con numero di matricola, che tipo sono, base o premium e quanti metodi di pagamento usano.\n";
                cout << "7 - Dimostra quante volte i clienti hanno noleggiato nelle sede attuale che si trovano i mezzi di transporti per noleggiare.\n";
                break;
            case 1:
                //Dimostra tutti i impiegati con stipendio piu basso della media
                printQuery(res1);
                cout<<endl;
                cout<<endl;
                break;

            case 2:
                //Dimostra i veicoli, dove si trovano e il suo nome, e da quanti impiegati possono essere usati
                
                printQuery(res2);
                cout<<endl;
                cout<<endl;
                break;

            case 3:    
                //Dimostra i dipendenti delle sede e anche quelle sede che non hanno hanno un dipendente
                
                printQuery(res3);
                cout<<endl;
                cout<<endl;
                break;
            case 4:
                //Dimostra chi dai impiegati ha fatto almeno 2 caricamenti
                printQuery(res4);
                cout<<endl;
                cout<<endl;
                break;
            case 5:
                //Dimostra quante volta hanno usatto una bici o scooter i clienti attivi
                printQuery(res5);
                cout<<endl;
                cout<<endl;
                break;
            case 6:
                //Dimostra i utenti con numero di matricola, che tipo sono, base o premium e quanti metodi di pagamento usano
                printQuery(res6);
                cout<<endl;
                cout<<endl;
                break;
            case 7:
                //Dimostra quante volte i clienti hanno noleggiato nelle sede attuale che si trovano i mezzi di transporti per noleggiare
                printQuery(res7);
                cout<< endl;
                cout <<endl;
                break;
            default:
                cycle = false;
                break;
        }
        cin >> i;
        if(i < 0 || i > 7){
            cycle = false;
        }
    }


    PQfinish(conn);

    return 0;
}