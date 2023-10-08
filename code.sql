CREATE TABLE Cliente (
    Matricola           INT       PRIMARY KEY,
    Nome                varchar(45)     NOT NULL,
    Cognome             varchar(45)     NOT NULL,
    Data_di_Nascita     date            NOT NULL,
    Email               varchar(100)    NOT NULL,
    Tipo                char(8)         NOT NULL,
    Rata_Mensile        DECIMAL(5,2),
    Data_Iscrizione     DATE,
    Data_Fine_Iscrizione Date,
    Rata                DECIMAL(4,2),
    CHECK((Tipo = 'Base' AND Rata IS NOT NULL AND Rata_Mensile IS NULL AND Data_Iscrizione IS NULL AND Data_Fine_Iscrizione IS NULL)OR(Tipo = 'Premium' AND Rata IS NULL AND Rata_Mensile IS NOT NULL AND Data_Iscrizione IS NOT NULL AND Data_Fine_Iscrizione IS NOT NULL))
);

CREATE TABLE Metodo_di_Pagamento (
    ID                  INT             PRIMARY KEY,
    Tipo                CHAR(7)         NOT NULL,
    Numero              bigint,
    Nome_Cognome        VARCHAR(100),
    Nr_Sicurezza        INT,
    Data_di_Scadenza    DATE,
    Email               VARCHAR(100),
    Matricola           INT  NOT NULL,
	FOREIGN KEY (Matricola) REFERENCES Cliente(Matricola)  ON DELETE CASCADE,
    CHECK((Tipo = 'Carta' AND Numero IS NOT NULL AND Nome_Cognome IS NOT NULL AND Nr_Sicurezza IS NOT NULL AND Data_di_Scadenza IS NOT NULL AND Email IS NULL)OR(Tipo = 'Account' AND Numero IS NULL AND Nome_Cognome IS NULL AND Nr_Sicurezza IS NULL AND Data_di_Scadenza IS NULL AND Email IS NOT NULL))
);

CREATE TABLE Sede (
    Citta               VARCHAR(30)     PRIMARY KEY,
    Spesa_Annuale      DECIMAL(8,2)    NOT NULL,
    Reddito_Anno_Passato DECIMAL(8,2)
);

CREATE TABLE Impiegato (
    Matricola           INT        PRIMARY KEY,
    Nome                varchar(45)     NOT NULL,
    Cognome             varchar(45)     NOT NULL,
    Data_di_Nascita     date            NOT NULL,
    Email               varchar(100)    NOT NULL,
    Stipendio           DECIMAL(8,2)    NOT NULL,
    Nr_Telefono         bigint             NOT NULL,
    Nr_Patenta          int,
    Sede                VARCHAR(30) NOT NULL,
    Sede_Responsabilita VARCHAR(30),
    FOREIGN KEY (Sede) REFERENCES Sede(Citta) ON DELETE CASCADE,
    FOREIGN KEY (Sede_Responsabilita) REFERENCES Sede(Citta) ON DELETE SET NULL
);

CREATE TABLE Oggetto_di_Noleggio (
    Targa               text            PRIMARY KEY,
    Tipo                CHAR(10)        NOT NULL,
    Batteria            Int,
    Data_Acquisizione   DATE            NOT NULL,
    Prezzo_Iniziale     DECIMAL(8,2)    NOT NULL,
    Sede                VARCHAR(30),     
    FOREIGN KEY (Sede) REFERENCES Sede(Citta) ON DELETE SET NULL,
    CHECK((Tipo = 'BiciElett' AND Batteria IS NOT NULL) OR (Tipo = 'Scooter' AND Batteria IS NOT NULL) OR (Tipo = 'BiciNormle' AND Batteria IS NULL))
);

CREATE TABLE Noleggio_Passato (
    ID                  INT             PRIMARY KEY,
    Data_Ora_Consegnata TIMESTAMP        NOT NULL,
    Posizione_Consegnata VARCHAR(100)   NOT NULL,
    Data_Ora_Preso      TIMESTAMP        NOT NULL,
    Posizione_Presa     VARCHAR(100)    NOT NULL,
    Comment             VARCHAR(500),
    Matricola           INT NOT NULL, 
    Targa               text NOT NULL,
    FOREIGN KEY (Matricola) REFERENCES Cliente(Matricola) ON DELETE CASCADE,
    FOREIGN KEY (Targa) REFERENCES Oggetto_di_Noleggio(Targa) ON DELETE CASCADE 
);

CREATE TABLE Noleggio_Presente (
    ID                  INT             PRIMARY KEY,
    Data_Ora_Preso      TIMESTAMP        NOT NULL,
    Posizione_Presa     VARCHAR(100)    NOT NULL,
    Matricola           INT NOT NULL, 
    Targa               text NOT NULL,
    FOREIGN KEY (Matricola) REFERENCES Cliente(Matricola) ON DELETE CASCADE,
    FOREIGN KEY (Targa) REFERENCES Oggetto_di_Noleggio(Targa) ON DELETE CASCADE
);



CREATE TABLE Manutenzione (
    Data_Ora            TIMESTAMP        NOT NULL,
    Targa               text            NOT NULL, 
    Matricola           INT        NOT NULL, 
    Prezzo              DECIMAL(5,2),
    PRIMARY KEY(Data_Ora, Targa, Matricola),
    FOREIGN KEY (Targa) REFERENCES Oggetto_di_Noleggio(Targa) ON DELETE CASCADE,  
    FOREIGN KEY (Matricola) REFERENCES Impiegato(Matricola) ON DELETE CASCADE
);

CREATE TABLE Caricamento (
    Data_Ora            TIMESTAMP        NOT NULL,
    Targa               text            NOT NULL,
    Matricola           INT        NOT NULL,
    Ricompensa          DECIMAL(5,2),
    PRIMARY KEY(Data_Ora, Targa, Matricola), 
    FOREIGN KEY (Targa) REFERENCES Oggetto_di_Noleggio(Targa) ON DELETE CASCADE,  
    FOREIGN KEY (Matricola) REFERENCES Impiegato(Matricola) ON DELETE CASCADE
);

CREATE TABLE Ufficio (
    Indirizio           VARCHAR(40)     PRIMARY KEY,
    Piano               INT             NOT NULL,
    Circonferenza       DECIMAL(6,3)    NOT NULL,
    Affitto             DECIMAL(7,2)    NOT NULL,
    Data_Acquisizione   DATE            NOT NULL,
    Prezzo_Iniziale     DECIMAL(8,2)    NOT NULL,
    Sede                VARCHAR(30),     
    FOREIGN KEY (Sede) REFERENCES Sede(Citta) ON DELETE CASCADE
);

CREATE TABLE Veicolo (
    Targa               text            PRIMARY KEY,
    Nome                VARCHAR(50)     NOT NULL,
    Data_di_Revisione   DATE            NOT NULL,
    Data_Acquisizione   DATE            NOT NULL,
    Prezzo_Iniziale     DECIMAL(8,2)    NOT NULL,
    Sede                VARCHAR(30),
    FOREIGN KEY (Sede) REFERENCES Sede(Citta) ON DELETE SET NULL
);

DROP view if exists carsede;
Drop view if exists tottal;
DROP VIEW  IF EXists oggettopas;
DROP VIEW  if exists oggettopres;


CREATE VIEW OggettoPas AS
SELECT  o.targa , np.matricola, o.sede
FROM  noleggio_passato NP FULL JOIN oggetto_di_noleggio O
ON o.targa = np.targa 
;

CREATE VIEW OggettoPres AS
SELECT  o.targa , ns.matricola, o.sede
FROM  noleggio_presente Ns FULL JOIN oggetto_di_noleggio O
ON o.targa = ns.targa
;

CREATE VIEW Tottal AS
select s.citta, o.targa, o.matricola from oggettopas O RIght join sede S on o.sede = s.citta
union all
select s.citta, o.targa, o.matricola from oggettopres O right join sede S on o.sede = s.citta
;

CREATE view carsede AS
SELECT v.targa, v.nome, s.citta, v.sede
FROM veicolo V, sede s
WHERE v.sede = s.citta
;

CREATE INDEX Posizione_Presente ON noleggio_presente(posizione_presa);
CREATE INDEX Posizione_Lasciato ON noleggio_passato(posizione_consegnata);

insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (1, 'Nerta', 'Brewers', '24-02-1988', 'nbrewers0@nature.com', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (2, 'Tammie', 'Elvey', '17-12-1988', 'telvey1@meetup.com', 'Base', null,    null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (3, 'Alexis', 'Russell', '13-05-1998', 'arussell2@go.com', 'Premium', 19.9,   '07-06-2021', '03-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (4, 'Shanie', 'Conew', '27-09-1987', 'sconew3@google.fr', 'Premium', 19.9,    '23-05-2021', '16-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (5, 'Tim', 'Vasnetsov', '14-11-1975', 'tvasnetsov4@slate.com', 'Base', null,  null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (6, 'Serge', 'Bourdel', '21-12-1995', 'sbourdel5@hubpages.com', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (7, 'Bendix', 'McBeth', '24-02-1984', 'bmcbeth6@unesco.org', 'Base', null,  null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (8, 'Merle', 'O'' Meara', '20-04-1982', 'momeara7@surveymonkey.com', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (9, 'Alexi', 'Pynner', '03-12-1982', 'apynner8@canalblog.com', 'Premium', 19.9,      '11-02-2021', '22-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (10, 'Robbin', 'Durtnell', '21-10-1978', 'rdurtnell9@lulu.com', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (11, 'Arabela', 'Cottesford', '11-01-1989', 'acottesforda@google.com.au', 'Premium', 19.9, '30-04-2021', '02-08-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (12, 'Dav', 'Tinston', '13-08-1984', 'dtinstonb@istockphoto.com', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (13, 'Angie', 'Greenig', '05-03-1981', 'agreenigc@mail.ru', 'Premium', 19.9,    '05-05-2021', '29-07-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (14, 'Bernita', 'Rafferty', '26-01-1995', 'braffertyd@skype.com', 'Base', null,  null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (15, 'Carce', 'Deverick', '23-10-1980', 'cdevericke@google.com.hk', 'Base', null,  null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (16, 'Malcolm', 'Balser', '07-04-1990', 'mbalserf@a8.net', 'Base', null,     null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (17, 'Mord', 'Lanfranchi', '12-12-1997', 'mlanfranchig@latimes.com', 'Premium', 19.9,      '29-06-2021', '04-08-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (18, 'Alberta', 'Axelby', '06-01-1993', 'aaxelbyh@biblegateway.com', 'Premium', 19.9,      '15-01-2021', '18-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (19, 'Angy', 'Rigge', '20-06-1985', 'ariggei@miibeian.gov.cn', 'Premium', 19.9,      '13-06-2021', '14-09-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (20, 'Kata', 'Iacovacci', '02-05-1994', 'kiacovaccij@goo.ne.jp', 'Premium', 19.9,          '05-03-2021', '12-12-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (21, 'Cyndy', 'Wolfindale', '27-01-1976', 'cwolfindalek@blogspot.com', 'Premium', 19.9,    '06-02-2021', '18-09-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (22, 'Felicia', 'Matyashev', '16-09-1983', 'fmatyashevl@fda.gov', 'Premium', 19.9,         '10-02-2021', '24-12-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (23, 'Geoffry', 'Brownill', '24-07-1985', 'gbrownillm@go.com', 'Base', null, null, null,   1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (24, 'Dedie', 'Anscott', '22-03-1985', 'danscottn@jimdo.com', 'Premium', 19.9,    '11-02-2021', '31-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (25, 'Daryle', 'Rofe', '02-01-1981', 'drofeo@java.com', 'Base', null,            null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (26, 'Lauritz', 'McIlwaine', '10-09-1973', 'lmcilwainep@europa.eu', 'Base', null,null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (27, 'Nelia', 'De Witt', '29-10-1971', 'ndewittq@e-recht24.de', 'Premium', 19.9,           '24-02-2021', '04-11-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (28, 'Riley', 'Jiruca', '07-10-1977', 'rjirucar@upenn.edu', 'Base', null,       null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (29, 'Kariotta', 'Poulglais', '22-08-1976', 'kpoulglaiss@topsy.com', 'Base', null,null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (30, 'Ingmar', 'McPake', '01-06-1979', 'imcpaket@hubpages.com', 'Premium', 19.9,           '26-05-2021', '10-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (31, 'Joey', 'Emlin', '03-02-1979', 'jemlinu@eepurl.com', 'Premium', 19.9,           '07-06-2021', '13-12-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (32, 'Sven', 'Rosedale', '09-09-1979', 'srosedalev@moonfruit.com', 'Base', null,        null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (33, 'Kamillah', 'Kennet', '03-10-1975', 'kkennetw@storify.com', 'Premium', 19.9,          '13-06-2021', '10-10-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (34, 'Erskine', 'Audenis', '07-08-1974', 'eaudenisx@ebay.com', 'Base', null,  null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (35, 'Ulrikaumeko', 'Croce', '06-12-1997', 'ucrocey@twitter.com', 'Premium', 19.9,         '02-01-2021', '22-08-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (36, 'Cathrine', 'Mosdell', '14-12-1974', 'cmosdellz@opera.com', 'Base', null,   null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (37, 'Anatollo', 'Hearon', '01-11-1983', 'ahearon10@yellowpages.com', 'Premium', 19.9,     '28-01-2021', '01-08-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (38, 'Rheba', 'Borrowman', '15-07-1970', 'rborrowman11@dyndns.org', 'Base', null, null, null, 1.5);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (39, 'Barney', 'Pyner', '12-09-1978', 'bpyner12@privacy.gov.au', 'Premium', 19.9,     '22-01-2021', '30-12-2022', null);
insert into Cliente (matricola, nome, cognome, data_di_nascita, email, tipo, rata_mensile, data_iscrizione, data_fine_iscrizione, rata) values (40, 'Arlen', 'Gymlett', '23-02-1998', 'agymlett13@umich.edu', 'Base', null,   null, null, 1.5);

insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (1, 'Account', null, null, null, null, 'ofitchew0@amazonaws.com', 12);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (2, 'Account', null, null, null, null, 'gkeyden1@exblog.jp', 9);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (3, 'Carta', 5007662506195725, 'Ringo Cotgrove', 412, '05-04-2028', null, 32);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (4, 'Carta', 5010123039551541, 'Dora Breddy', 628, '14-01-2022', null, 33);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (5, 'Account', null, null, null, null, 'gvigers4@ucsd.edu', 9);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (6, 'Account', null, null, null, null, 'sjoret5@phoca.cz', 7);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (7, 'Account', null, null, null, null, 'bguiel6@hubpages.com', 2);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (8, 'Account', null, null, null, null, 'sbransom7@vkontakte.ru', 10);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (9, 'Account', null, null, null, null, 'spinson8@time.com', 36);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (10, 'Carta', 3568549980823524, 'Casey Clarkin', 610, '09-04-2029', null, 4);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (11, 'Account', null, null, null, null, 'lstienhama@state.tx.us', 29);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (12, 'Account', null, null, null, null, 'saliboneb@wiley.com', 10);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (13, 'Account', null, null, null, null, 'zivanichevc@psu.edu', 13);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (14, 'Carta', 5038900641220971, 'Thorn Scalia', 857, '18-02-2029', null, 3);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (15, 'Account', null, null, null, null, 'tmeddowse@feedburner.com', 38);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (16, 'Carta', 5108758139317120, 'Estrella Tebbs', 491, '26-10-2024', null, 13);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (17, 'Account', null, null, null, null, 'dseedsg@tripadvisor.com', 11);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (18, 'Carta', 5038315357087730, 'Mehetabel Driscoll', 458, '24-12-2028', null, 32);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (19, 'Account', null, null, null, null, 'lgammeli@webeden.co.uk', 32);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (20, 'Carta', 4175005826884934, 'Cherye Wilcott', 226, '03-06-2022', null, 11);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (21, 'Account', null, null, null, null, 'aalessandrettik@cornell.edu', 32);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (22, 'Carta', 6331106427748518520, 'Mab Ranscombe', 528, '29-06-2021', null, 8);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (23, 'Account', null, null, null, null, 'equadrim@w3.org', 36);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (24, 'Carta', 3578295184440537, 'Kimberli Killigrew', 661, '12-04-2026', null, 15);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (25, 'Carta', 4017956960632160, 'Ashlen Campione', 978, '15-09-2022', null, 17);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (26, 'Account', null, null, null, null, 'tdyballp@loc.gov', 5);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (27, 'Carta', 201866779548750, 'Theodor Crispe', 175, '21-10-2027', null, 21);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (28, 'Account', null, null, null, null, 'mbonhillr@spiegel.de', 2);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (29, 'Carta', 3568572863922403, 'Adiana Bore', 854, '10-05-2027', null, 24);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (30, 'Account', null, null, null, null, 'dthoriust@about.com', 33);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (31, 'Carta', 3530729250777379, 'Meredith Ardy', 110, '04-12-2023', null, 36);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (32, 'Account', null, null, null, null, 'kstallybrassv@ft.com', 5);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (33, 'Account', null, null, null, null, 'mwerndlyw@dailymail.co.uk', 26);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (34, 'Account', null, null, null, null, 'ajakoviljevicx@trellian.com', 6);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (35, 'Account', null, null, null, null, 'bsiggeey@t.co', 12);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (36, 'Carta', 6393533983029168, 'Dix Bettenay', 155, '23-04-2028', null, 33);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (37, 'Carta', 3549829727332706, 'Remy Tittershill', 316, '21-12-2021', null, 39);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (38, 'Carta', 3559627574245071, 'Abagael Bonnin', 372, '21-04-2028', null, 25);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (39, 'Account', null, null, null, null, 'sbonafant12@tinypic.com', 12);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (40, 'Carta', 3529847027144161, 'Aurore Edgeon', 377, '15-01-2029', null, 5);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (41, 'Account', null, null, null, null, 'gdoull14@etsy.com', 4);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (42, 'Account', null, null, null, null, 'ccranton15@dailymail.co.uk', 7);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (43, 'Account', null, null, null, null, 'teast16@ebay.co.uk', 33);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (44, 'Account', null, null, null, null, 'rstate17@vinaora.com', 12);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (45, 'Account', null, null, null, null, 'iformby18@tmall.com', 14);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (46, 'Carta', 633463013074480246, 'Grayce MacSkeagan', 939, '04-08-2025', null, 22);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (47, 'Carta', 3571498327605027, 'Caddric Devereu', 245, '10-05-2023', null, 5);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (48, 'Carta', 4405963295227799, 'Eleanore Mityukov', 435, '26-07-2028', null, 10);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (49, 'Carta', 4936700804468284, 'Dana Longmead', 871, '05-10-2026', null, 32);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (50, 'Account', null, null, null, null, 'rtigner1d@google.nl', 9);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (51, 'Carta', '3529720285528153', 'Gerrard Wynch', 625, '24-12-2027', null, 36);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (52, 'Account', null, null, null, null, 'tformoy1f@phpbb.com', 28);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (53, 'Carta', 3557040414816204, 'Geoffrey Alves', 861, '31-01-2026', null, 34);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (54, 'Carta', 490522925373363290, 'Hartley Kingescot', 467, '18-05-2028', null, 3);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (55, 'Account', null, null, null, null, 'dgarling1i@deliciousdays.com', 17);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (56, 'Account', null, null, null, null, 'bbichener1j@sciencedaily.com', 24);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (57, 'Account', null, null, null, null, 'vhutson1k@independent.co.uk', 26);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (58, 'Account', null, null, null, null, 'mlowman1l@eepurl.com', 30);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (59, 'Account', null, null, null, null, 'whaigh1m@wikia.com', 33);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (60, 'Carta', 3587969524656502, 'Risa Lawtey', 833, '14-11-2021', null, 40);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (61, 'Carta', 6371983000994702, 'Nettle Mauser', 773, '17-12-2026', null, 14);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (62, 'Account', null, null, null, null, 'cgarn1p@rakuten.co.jp', 8);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (63, 'Carta', 3528600610653523, 'Faythe Goadsby', 985, '27-01-2027', null, 4);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (64, 'Carta', 3557638377637689, 'Witty Rostron', 945, '23-01-2025', null, 16);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (65, 'Carta', 675980057853331885, 'Mabel Rohfsen', 866, '31-12-2026', null, 22);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (66, 'Carta', 3577743139899126, 'Cosmo Banford', 526, '09-02-2026', null, 40);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (67, 'Account', null, null, null, null, 'nduns1u@google.co.jp', 24);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (68, 'Carta', 6762574144213719595, 'Othilie McCart', 431, '15-02-2027', null, 26);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (69, 'Carta', 3588378295822344, 'Jenilee Tramel', 291, '09-09-2022', null, 30);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (70, 'Carta', 5020888023269775, 'Desmond Zieme', 215, '01-05-2022', null, 1);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (71, 'Account', null, null, null, null, 'cnangle1y@blogger.com', 4);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (72, 'Carta', 5277453755086234, 'Aloysius Calwell', 157, '18-12-2027', null, 21);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (73, 'Carta', 4175003427856880, 'Loralie Djordjevic', 533, '08-04-2028', null, 17);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (74, 'Account', null, null, null, null, 'lpancast21@usda.gov', 22);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (75, 'Carta', 5602246438016867, 'Nonna Hannay', 987, '29-01-2029', null, 5);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (76, 'Carta', 5602244369374876, 'Isobel Planque', 495, '07-02-2028', null, 4);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (77, 'Carta', 3577577838373052, 'Ruthi Wendover', 760, '02-07-2024', null, 14);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (78, 'Carta', 5100142602494310, 'Adah Hand', 545, '02-04-2025', null, 18);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (79, 'Carta', 5048371698962733, 'Maryanne Yannikov', 794, '19-04-2022', null, 7);
insert into Metodo_di_Pagamento (id, tipo, numero, nome_cognome, nr_sicurezza, data_di_scadenza, email, matricola) values (80, 'Carta', 3547059590533238, 'Ravid Blindt', 821, '03-07-2027', null, 40);

INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Qinglin',332939,806689);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Gaopi',235615,598257);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Troyes',973497,129771);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Gaspar',226980,199384);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Santa Rosa de Viterbo',190557,622462);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Culeng',228195,333160);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Tomiya',210444,178330);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Shidong',362308,212223);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Bosanski Brod',119882,66220);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Pitkyaranta',15978,668345);
INSERT INTO sede(citta,spesa_annuale,reddito_anno_passato) VALUES ('Stockholm',990864,975107);


insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (1, 'Bethina', 'Siney', '17-09-1975', 'bsiney0@disqus.com', 2427, 331585351319, null, 'Stockholm', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (2, 'Mersey', 'Aylett', '28-05-1989', 'maylett1@1und1.de', 3381, 335718155716, 114283, 'Troyes', 'Troyes');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (3, 'Barry', 'Wixey', '04-10-1987', 'bwixey2@bbb.org', 6360, 334663190449, 904054, 'Troyes', 'Troyes');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (4, 'Heall', 'Mault', '05-04-1995', 'hmault3@google.com.hk', 8282, 334848005492, 234189, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (5, 'Fredek', 'Bussen', '12-07-1972', 'fbussen4@sourceforge.net', 9417, 332700818269, null, 'Stockholm', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (6, 'Merrielle', 'Needs', '13-03-1975', 'mneeds5@163.com', 7577, 337612921371, 742677, 'Qinglin', 'Qinglin');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (7, 'Cyndy', 'Richly', '15-02-1980', 'crichly6@edublogs.org', 2304, 330934054253, 725107, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (8, 'Michelina', 'McNeilly', '17-10-1990', 'mmcneilly7@biblegateway.com', 2566, 333608852867, null, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (9, 'Vallie', 'Kimbury', '21-09-1984', 'vkimbury8@wix.com', 5934, 335106388298, null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (10, 'Marabel', 'Keoghane', '03-07-1991', 'mkeoghane9@w3.org', 6400, 335853383560, null, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (11, 'Abbot', 'Wakelam', '14-10-1986', 'awakelama@bandcamp.com', 7987, 334438807126, 123105, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (12, 'Hayley', 'Selley', '19-04-1991', 'hselleyb@stumbleupon.com', 7142, 335522699658, 990589, 'Shidong', 'Shidong');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (13, 'Gusella', 'Pepon', '25-06-1990', 'gpeponc@slate.com', 2318, 330292015780, 426224, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (14, 'Seward', 'Isbell', '06-03-1992', 'sisbelld@ameblo.jp', 3490, 335094754467, 458070, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (15, 'Jason', 'Cammoile', '22-03-1987', 'jcammoilee@themeforest.net', 4042, 336583784146, 871363, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (16, 'Rodi', 'Dunnett', '07-06-1977', 'rdunnettf@marriott.com', 3883, 333101345248, null, 'Tomiya', 'Tomiya');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (17, 'Charmian', 'Graveston', '20-05-1998', 'cgravestong@cdc.gov', 7921, 339003084174, 263708, 'Gaopi', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (18, 'Sonnnie', 'Baxstare', '21-07-1979', 'sbaxstareh@intel.com', 1504, 334041550239, 816766, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (19, 'Tully', 'Boland', '03-03-1988', 'tbolandi@ihg.com', 6705, 336388351121, 493588, 'Tomiya', 'Tomiya');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (20, 'Nissie', 'Ockleshaw', '02-04-2000', 'nockleshawj@prlog.org', 2684, 339841170927, 523189, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (21, 'Tobi', 'Halwood', '04-10-1983', 'thalwoodk@de.vu', 7296, 338936553450, null, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (22, 'Dacia', 'Keen', '23-07-1991', 'dkeenl@ibm.com', 5620, 331700212151, 123988, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (23, 'Alvina', 'Cowtherd', '17-07-1995', 'acowtherdm@ustream.tv', 9279, 339497433589, null, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (24, 'Sallie', 'Kinsey', '18-11-1980', 'skinseyn@gnu.org', 6787, 331730832228, 241374, 'Gaopi', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (25, 'Jaime', 'Ferreira', '27-10-1984', 'jferreirao@squidoo.com', 3967, 339230443176, 384522, 'Pitkyaranta', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (26, 'Murdoch', 'Hauxley', '09-08-1989', 'mhauxleyp@angelfire.com', 6046, 335619013203, null, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (27, 'Orson', 'Hawkeridge', '18-04-2000', 'ohawkeridgeq@nature.com', 2897, 337732738514, 197402, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (28, 'Joellen', 'Darington', '06-05-1982', 'jdaringtonr@tinypic.com', 6720, 334819298570, 921854, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (29, 'Lemmy', 'Duigenan', '28-08-1992', 'lduigenans@hibu.com', 6794, 335952429583, 329471, 'Pitkyaranta', 'Pitkyaranta');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (30, 'Evin', 'Baynom', '06-06-1993', 'ebaynomt@abc.net.au', 6344, 332557499011, 466666, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (31, 'Evonne', 'Mithon', '24-09-1972', 'emithonu@aol.com', 7531, 334221483243, null, 'Stockholm', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (32, 'Rosalind', 'Doghartie', '16-09-1997', 'rdoghartiev@addthis.com', 5176, 335296037513, 144201, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (33, 'Honor', 'Saker', '22-06-1981', 'hsakerw@uiuc.edu', 9092, 333069853305, 982988, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (34, 'Eric', 'MacGall', '03-04-1989', 'emacgallx@unc.edu', 5686, 331349890817, 647745, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (35, 'Mandie', 'Dudill', '28-10-1984', 'mdudilly@intel.com', 9493, 338336892617, null, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (36, 'Neysa', 'Weddeburn', '24-05-1993', 'nweddeburnz@yahoo.com', 6037, 332168949390, 734059, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (37, 'Merrill', 'Ragate', '30-06-1973', 'mragate10@ifeng.com', 6001, 336992308866, 489884, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (38, 'Seana', 'Pedler', '15-03-1981', 'spedler11@comsenz.com', 7599, 332657441715, 406009, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (39, 'Lionel', 'Sherlaw', '22-09-1995', 'lsherlaw12@amazon.co.jp', 1415, 339606288423, null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (40, 'Tiler', 'Becaris', '29-12-1986', 'tbecaris13@linkedin.com', 3726, 332982573853, 318068, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (41, 'Chloette', 'Sell', '24-12-1980', 'csell14@pinterest.com', 6207, 331865486111, null, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (42, 'Georas', 'Hardwidge', '15-10-1975', 'ghardwidge15@google.de', 2750, 330123466636, 433066, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (43, 'Yorker', 'Lanigan', '02-02-1984', 'ylanigan16@example.com', 4890, 331577787508, 817557, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (44, 'Emile', 'Aimson', '03-10-1977', 'eaimson17@multiply.com', 8597, 336274904812, null, 'Troyes', 'Qinglin');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (45, 'Star', 'Hallaways', '05-06-1972', 'shallaways18@jimdo.com', 5358, 332909320348, 529587, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (46, 'Oriana', 'Harroway', '27-04-1992', 'oharroway19@cisco.com', 5909, 330355892486, 695714, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (47, 'Eugenia', 'Yakovliv', '28-05-1993', 'eyakovliv1a@people.com.cn', 6898, 339885823433, 324882, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (48, 'Caleb', 'Visco', '31-01-1975', 'cvisco1b@amazon.com', 7967, 334838819382, 149314, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (49, 'Karl', 'Purshouse', '28-03-1979', 'kpurshouse1c@goo.ne.jp', 8669, 337863176423, null, 'Gaopi', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (50, 'Heindrick', 'Lexa', '09-06-1988', 'hlexa1d@dmoz.org', 5332, 332727393377, 651935, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (51, 'Jennilee', 'Dillingston', '07-07-1973', 'jdillingston1e@ihg.com', 1685, 331317531809, 955711, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (52, 'Karita', 'Hawarden', '10-01-1984', 'khawarden1f@oracle.com', 6487, 335273362365, null, 'Culeng', 'Culeng');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (53, 'Eustace', 'Donett', '07-04-1995', 'edonett1g@furl.net', 7075, 339394328672, 759245, 'Stockholm', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (54, 'Alfred', 'Daber', '28-01-1990', 'adaber1h@elpais.com', 7207, 335704662149, 888740, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (55, 'Eryn', 'Mowlam', '01-05-1989', 'emowlam1i@hibu.com', 5318, 336652142430, 975282, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (56, 'Mirelle', 'Crossthwaite', '18-02-1990', 'mcrossthwaite1j@youtu.be', 3250, 336155487513, 473495, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (57, 'Khalil', 'Coxwell', '27-05-1996', 'kcoxwell1k@google.com.hk', 5948, 332424688258, null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (58, 'Ailbert', 'Pawlaczyk', '10-08-1991', 'apawlaczyk1l@yahoo.com', 8329, 333376296059, 850071, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (59, 'Chas', 'Barthelemy', '12-09-1992', 'cbarthelemy1m@chronoengine.com', 1851, 339837386325, 794131, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (60, 'Aile', 'Swayne', '30-04-1998', 'aswayne1n@foxnews.com', 8879, 330148414150, 782416, 'Pitkyaranta', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (61, 'Catina', 'Rawlins', '07-03-1980', 'crawlins1o@dailymotion.com', 2255, 330646507697, null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (62, 'Moishe', 'Gilbride', '29-11-1992', 'mgilbride1p@xrea.com', 4025, 331484701569, 887043, 'Shidong', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (63, 'Deeanne', 'Andreu', '10-05-1988', 'dandreu1q@marketwatch.com', 9501, 335818482488, 529520, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (64, 'Bartram', 'Watters', '13-05-1972', 'bwatters1r@prlog.org', 2221, 330366997723, 590084, 'Culeng', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (65, 'Tailor', 'Rollingson', '22-09-1974', 'trollingson1s@zimbio.com', 7222, 339720271154,  null, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (66, 'Stefania', 'Backwell', '15-04-1993', 'sbackwell1t@disqus.com', 4466, 333502241840, 129298, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (67, 'Anastassia', 'O''Doohaine', '26-03-1992', 'aodoohaine1u@altervista.org', 3928, 335016067787, 248767, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (68, 'Dena', 'MacKee', '30-05-1973', 'dmackee1v@slashdot.org', 4413, 331626149850, 611990, 'Stockholm', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (69, 'Lindsay', 'O''Carmody', '24-01-1988', 'locarmody1w@sfgate.com', 2395, 333077135211,  null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (70, 'Merwyn', 'Harlow', '19-01-1975', 'mharlow1x@ezinearticles.com', 6871, 339284609965, 410395, 'Troyes', 'Troyes');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (71, 'Northrup', 'Ring', '23-10-1978', 'nring1y@mysql.com', 2985, 337507805297, 847868, 'Gaspar', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (72, 'Renard', 'Legg', '26-10-1981', 'rlegg1z@nbcnews.com', 3890, 337519403902, 533631, 'Troyes', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (73, 'Lutero', 'Killelea', '10-03-1997', 'lkillelea20@privacy.gov.au', 9067, 338808626909,  null, 'Tomiya', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (74, 'Ann', 'Sarch', '02-05-1978', 'asarch21@biglobe.ne.jp', 1682, 330988258781, 552288, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (75, 'Ainslie', 'Sexty', '20-11-1991', 'asexty22@chicagotribune.com', 6871, 335567568795, 389499, 'Santa Rosa de Viterbo', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (76, 'Lucias', 'Wheelwright', '25-01-1981', 'lwheelwright23@amazonaws.com', 6571, 334074826631, 262900, 'Qinglin', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (77, 'Mela', 'Spaunton', '22-05-1990', 'mspaunton24@ameblo.jp', 9998, 339547748288, 199852, 'Santa Rosa de Viterbo', 'Santa Rosa de Viterbo');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (78, 'Windy', 'Coumbe', '06-02-1982', 'wcoumbe25@washingtonpost.com', 9836, 335025742277, null, 'Bosanski Brod', null);
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (79, 'Shanan', 'Drynan', '09-06-1993', 'sdrynan26@flavors.me', 5755, 330467378996, null, 'Culeng', 'Culeng');
insert into impiegato (matricola, nome, cognome, data_di_nascita, email, stipendio, nr_telefono, nr_patenta, sede, sede_responsabilita) values (80, 'Miriam', 'Pedlow', '24-02-1992', 'mpedlow27@vk.com', 9586, 335788281999,  null, 'Culeng', null);



insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('2B3CA7CW0AH406958', 'BiciNormle', null, '02-01-2004', 425, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('2HNYD2H82DH704192', 'BiciNormle', null, '11-08-2004', 933, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('JTMHY7AJ7D4802894', 'Scooter', 67, '13-03-2002', 603, 'Culeng');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('3C3CFFJH4DT807573', 'BiciElett', 65, '17-11-2003', 856, 'Gaspar');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WA1DGAFP8FA598276', 'BiciElett', 8, '08-09-2001', 903, 'Troyes');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GYS4CEF1ER030942', 'Scooter', 76, '29-10-2004', 972, 'Pitkyaranta');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G6DM1ED1B0807589', 'BiciElett', 14, '04-06-2000', 292, 'Culeng');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FTSW2A5XAE108933', 'BiciElett', 3, '16-06-2003', 688, 'Qinglin');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GYUKJEF3AR142879', 'Scooter', 12, '10-01-2002', 995, 'Culeng');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('JN8AZ2NC6D9680887', 'Scooter', 55, '02-07-2000', 834, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FTSW2A52AE822314', 'BiciNormle', null, '02-04-2004', 768, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GYS4HKJ2FR124299', 'Scooter', 85, '12-09-2003', 124, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FTSX2B51AE200587', 'Scooter', 62, '25-12-2000', 456, 'Gaopi');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAULC68E95A271869', 'BiciNormle', null, '14-07-2003', 780, 'Shidong');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('3GYFNGE3XFS929972', 'BiciNormle', null, '12-04-2002', 214, 'Shidong');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1D4PT6GX2AW619664', 'Scooter', 34, '07-02-2005', 650, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('TRUUT28N841944123', 'Scooter', 16, '30-07-2004', 682, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUYGAFC0CN160616', 'BiciElett', 100, '18-06-2004', 776, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FTEX1CV0AF625668', 'BiciNormle', null, '11-11-2002', 356, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('YV426MDA5F2575139', 'BiciElett', 88, '20-02-2004', 424, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FTWX3A52AE836217', 'Scooter', 11, '15-05-2001', 799, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('3D7TP2CT4BG196166', 'Scooter', 51, '02-10-2003', 870, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WBAHN03508D237732', 'BiciElett', 94, '26-11-2002', 364, 'Gaopi');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('19UUA65694A248795', 'BiciElett', 19, '16-04-2005', 803, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('2FMHK6DC3AB818190', 'BiciElett', 77, '07-08-2004', 218, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('JN8AE2KP6B9488627', 'Scooter', 56, '30-06-2001', 246, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('JM1NC2LF3E0992294', 'Scooter', 70, '05-03-2001', 249, 'Pitkyaranta');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GYEK63N23R667527', 'BiciElett', 49, '22-04-2001', 521, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUDG94F95N449099', 'Scooter', 20, '15-03-2005', 120, 'Culeng');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('19UUA8F52CA671749', 'BiciNormle', null, '13-02-2002', 487, 'Tomiya');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G4HP52K45U851496', 'BiciElett', 52, '20-06-2002', 794, 'Tomiya');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G6KF54983U154663', 'Scooter', 35, '17-11-2002', 267, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1HGCP2E37CA233591', 'BiciNormle', null, '23-08-2000', 317, 'Shidong');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUR2AFDXEN404156', 'Scooter', 65, '28-10-2002', 848, 'Gaspar');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUVC68E55A375736', 'Scooter', 80, '20-04-2002', 144, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUBH74F56N653795', 'BiciElett', 64, '19-04-2001', 846, 'Pitkyaranta');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUTFAFH0BN309050', 'BiciNormle', null, '27-04-2002', 766, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WDDGF4HB4EA013237', 'BiciElett', 9, '26-08-2000', 848, 'Pitkyaranta');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAU4FAFR3AA892474', 'Scooter', 6, '26-06-2002', 140, 'Qinglin');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1N6AF0LX9FN775014', 'BiciElett', 70, '26-04-2001', 347, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUNF78P98A256221', 'BiciElett', 52, '20-07-2000', 692, 'Bosanski Brod');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G6DK5ED9B0704336', 'BiciElett', 86, '11-09-2002', 831, 'Gaspar');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1FT7W2A63EE613622', 'Scooter', 26, '21-03-2002', 250, 'Shidong');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WVWAN7AN0DE340931', 'BiciNormle', null, '15-04-2003', 475, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('19UUA9F53DA560988', 'BiciElett', 37, '21-08-2003', 511, 'Troyes');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WBA3A5C54CF000404', 'BiciElett', 0, '07-08-2003', 113, 'Troyes');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUMR44E76N753635', 'Scooter', 24, '16-02-2005', 660, 'Gaspar');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUVFAFH7DN358841', 'BiciElett', 34, '03-12-2001', 886, 'Shidong');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1D7RB1CP9AS114039', 'BiciNormle', null, '23-01-2005', 249, 'Gaopi');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G4HF57938U576474', 'BiciElett', 9, '23-01-2002', 387, 'Gaopi');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUMF78PX6A787288', 'Scooter', 53, '27-11-2001', 653, 'Stockholm');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GD11XEG5FF899164', 'BiciElett', 35, '11-07-2000', 154, 'Qinglin');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('3MZBM1U75EM626848', 'BiciElett', 2, '01-08-2000', 827, 'Gaspar');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1GKS1GEJ1DR774361', 'BiciNormle', null, '14-11-2001', 471, 'Qinglin');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAUCFAFH6AN421950', 'Scooter', 87, '29-04-2004', 429, 'Troyes');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1N4AL2AP7CN271928', 'Scooter', 8, '11-06-2000', 366, 'Santa Rosa de Viterbo');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G6DP577250604897', 'BiciElett', 29, '22-05-2004', 979, 'Qinglin');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('W04G05GVXB1325680', 'BiciElett', 61, '27-12-2003', 408, 'Tomiya');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('1G6DX67D570710095', 'BiciNormle', null, '22-05-2002', 562, 'Culeng');
insert into Oggetto_di_Noleggio (targa, tipo, batteria, data_acquisizione, prezzo_iniziale, sede) values ('WAULC58E75A203886', 'BiciNormle', null, '01-09-2003', 892, 'Qinglin');

insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('2 Golf View Center', 1, 95, 885, '10-08-2002', 814, 'Gaopi');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('19169 Del Sol Avenue', 0, 53, 2872, '23-10-2001', 1836, 'Troyes');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('31021 Sage Point', 5, 74, 2542, '31-12-2004', 1233, 'Gaspar');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('2999 Clove Street', 5, 50, 3374, '17-05-2002', 3487, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('153 Mosinee Trail', 4, 98, 678, '29-10-2003', 3132, 'Bosanski Brod');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('91 Fordem Street', 4, 63, 973, '06-11-2000', 3282, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('011 Dorton Place', 7, 81, 2681, '04-03-2006', 1917, 'Pitkyaranta');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('9 Norway Maple Parkway', 4, 58, 1966, '18-01-2002', 2531, 'Gaspar');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('5106 Welch Junction', 7, 100, 534, '25-10-2001', 3287, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('19193 Rowland Parkway', 6, 99, 2024, '09-02-2004', 2629, 'Bosanski Brod');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('7 Gulseth Drive', 4, 80, 2859, '13-10-2003', 1382, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('22 Main Alley', 5, 66, 2071, '02-12-2003', 2963, 'Stockholm');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('8 Quincy Plaza', 1, 63, 624, '24-07-2001', 1246, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('41 Susan Parkway', 5, 96, 2757, '11-06-2002', 2276, 'Santa Rosa de Viterbo');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('9157 Magdeline Park', 10, 94, 1780, '04-05-2001', 1438, 'Pitkyaranta');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('35 Schlimgen Center', 6, 64, 2155, '15-03-2002', 665, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('233 Debs Circle', 6, 90, 1619, '27-01-2002', 2232, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('983 Logan Road', 3, 54, 1486, '19-10-2002', 2043, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('89 Di Loreto Plaza', 7, 52, 1506, '07-11-2002', 2478, 'Gaopi');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('99355 La Follette Road', 0, 88, 933, '02-06-2001', 2463, 'Stockholm');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('863 Ohio Plaza', 7, 96, 2299, '08-04-2006', 2644, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('762 Dryden Plaza', 4, 56, 2754, '30-04-2005', 1566, 'Pitkyaranta');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('6355 American Parkway', 7, 98, 3221, '15-08-2000', 570, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('1 Grim Court', 8, 78, 1436, '11-10-2001', 1185, 'Troyes');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('79558 Blaine Point', 1, 90, 810, '02-01-2005', 1113, 'Tomiya');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('00090 Mallory Place', 4, 90, 3033, '03-03-2002', 519, 'Tomiya');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('6180 Valley Edge Hill', 10, 88, 942, '22-12-2004', 1222, 'Gaspar');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('3782 Fairview Point', 2, 69, 2547, '09-11-2004', 2885, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('634 Arkansas Court', 4, 50, 2883, '23-11-2003', 2175, 'Troyes');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('505 Northland Hill', 9, 63, 2151, '05-09-2005', 1299, 'Gaspar');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('93868 Arizona Way', 2, 89, 2349, '27-01-2003', 3360, 'Tomiya');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('36 Eastlawn Avenue', 2, 87, 2398, '12-08-2005', 2410, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('4509 Sherman Hill', 8, 86, 2675, '08-02-2002', 3460, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('6 Glacier Hill Court', 6, 60, 1772, '04-08-2000', 3018, 'Culeng');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('871 Autumn Leaf Lane', 9, 99, 2826, '05-04-2006', 1129, 'Qinglin');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('7278 Welch Center', 0, 64, 632, '11-09-2002', 2053, 'Gaopi');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('761 Del Mar Court', 10, 86, 2757, '13-10-2000', 1382, 'Santa Rosa de Viterbo');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('51 Butternut Point', 3, 73, 1786, '24-01-2001', 2048, 'Pitkyaranta');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('80 Ridge Oak Alley', 0, 90, 3475, '26-07-2005', 2263, 'Santa Rosa de Viterbo');
insert into Ufficio (indirizio, piano, circonferenza, affitto, data_acquisizione, prezzo_iniziale, sede) values ('0 Moose Park', 0, 96, 3396, '18-10-2001', 1184, 'Gaspar');

insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JN1CV6EK0CM841330', 'Chevrolet Express', '09-09-2022', '04-05-2017', 23816, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WAUKD78PX7A730233', 'Mercedes Sprinter', '19-07-2022', '28-01-2015', 15578, 'Culeng');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1GD21ZCG4DZ546929', 'Ford Transit', '25-05-2022', '08-12-2013', 17206, 'Shidong');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WDDLJ7GB9FA878366', 'Mercedes Sprinter', '22-10-2022', '02-10-2021', 28671, 'Gaspar');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('3FADP0L33BR423313', '2018 NV CARGO', '13-04-2023', '09-07-2020', 12794, 'Santa Rosa de Viterbo');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JN8AZ1MUXEW579357', 'Chevrolet Express', '19-09-2022', '24-10-2011', 33752, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WUARL48H48K307741', 'Mercedes Sprinter', '23-01-2023', '29-01-2014', 28949, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WAUNF78P78A832694', 'Ford Transit Connect', '12-04-2023', '04-01-2016', 28742, 'Santa Rosa de Viterbo');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WUAUUAFG8CN390582', 'Ford Transit', '04-05-2023', '31-10-2016', 12228, 'Culeng');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WA1WMAFE3AD033022', 'Mercedes Sprinter', '12-04-2023', '04-11-2017', 9523, 'Bosanski Brod');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBA4C9C51FD365547', 'Ford Transit Connect', '04-10-2022', '19-03-2012', 23832, 'Pitkyaranta');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WA1LFBFP1BA394238', 'Express Cargo Can', '03-07-2022', '03-04-2013', 8815, 'Stockholm');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1G4GA5ER4DF222345', 'Chevrolet Express', '13-04-2023', '19-12-2020', 32615, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JHMZF1C43CS292597', 'Express Cargo Can', '30-04-2023', '03-12-2013', 20308, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBA5M4C58FD134231', 'Dodge Ram ProMaster', '28-08-2022', '02-09-2021', 14410, 'Tomiya');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('KL4CJHSB8EB164917', 'Ford Transit Connect', '14-09-2022', '20-11-2013', 16921, 'Gaopi');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('SCFEBBBC2AG627554', 'Chevrolet Express', '15-11-2022', '21-11-2010', 11273, 'Santa Rosa de Viterbo');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBADN63471G149869', 'Mercedes Sprinter', '12-03-2023', '17-10-2018', 30972, 'Stockholm');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('5N1AN0NW3EN236554', 'Mercedes Metris', '13-05-2023', '28-10-2012', 8417, 'Bosanski Brod');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WAUGL98E38A262303', 'Chevrolet Express', '20-11-2022', '09-09-2015', 21026, 'Bosanski Brod');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JN1AY1AR9DM460646', 'Mercedes Metris', '24-04-2023', '21-03-2012', 17635, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1D4PU6GX5AW232894', 'Ford Transit Connect', '26-12-2022', '11-01-2014', 32463, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('2FMGK5BC7AB166277', '2018 NV CARGO', '04-01-2023', '04-12-2020', 12066, 'Gaspar');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('3C4PDDGG5ET985502', 'Mercedes Sprinter', '22-08-2022', '12-08-2018', 9769, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1G6AA5RA0F0964037', 'Mercedes Sprinter', '27-08-2022', '21-12-2010', 28325, 'Gaspar');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('TRUDD38J281365425', 'Chevrolet Express', '09-10-2022', '29-05-2012', 15442, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WVGAV7AX7CW809812', '2018 NV CARGO', '31-07-2022', '01-02-2021', 17367, 'Culeng');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBA5A7C55ED245120', 'Mercedes Metris', '30-06-2022', '18-03-2020', 25915, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBA3A5C59CF537320', '2018 NV CARGO', '29-09-2022', '06-06-2014', 18429, 'Gaspar');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1G6AH5R30F0419808', 'Dodge Ram ProMaster', '12-02-2023', '22-07-2014', 27059, 'Pitkyaranta');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('KMHHT6KD3AU519739', 'Chevrolet Express', '23-03-2023', '22-09-2013', 19201, 'Pitkyaranta');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('KNADH5A34B6194402', 'Mercedes Sprinter', '14-04-2023', '21-06-2016', 19482, 'Shidong');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('2T3BFREV0FW090027', 'Mercedes Metris', '24-06-2022', '18-06-2018', 9823, 'Gaspar');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBADS43401G395398', 'Mercedes Metris', '25-02-2023', '14-06-2013', 28309, 'Gaopi');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JH4DC54864S932282', 'Dodge Ram ProMaster', '09-07-2022', '04-04-2013', 33184, 'Tomiya');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('1GYS3NKJ4FR632355', '2018 NV CARGO', '17-09-2022', '29-11-2015', 29766, 'Shidong');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('WBAVD13576K259280', 'Mercedes Metris', '16-06-2022', '15-11-2018', 22215, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('VNKKTUD37FA884038', 'Mercedes Metris', '29-09-2022', '12-12-2020', 22370, 'Troyes');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('JH4KB16698C480746', '2018 NV CARGO', '27-07-2022', '29-06-2021', 14835, 'Qinglin');
insert into Veicolo (targa, nome, Data_di_Revisione, data_acquisizione, prezzo_iniziale, sede) values ('YV1622FS2C2159601', '2018 NV CARGO', '06-04-2023', '12-04-2018', 9652, 'Santa Rosa de Viterbo');


insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('04-08-2016', '1GYUKJEF3AR142879', 12, 20);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('15-01-2014', 'JTMHY7AJ7D4802894', 21, 16);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('26-10-2018', 'JTMHY7AJ7D4802894', 41, 30);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('25-06-2013', '1D7RB1CP9AS114039', 53, 26);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('18-12-2015', 'YV426MDA5F2575139', 3, 16);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('13-06-2019', 'WAUYGAFC0CN160616', 8, 17);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('20-09-2013', 'WAU4FAFR3AA892474', 74, 4);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('14-08-2013', '1N6AF0LX9FN775014', 69, 19);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('17-09-2021', '1G6KF54983U154663', 2, 28);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('11-01-2021', '3C3CFFJH4DT807573', 20, 9);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('28-06-2015', '1FTWX3A52AE836217', 16, 8);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('01-04-2019', '3MZBM1U75EM626848', 29, 5);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('28-10-2017', 'WAU4FAFR3AA892474', 40, 29);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('06-05-2014', 'WAU4FAFR3AA892474', 48, 29);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('02-06-2021', '1GYS4CEF1ER030942', 50, 2);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('15-05-2016', '1GYEK63N23R667527', 31, 29);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('12-01-2011', 'WAUDG94F95N449099', 29, 3);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('18-10-2018', '1HGCP2E37CA233591', 70, 21);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('15-01-2020', '1FTWX3A52AE836217', 61, 24);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('17-04-2016', '1FTSW2A5XAE108933', 7, 25);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('20-07-2021', 'WA1DGAFP8FA598276', 2, 27);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('13-09-2013', '1GYS4HKJ2FR124299', 78, 13);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('11-02-2018', '1FTSW2A5XAE108933', 80, 11);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('16-05-2011', '1GD11XEG5FF899164', 49, 25);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('22-09-2019', 'JN8AE2KP6B9488627', 42, 19);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('11-01-2019', '19UUA9F53DA560988', 2, 13);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('05-07-2016', '2FMHK6DC3AB818190', 16, 4);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('13-08-2019', 'WAUBH74F56N653795', 8, 6);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('27-07-2014', '3MZBM1U75EM626848', 56, 15);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('23-10-2021', 'JN8AE2KP6B9488627', 78, 2);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('26-12-2010', '3MZBM1U75EM626848', 6, 9);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('24-04-2022', 'TRUUT28N841944123', 11, 3);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('13-01-2012', '1FTWX3A52AE836217', 14, 11);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('11-06-2012', '1G4HP52K45U851496', 13, 3);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('20-11-2017', 'WAUCFAFH6AN421950', 55, 16);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('29-04-2018', 'TRUUT28N841944123', 46, 25);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('16-02-2022', 'WAUNF78P98A256221', 9, 19);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('10-12-2013', 'WBA3A5C54CF000404', 79, 24);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('02-05-2015', 'TRUUT28N841944123', 68, 9);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('07-08-2010', 'WAUMF78PX6A787288', 53, 3);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('02-01-2016', '19UUA65694A248795', 47, 2);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('13-08-2010', 'WAUNF78P98A256221', 38, 11);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('12-03-2019', '1GYS4HKJ2FR124299', 17, 11);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('03-10-2014', '19UUA9F53DA560988', 72, 9);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('16-07-2014', '1GYEK63N23R667527', 77, 18);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('22-08-2010', 'WVWAN7AN0DE340931', 23, 13);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('02-05-2013', '2HNYD2H82DH704192', 60, 13);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('01-07-2017', '1D7RB1CP9AS114039', 29, 29);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('05-02-2019', 'JM1NC2LF3E0992294', 74, 18);
insert into Manutenzione (data_ora, targa, matricola, prezzo) values ('25-09-2020', 'WAUVFAFH7DN358841', 39, 7);

insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('14-04-2013', 'WVWAN7AN0DE340931', 14, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('09-07-2011', 'WBAHN03508D237732', 43, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('01-03-2022', '1G6KF54983U154663', 79, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('01-05-2014', '1G6DM1ED1B0807589', 73, 10);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('22-04-2020', '1GD11XEG5FF899164', 7, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('13-04-2011', '3MZBM1U75EM626848', 27, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('21-12-2018', 'WAUMR44E76N753635', 11, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('05-03-2019', '19UUA9F53DA560988', 7, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('05-12-2018', '1G6DX67D570710095', 48, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('19-06-2012', '2FMHK6DC3AB818190', 4, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('21-06-2010', '1D7RB1CP9AS114039', 6, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('26-05-2019', 'JN8AE2KP6B9488627', 2, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('07-09-2013', '1G4HP52K45U851496', 19, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('03-07-2021', 'WAULC68E95A271869', 60, 10);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('06-08-2010', '2B3CA7CW0AH406958', 24, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('20-07-2020', 'WAULC58E75A203886', 72, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('26-06-2017', '2B3CA7CW0AH406958', 63, 10);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('28-02-2021', 'WBAHN03508D237732', 15, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('12-04-2017', 'WAUDG94F95N449099', 34, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('30-04-2011', '19UUA65694A248795', 33, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('02-01-2017', 'WAUMR44E76N753635', 79, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('27-08-2021', '3GYFNGE3XFS929972', 74, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('20-03-2022', 'JM1NC2LF3E0992294', 56, 10);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('27-09-2018', '1GYUKJEF3AR142879', 64, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('02-06-2011', '1G6DX67D570710095', 61, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('20-04-2017', 'JM1NC2LF3E0992294', 37, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('18-02-2021', 'WAUYGAFC0CN160616', 13, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('11-05-2015', '1GYUKJEF3AR142879', 33, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('05-01-2017', 'WAUR2AFDXEN404156', 28, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('02-10-2015', 'WAUMF78PX6A787288', 36, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('12-11-2016', '1N6AF0LX9FN775014', 14, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('09-04-2014', '1FTWX3A52AE836217', 6, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('11-01-2017', 'WA1DGAFP8FA598276', 26, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('04-01-2012', 'YV426MDA5F2575139', 15, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('29-12-2019', 'WAUVC68E55A375736', 17, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('04-02-2011', '1HGCP2E37CA233591', 75, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('28-05-2015', 'WA1DGAFP8FA598276', 47, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('04-09-2015', '1GYS4CEF1ER030942', 15, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('11-12-2012', '1FTSW2A52AE822314', 45, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('05-06-2020', 'WAUR2AFDXEN404156', 24, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('21-02-2020', 'JN8AE2KP6B9488627', 23, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('28-10-2018', '1G6DM1ED1B0807589', 62, 8);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('24-01-2017', '2FMHK6DC3AB818190', 40, 5);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('20-08-2021', '1GD11XEG5FF899164', 65, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('04-05-2016', '1GD11XEG5FF899164', 1, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('27-01-2012', '1G4HP52K45U851496', 47, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('11-11-2017', '1D7RB1CP9AS114039', 33, 9);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('27-09-2014', 'JM1NC2LF3E0992294', 28, 6);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('03-10-2013', 'JN8AZ2NC6D9680887', 52, 7);
insert into Caricamento (data_ora, targa, matricola, ricompensa) values ('01-09-2011', '1D4PT6GX2AW619664', 26, 7);

insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (1, '2021-10-26 01:07:08', '-77.0844226 - -12.0560257', 12, 'YV426MDA5F2575139');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (2, '2022-04-02 22:35:50', '128.8189471 - 35.9132087', 8, 'WA1DGAFP8FA598276');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (3, '2021-10-30 13:22:08', '107.454927 - -6.403006', 39, '1G6KF54983U154663');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (4, '2022-01-15 13:08:44', '-59.1078529 - -25.7333842', 32, '1FTSW2A52AE822314');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (5, '2021-11-30 08:11:29', '110.971573 - 30.406007', 20, '1GYS4HKJ2FR124299');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (6, '2022-02-12 02:13:27', '113.646181 - 26.879864', 26, '1FTSX2B51AE200587');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (7, '2021-12-17 04:52:59', '113.719422 - 37.57126', 11, '1GKS1GEJ1DR774361');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (8, '2022-04-12 08:17:54', '-70.5126462 - 19.2232969', 1, 'TRUUT28N841944123');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (9, '2022-01-09 16:10:15', '69.5394189 - 36.7338782', 34, 'WAUNF78P98A256221');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (10, '2021-10-05 17:27:24', '-46.5619303 - -21.7853787', 11, 'JN8AE2KP6B9488627');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (11, '2021-06-10 06:36:52', '109.44096 - 34.540852', 38, 'JM1NC2LF3E0992294');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (12, '2021-06-12 07:35:01', '100.8338593 - 14.5807588', 6, '3C3CFFJH4DT807573');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (13, '2021-08-19 05:45:47', '93.768409 - 55.7279446', 22, '1G4HP52K45U851496');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (14, '2021-12-10 17:07:17', '127.6825578 - 26.1853781', 36, '1GYS4HKJ2FR124299');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (15, '2021-10-10 20:49:05', '120.9924256 - 14.6092588', 36, 'JM1NC2LF3E0992294');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (16, '2021-09-03 23:17:51', '15.9258038 - 50.2614977', 25, '3C3CFFJH4DT807573');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (17, '2021-10-01 16:11:28', '96.5329775 - 16.7646219', 38, 'JM1NC2LF3E0992294');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (18, '2021-07-11 02:17:25', '15.3858774 - 50.9704636', 37, '1FTEX1CV0AF625668');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (19, '2021-09-28 15:43:25', '111.285799 - 35.818632', 30, 'WAUVC68E55A375736');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (20, '2021-10-12 01:24:59', '44.0177989 - 13.5775886', 30, 'JTMHY7AJ7D4802894');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (21, '2021-07-26 01:31:05', '114.0369075 - -8.557437', 2, 'YV426MDA5F2575139');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (22, '2021-07-01 08:43:41', '-97.3141928 - 20.452352', 11, 'WAUMR44E76N753635');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (23, '2021-10-12 21:36:34', '-8.6883541 - 40.6057199', 35, 'WAUR2AFDXEN404156');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (24, '2021-08-13 04:17:08', '61.3521146 - 54.8986278', 35, '2B3CA7CW0AH406958');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (25, '2021-09-16 22:16:13', '30.8274819 - 69.4326713', 10, '1GYEK63N23R667527');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (26, '2022-02-26 12:10:36', '-73.9830029 - 10.8698035', 4, 'WAUMF78PX6A787288');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (27, '2022-05-02 04:42:44', '111.1056539 - -7.4417327', 32, 'WAUTFAFH0BN309050');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (28, '2021-10-22 17:06:02', '-55.6287206 - -34.4867748', 2, '1G4HF57938U576474');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (29, '2021-06-30 16:23:03', '114.807963 - 22.839541', 16, '1GKS1GEJ1DR774361');
insert into noleggio_presente (id, data_ora_preso, posizione_presa, matricola, targa) values (30, '2022-05-18 22:04:13', '-53.05199 - -26.0779448', 39, 'WAUTFAFH0BN309050');

insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (1, '2021-09-04 14:48:57', '2021-11-08 13:21:22', '60.657365 - 53.806717', '60.657365 - 53.806717', 18, null, '1G6DK5ED9B0704336');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (2, '2021-10-03 07:02:46', '2021-10-11 17:13:52', '119.1284 - -9.566', '119.1284 - -9.566', 20, null, 'YV426MDA5F2575139');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (3, '2021-09-10 12:31:58', '2022-02-19 12:31:00', '24.6094605 - 49.9693586', '24.6094605 - 49.9693586', 28, null, 'WBA3A5C54CF000404');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (4, '2021-10-05 07:52:10', '2021-09-01 21:00:15', '-88.8718935 - 14.6531486', '-88.8718935 - 14.6531486', 22, null, 'WAUYGAFC0CN160616');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (5, '2021-10-22 14:13:36', '2021-05-26 02:45:37', '124.825117 - 45.141789', '124.825117 - 45.141789', 36, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '3MZBM1U75EM626848');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (6, '2022-04-02 22:43:01', '2022-01-15 11:01:02', '25.605439 - 49.3962315', '25.605439 - 49.3962315', 17, null, '1GYUKJEF3AR142879');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (7, '2021-09-22 07:26:28', '2022-03-19 09:38:35', '-9.3469171 - 38.6849828', '-9.3469171 - 38.6849828', 40, null, 'WAUDG94F95N449099');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (8, '2022-03-28 16:10:17', '2021-07-03 13:36:33', '-71.4013635 - 41.8265437', '-71.4013635 - 41.8265437', 19, null, 'WAUTFAFH0BN309050');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (9, '2021-11-21 12:51:53', '2021-07-12 03:01:28', '-55.9600098 - -34.4402062', '-55.9600098 - -34.4402062', 12, null, 'WVWAN7AN0DE340931');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (10, '2021-10-07 08:20:06', '2022-05-18 16:28:46', '90.8163059 - 24.2442046', '90.8163059 - 24.2442046', 34, null, '1GYEK63N23R667527');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (11, '2021-07-17 01:14:23', '2022-04-28 07:42:41', '12.2028691 - 57.6055534', '12.2028691 - 57.6055534', 17, null, '1FTSW2A52AE822314');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (12, '2021-09-27 10:47:36', '2021-09-03 05:25:42', '61.0018 - 41.56055', '61.0018 - 41.56055', 23, null, '1D4PT6GX2AW619664');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (13, '2022-03-01 17:28:59', '2021-12-17 08:55:57', '115.786056 - 25.600272', '115.786056 - 25.600272', 26, null, 'JM1NC2LF3E0992294');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (14, '2021-09-12 13:21:08', '2021-08-27 14:12:14', '124.25 - 7.2333331', '124.25 - 7.2333331', 5, null, '1GYEK63N23R667527');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (15, '2021-06-02 18:57:05', '2022-05-14 02:42:48', '112.9513185 - 28.2412186', '112.9513185 - 28.2412186', 29, null, 'WBA3A5C54CF000404');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (16, '2022-01-24 12:19:31', '2021-10-21 14:02:56', '113.8659097 - -6.9909214', '113.8659097 - -6.9909214', 16, null, 'WDDGF4HB4EA013237');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (17, '2021-06-15 22:49:14', '2021-06-01 06:01:14', '107.172085 - -7.4212735', '107.172085 - -7.4212735', 24, null, 'JTMHY7AJ7D4802894');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (18, '2022-01-19 02:39:46', '2021-06-24 12:23:39', '24.5376727 - 42.1333129', '24.5376727 - 42.1333129', 25, null, '1FTWX3A52AE836217');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (19, '2021-09-21 10:53:31', '2021-06-13 13:57:03', '-87.0696273 - 20.6523028', '-87.0696273 - 20.6523028', 2, null, 'WAUMR44E76N753635');
insert into noleggio_passato (id, data_ora_preso, data_ora_consegnata, posizione_presa, posizione_consegnata, matricola, comment, targa) values (20, '2021-09-16 18:35:09', '2022-03-10 05:12:26', '108.0865424 - -7.4903037', '108.0865424 - -7.4903037', 4, 'Suspendisse accumsan tortor quis turpis. Sed ante.', '1FTSW2A52AE822314');