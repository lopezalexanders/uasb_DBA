--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: album; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE album (
    albumid integer NOT NULL,
    title character varying(100),
    artistid integer
);


ALTER TABLE public.album OWNER TO admin_user;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE artist (
    artistid integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.artist OWNER TO admin_user;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE customer (
    customerid integer NOT NULL,
    firstname character varying(80),
    lastname character varying(80),
    company character varying(80),
    address character varying(100),
    city character varying(50),
    state character varying(100),
    country character varying(100),
    postalcode character varying(15),
    phone character varying(50),
    fax character varying(50),
    email character varying(100),
    supportrepid integer
);


ALTER TABLE public.customer OWNER TO admin_user;

--
-- Name: invoice; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE invoice (
    invoiceid integer NOT NULL,
    customerid integer,
    invoicedate timestamp without time zone,
    billingaddress character varying(100),
    billingcity character varying(100),
    billingstate character varying(100),
    billingcountry character varying(100),
    billingpostalcode character varying(15),
    total money
);


ALTER TABLE public.invoice OWNER TO admin_user;

--
-- Name: invoiceline; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE invoiceline (
    invoicelineid integer NOT NULL,
    invoiceid integer,
    trackid integer,
    unitprice money,
    quantity smallint
);


ALTER TABLE public.invoiceline OWNER TO admin_user;

--
-- Name: clientes_mas_compras; Type: VIEW; Schema: public; Owner: admin_user
--

CREATE VIEW clientes_mas_compras AS
 SELECT c.firstname,
    c.lastname,
    count(inv_l.quantity) AS c_canciones
   FROM customer c,
    invoice inv,
    invoiceline inv_l
  WHERE ((c.customerid = inv.customerid) AND (inv.invoiceid = inv_l.invoiceid))
  GROUP BY c.firstname, c.lastname
  ORDER BY count(inv_l.quantity) DESC
 LIMIT 3;


ALTER TABLE public.clientes_mas_compras OWNER TO admin_user;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE employee (
    employeeid integer NOT NULL,
    lastname character varying(80),
    firstname character varying(80),
    title character varying(80),
    reportsto integer,
    birthdate timestamp without time zone,
    hiredate timestamp without time zone,
    address character varying(100),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    postalcode character varying(15),
    phone character varying(50),
    fax character varying(50),
    email character varying(100)
);


ALTER TABLE public.employee OWNER TO admin_user;

--
-- Name: genero; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE genero (
    generoid integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.genero OWNER TO admin_user;

--
-- Name: mediatype; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE mediatype (
    mediatypeid integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.mediatype OWNER TO admin_user;

--
-- Name: playlist; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE playlist (
    playlistid integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.playlist OWNER TO admin_user;

--
-- Name: playlisttrack; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE playlisttrack (
    playlistid integer NOT NULL,
    trackid integer NOT NULL
);


ALTER TABLE public.playlisttrack OWNER TO admin_user;

--
-- Name: track; Type: TABLE; Schema: public; Owner: admin_user; Tablespace: 
--

CREATE TABLE track (
    trackid integer NOT NULL,
    name character varying(200),
    albumid integer,
    mediatypeid integer,
    generoid integer,
    composer character varying(200),
    milliseconds integer,
    bytes integer,
    unitprice money
);


ALTER TABLE public.track OWNER TO admin_user;

--
-- Name: top20_canciones_duracion_tipo; Type: VIEW; Schema: public; Owner: admin_user
--

CREATE VIEW top20_canciones_duracion_tipo AS
 SELECT t_r.trackid,
    t_r.name AS name_track,
    t_r.milliseconds,
    mt_r.name
   FROM mediatype mt_r,
    track t_r
  WHERE ((t_r.trackid IN ( SELECT r.trackid
           FROM ( SELECT t.trackid,
                    t.name,
                    t.milliseconds,
                    mt.name
                   FROM track t,
                    mediatype mt
                  WHERE ((t.mediatypeid = mt.mediatypeid) AND (mt.mediatypeid = mt_r.mediatypeid))
                  ORDER BY mt.name, t.milliseconds DESC
                 LIMIT 20) r(trackid, name, milliseconds, name_1))) AND (t_r.mediatypeid = mt_r.mediatypeid))
  ORDER BY mt_r.name, t_r.milliseconds DESC;


ALTER TABLE public.top20_canciones_duracion_tipo OWNER TO admin_user;

--
-- Name: top5_vendidas_genero; Type: VIEW; Schema: public; Owner: admin_user
--

CREATE VIEW top5_vendidas_genero AS
 SELECT gi.generoid,
    gi.name AS genero,
    tr.name AS tema,
    count(iv.quantity) AS vend
   FROM genero gi,
    invoiceline iv,
    track tr
  WHERE ((((tr.name)::text IN ( SELECT r.name
           FROM ( SELECT t.name,
                    count(i.quantity) AS vendidos
                   FROM genero g,
                    track t,
                    invoiceline i
                  WHERE (((g.generoid = t.generoid) AND (t.trackid = i.trackid)) AND (g.generoid = gi.generoid))
                  GROUP BY g.generoid, g.name, t.name
                  ORDER BY g.name, count(i.quantity) DESC
                 LIMIT 5) r)) AND (gi.generoid = tr.generoid)) AND (tr.trackid = iv.trackid))
  GROUP BY gi.generoid, gi.name, tr.name
  ORDER BY gi.generoid, count(iv.quantity) DESC;


ALTER TABLE public.top5_vendidas_genero OWNER TO admin_user;

--
-- Name: total_ventas_mes_vendedor; Type: VIEW; Schema: public; Owner: admin_user
--

CREATE VIEW total_ventas_mes_vendedor AS
 SELECT e.lastname,
    e.firstname,
    date_part('year'::text, i.invoicedate) AS "año",
    to_char(i.invoicedate, 'MM'::text) AS mes,
    sum(i.total) AS sum
   FROM employee e,
    (customer c
     CROSS JOIN invoice i)
  WHERE ((e.employeeid = c.supportrepid) AND (c.customerid = i.customerid))
  GROUP BY e.lastname, e.firstname, date_part('year'::text, i.invoicedate), to_char(i.invoicedate, 'MM'::text)
  ORDER BY e.lastname, e.firstname, date_part('year'::text, i.invoicedate), to_char(i.invoicedate, 'MM'::text);


ALTER TABLE public.total_ventas_mes_vendedor OWNER TO admin_user;

--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY album (albumid, title, artistid) FROM stdin;
1	For Those About To Rock We Salute You	1
2	Balls to the Wall	2
3	Restless and Wild	2
4	Let There Be Rock	1
5	Big Ones	3
6	Jagged Little Pill	4
7	Facelift	5
9	Plays Metallica By Four Cellos	7
10	Audioslave	8
11	Out Of Exile	8
12	BackBeat Soundtrack	9
13	The Best Of Billy Cobham	10
14	Alcohol Fueled Brewtality Live! [Disc 1]	11
15	Alcohol Fueled Brewtality Live! [Disc 2]	11
16	Black Sabbath	12
17	Black Sabbath Vol. 4 (Remaster)	12
18	Body Count	13
19	Chemical Wedding	14
20	The Best Of Buddy Guy - The Millenium Collection	15
21	Prenda Minha	16
22	Sozinho Remix Ao Vivo	16
23	Minha Historia	17
27	Cidade Negra - Hits	19
30	BBC Sessions [Disc 1] [Live]	22
31	Bongo Fury	23
32	Carnaval 2001	21
33	Chill: Brazil (Disc 1)	24
35	Garage Inc. (Disc 1)	50
36	Greatest Hits II	51
37	Greatest Kiss	52
38	Heart of the Night	53
39	International Superhits	54
40	Into The Light	55
41	Meus Momentos	56
43	MK III The Final Concerts [Disc 1]	58
44	Physical Graffiti [Disc 1]	22
45	Sambas De Enredo 2001	21
46	Supernatural	59
47	The Best of Ed Motta	37
48	The Essential Miles Davis [Disc 1]	68
49	The Essential Miles Davis [Disc 2]	68
50	The Final Concerts (Disc 2)	58
51	Up An' Atom	69
53	Vozes do MPB	21
54	Chronicle, Vol. 1	76
55	Chronicle, Vol. 2	76
58	Come Taste The Band	58
59	Deep Purple In Rock	58
60	Fireball	58
61	Knocking at Your Back Door: The Best Of Deep Purple in the 80's	58
62	Machine Head	58
63	Purpendicular	58
64	Slaves And Masters	58
65	Stormbringer	58
66	The Battle Rages On	58
67	Vault: Def Leppard's Greatest Hits	78
68	Outbreak	79
69	Djavan Ao Vivo - Vol. 02	80
70	Djavan Ao Vivo - Vol. 1	80
72	The Cream Of Clapton	81
73	Unplugged	81
74	Album Of The Year	82
75	Angel Dust	82
76	King For A Day Fool For A Lifetime	82
77	The Real Thing	82
78	Deixa Entrar	83
79	In Your Honor [Disc 1]	84
80	In Your Honor [Disc 2]	84
81	One By One	84
82	The Colour And The Shape	84
83	My Way: The Best Of Frank Sinatra [Disc 1]	85
84	Roda De Funk	86
86	Quanta Gente Veio Ver (Live)	27
88	Faceless	87
89	American Idiot	54
90	Appetite for Destruction	88
91	Use Your Illusion I	88
92	Use Your Illusion II	88
93	Blue Moods	89
94	A Matter of Life and Death	90
95	A Real Dead One	90
96	A Real Live One	90
97	Brave New World	90
98	Dance Of Death	90
99	Fear Of The Dark	90
100	Iron Maiden	90
101	Killers	90
102	Live After Death	90
103	Live At Donington 1992 (Disc 1)	90
104	Live At Donington 1992 (Disc 2)	90
105	No Prayer For The Dying	90
106	Piece Of Mind	90
107	Powerslave	90
108	Rock In Rio [CD1]	90
109	Rock In Rio [CD2]	90
110	Seventh Son of a Seventh Son	90
111	Somewhere in Time	90
112	The Number of The Beast	90
113	The X Factor	90
114	Virtual XI	90
115	Sex Machine	91
116	Emergency On Planet Earth	92
117	Synkronized	92
118	The Return Of The Space Cowboy	92
119	Get Born	93
120	Are You Experienced?	94
121	Surfing with the Alien (Remastered)	95
122	Jorge Ben Jor 25 Anos	46
123	Jota Quest-1995	96
125	Living After Midnight	98
126	Unplugged [Live]	52
127	BBC Sessions [Disc 2] [Live]	22
128	Coda	22
129	Houses Of The Holy	22
130	In Through The Out Door	22
131	IV	22
132	Led Zeppelin I	22
133	Led Zeppelin II	22
134	Led Zeppelin III	22
135	Physical Graffiti [Disc 2]	22
136	Presence	22
137	The Song Remains The Same (Disc 1)	22
138	The Song Remains The Same (Disc 2)	22
141	Greatest Hits	100
144	Misplaced Childhood	102
145	Barulhinho Bom	103
146	Seek And Shall Find: More Of The Best (1963-1981)	104
147	The Best Of Men At Work	105
148	Black Album	50
149	Garage Inc. (Disc 2)	50
150	Kill 'Em All	50
151	Load	50
152	Master Of Puppets	50
153	ReLoad	50
154	Ride The Lightning	50
155	St. Anger	50
156	...And Justice For All	50
157	Miles Ahead	68
158	Milton Nascimento Ao Vivo	42
159	Minas	42
163	From The Muddy Banks Of The Wishkah [Live]	110
164	Nevermind	110
166	Olodum	112
168	Arquivo II	113
169	Arquivo Os Paralamas Do Sucesso	113
170	Bark at the Moon (Remastered)	114
171	Blizzard of Ozz	114
172	Diary of a Madman (Remastered)	114
173	No More Tears (Remastered)	114
174	Tribute	114
175	Walking Into Clarksdale	115
176	Original Soundtracks 1	116
177	The Beast Live	117
178	Live On Two Legs [Live]	118
179	Pearl Jam	118
180	Riot Act	118
181	Ten	118
182	Vs.	118
183	Dark Side Of The Moon	120
185	Greatest Hits I	51
186	News Of The World	51
187	Out Of Time	122
188	Green	124
189	New Adventures In Hi-Fi	124
190	The Best Of R.E.M.: The IRS Years	124
192	Raul Seixas	126
193	Blood Sugar Sex Magik	127
194	By The Way	127
195	Californication	127
196	Retrospective I (1974-1980)	128
197	Santana - As Years Go By	59
198	Santana Live	59
199	Maquinarama	130
201	Judas 0: B-Sides and Rarities	131
202	Rotten Apples: Greatest Hits	131
203	A-Sides	132
204	Morning Dance	53
205	In Step	133
206	Core	134
207	Mezmerize	135
208	[1997] Black Light Syndrome	136
209	Live [Disc 1]	137
210	Live [Disc 2]	137
211	The Singles	138
212	Beyond Good And Evil	139
213	Pure Cult: The Best Of The Cult (For Rockers, Ravers, Lovers & Sinners) [UK]	139
214	The Doors	140
215	The Police Greatest Hits	141
216	Hot Rocks, 1964-1971 (Disc 1)	142
217	No Security	142
218	Voodoo Lounge	142
219	Tangents	143
220	Transmission	143
221	My Generation - The Very Best Of The Who	144
222	Serie Sem Limite (Disc 1)	145
223	Serie Sem Limite (Disc 2)	145
226	Battlestar Galactica: The Story So Far	147
227	Battlestar Galactica, Season 3	147
228	Heroes, Season 1	148
229	Lost, Season 3	149
230	Lost, Season 1	149
231	Lost, Season 2	149
232	Achtung Baby	150
233	All That You Can't Leave Behind	150
234	B-Sides 1980-1990	150
235	How To Dismantle An Atomic Bomb	150
236	Pop	150
237	Rattle And Hum	150
238	The Best Of 1980-1990	150
239	War	150
240	Zooropa	150
241	UB40 The Best Of - Volume Two [UK]	151
242	Diver Down	152
243	The Best Of Van Halen, Vol. I	152
244	Van Halen	152
245	Van Halen III	152
246	Contraband	153
248	Ao Vivo [IMPORT]	155
249	The Office, Season 1	156
250	The Office, Season 2	156
251	The Office, Season 3	156
252	Un-Led-Ed	157
253	Battlestar Galactica (Classic), Season 1	158
254	Aquaman	159
255	Instant Karma: The Amnesty International Campaign to Save Darfur	150
256	Speak of the Devil	114
257	20th Century Masters - The Millennium Collection: The Best of Scorpions	179
258	House of Pain	180
259	Radio Brasil (O Som da Jovem Vanguarda) - Seleccao de Henrique Amaro	36
260	Cake: B-Sides and Rarities	196
261	LOST, Season 4	149
262	Quiet Songs	197
264	Realize	199
265	Every Kind of Light	200
266	Duos II	201
267	Worlds	202
268	The Best of Beethoven	203
269	Temple of the Dog	204
270	Carry On	205
271	Revelations	8
272	Adorate Deum: Gregorian Chant from the Proper of the Mass	206
273	Allegri: Miserere	207
274	Pachelbel: Canon & Gigue	208
275	Vivaldi: The Four Seasons	209
276	Bach: Violin Concertos	210
277	Bach: Goldberg Variations	211
278	Bach: The Cello Suites	212
279	Handel: The Messiah (Highlights)	213
280	The World of Classical Favourites	214
281	Sir Neville Marriner: A Celebration	215
282	Mozart: Wind Concertos	216
283	Haydn: Symphonies 99 - 104	217
285	A Soprano Inspired	219
286	Great Opera Choruses	220
287	Wagner: Favourite Overtures	221
289	Tchaikovsky: The Nutcracker	223
290	The Last Night of the Proms	224
291	Puccini: Madama Butterfly - Highlights	225
292	Holst: The Planets, Op. 32 & Vaughan Williams: Fantasies	226
293	Pavarotti's Opera Made Easy	227
294	Great Performances - Barber's Adagio and Other Romantic Favorites for Strings	228
295	Carmina Burana	229
296	A Copland Celebration, Vol. I	230
297	Bach: Toccata & Fugue in D Minor	231
298	Prokofiev: Symphony No.1	232
299	Scheherazade	233
300	Bach: The Brandenburg Concertos	234
301	Chopin: Piano Concertos Nos. 1 & 2	235
302	Mascagni: Cavalleria Rusticana	236
303	Sibelius: Finlandia	237
304	Beethoven Piano Sonatas: Moonlight & Pastorale	238
305	Great Recordings of the Century - Mahler: Das Lied von der Erde	240
307	Adams, John: The Chairman Dances	242
309	Palestrina: Missa Papae Marcelli & Allegri: Miserere	244
310	Prokofiev: Romeo & Juliet	245
311	Strauss: Waltzes	226
312	Berlioz: Symphonie Fantastique	245
313	Bizet: Carmen Highlights	246
314	English Renaissance	247
315	Handel: Music for the Royal Fireworks (Original Version 1749)	208
317	Mozart Gala: Famous Arias	249
318	SCRIABIN: Vers la flamme	250
319	Armada: Music from the Courts of England and Spain	251
320	Mozart: Symphonies Nos. 40 & 41	248
321	Back to Black	252
322	Frank	252
323	Carried to Dust (Bonus Track Version)	253
324	Beethoven: Symphony No. 6 'Pastoral' Etc.	254
325	Bartok: Violin & Viola Concertos	255
326	Mendelssohn: A Midsummer Night's Dream	256
327	Bach: Orchestral Suites Nos. 1 - 4	257
328	Charpentier: Divertissements, Airs & Concerts	258
329	South American Getaway	259
331	Purcell: The Fairy Queen	261
333	Purcell: Music for the Queen Mary	263
335	J.S. Bach: Chaconne, Suite in E Minor, Partita in E Major & Prelude, Fugue and Allegro	265
336	Prokofiev: Symphony No.5 & Stravinksy: Le Sacre Du Printemps	248
337	Szymanowski: Piano Works, Vol. 1	266
339	Great Recordings of the Century: Paganini's 24 Caprices	268
341	Great Recordings of the Century - Shubert: Schwanengesang, 4 Lieder	270
342	Locatelli: Concertos for Violin, Strings and Continuo, Vol. 3	271
343	Respighi:Pines of Rome	226
344	Schubert: The Late String Quartets & String Quintet (3 CD's)	272
345	Monteverdi: L'Orfeo	273
346	Mozart: Chamber Music	274
347	Koyaanisqatsi (Soundtrack from the Motion Picture)	275
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY artist (artistid, name) FROM stdin;
1	AC/DC
2	Accept
3	Aerosmith
4	Alanis Morissette
5	Alice In Chains
7	Apocalyptica
8	Audioslave
9	BackBeat
10	Billy Cobham
11	Black Label Society
12	Black Sabbath
13	Body Count
14	Bruce Dickinson
15	Buddy Guy
16	Caetano Veloso
17	Chico Buarque
19	Cidade Negra
21	Various Artists
22	Led Zeppelin
23	Frank Zappa & Captain Beefheart
24	Marcos Valle
25	Milton Nascimento & Bebeto
26	Azymuth
27	Gilberto Gil
29	Bebel Gilberto
30	Jorge Vercilo
31	Baby Consuelo
32	Ney Matogrosso
33	Luiz Melodia
34	Nando Reis
36	O Rappa
37	Ed Motta
38	Banda Black Rio
39	Fernanda Porto
40	Os Cariocas
41	Elis Regina
42	Milton Nascimento
43	A Cor Do Som
44	Kid Abelha
46	Jorge Ben
47	Hermeto Pascoal
49	Edson, DJ Marky & DJ Patife Featuring Fernanda Porto
50	Metallica
51	Queen
52	Kiss
53	Spyro Gyra
54	Green Day
55	David Coverdale
56	Gonzaguinha
57	Os Mutantes
58	Deep Purple
59	Santana
60	Santana Feat. Dave Matthews
61	Santana Feat. Everlast
62	Santana Feat. Rob Thomas
63	Santana Feat. Lauryn Hill & Cee-Lo
64	Santana Feat. The Project G&B
66	Santana Feat. Eagle-Eye Cherry
67	Santana Feat. Eric Clapton
68	Miles Davis
69	Gene Krupa
75	Vinicius, Toquinho & Quarteto Em Cy
76	Creedence Clearwater Revival
78	Def Leppard
79	Dennis Chambers
80	Djavan
81	Eric Clapton
82	Faith No More
83	Falamansa
84	Foo Fighters
85	Frank Sinatra
86	Funk Como Le Gusta
87	Godsmack
88	Guns N' Roses
89	Incognito
90	Iron Maiden
91	James Brown
92	Jamiroquai
93	JET
94	Jimi Hendrix
95	Joe Satriani
96	Jota Quest
98	Judas Priest
100	Lenny Kravitz
101	Lulu Santos
102	Marillion
103	Marisa Monte
104	Marvin Gaye
105	Men At Work
110	Nirvana
112	Olodum
113	Os Paralamas Do Sucesso
114	Ozzy Osbourne
115	Page & Plant
116	Passengers
117	Paul D'Ianno
118	Pearl Jam
119	Peter Tosh
120	Pink Floyd
121	Planet Hemp
122	R.E.M. Feat. Kate Pearson
123	R.E.M. Feat. KRS-One
124	R.E.M.
125	Raimundos
126	Raul Seixas
127	Red Hot Chili Peppers
128	Rush
129	Simply Red
130	Skank
131	Smashing Pumpkins
132	Soundgarden
133	Stevie Ray Vaughan & Double Trouble
134	Stone Temple Pilots
135	System Of A Down
136	Terry Bozzio, Tony Levin & Steve Stevens
137	The Black Crowes
138	The Clash
139	The Cult
140	The Doors
141	The Police
142	The Rolling Stones
143	The Tea Party
144	The Who
145	Tim Maia
147	Battlestar Galactica
148	Heroes
149	Lost
150	U2
151	UB40
152	Van Halen
153	Velvet Revolver
154	Whitesnake
155	Zeca Pagodinho
156	The Office
157	Dread Zeppelin
158	Battlestar Galactica (Classic)
159	Aquaman
160	Christina Aguilera featuring BigElf
161	Aerosmith & Sierra Leone's Refugee Allstars
162	Los Lonely Boys
163	Corinne Bailey Rae
164	Dhani Harrison & Jakob Dylan
165	Jackson Browne
166	Avril Lavigne
167	Big & Rich
168	Youssou N'Dour
169	Black Eyed Peas
170	Jack Johnson
171	Ben Harper
172	Snow Patrol
173	Matisyahu
174	The Postal Service
175	Jaguares
176	The Flaming Lips
177	Jack's Mannequin & Mick Fleetwood
178	Regina Spektor
179	Scorpions
180	House Of Pain
181	Xis
182	Nega Gizza
183	Gustavo & Andres Veiga & Salazar
184	Rodox
185	Charlie Brown Jr.
187	Los Hermanos
188	Mundo Livre S/A
189	Otto
190	Instituto
192	DJ Dolores & Orchestra Santa Massa
193	Seu Jorge
194	Sabotage E Instituto
195	Stereo Maracana
196	Cake
197	Aisha Duo
199	Karsh Kale
200	The Posies
201	Luciana Souza/Romero Lubambo
202	Aaron Goldberg
203	Nicolaus Esterhazy Sinfonia
204	Temple of the Dog
205	Chris Cornell
206	Alberto Turco & Nova Schola Gregoriana
207	Richard Marlow & The Choir of Trinity College, Cambridge
208	English Concert & Trevor Pinnock
209	Anne-Sophie Mutter, Herbert Von Karajan & Wiener Philharmoniker
210	Hilary Hahn, Jeffrey Kahane, Los Angeles Chamber Orchestra & Margaret Batjer
211	Wilhelm Kempff
212	Yo-Yo Ma
213	Scholars Baroque Ensemble
214	Academy of St. Martin in the Fields & Sir Neville Marriner
215	Academy of St. Martin in the Fields Chamber Ensemble & Sir Neville Marriner
216	Berliner Philharmoniker, Claudio Abbado & Sabine Meyer
217	Royal Philharmonic Orchestra & Sir Thomas Beecham
219	Britten Sinfonia, Ivor Bolton & Lesley Garrett
220	Chicago Symphony Chorus, Chicago Symphony Orchestra & Sir Georg Solti
221	Sir Georg Solti & Wiener Philharmoniker
222	Academy of St. Martin in the Fields, John Birch, Sir Neville Marriner & Sylvia McNair
223	London Symphony Orchestra & Sir Charles Mackerras
224	Barry Wordsworth & BBC Concert Orchestra
225	Herbert Von Karajan, Mirella Freni & Wiener Philharmoniker
226	Eugene Ormandy
227	Luciano Pavarotti
228	Leonard Bernstein & New York Philharmonic
229	Boston Symphony Orchestra & Seiji Ozawa
230	Aaron Copland & London Symphony Orchestra
231	Ton Koopman
232	Sergei Prokofiev & Yuri Temirkanov
233	Chicago Symphony Orchestra & Fritz Reiner
234	Orchestra of The Age of Enlightenment
235	Emanuel Ax, Eugene Ormandy & Philadelphia Orchestra
236	James Levine
237	Berliner Philharmoniker & Hans Rosbaud
238	Maurizio Pollini
239	Academy of St. Martin in the Fields, Sir Neville Marriner & William Bennett
240	Gustav Mahler
242	Edo de Waart & San Francisco Symphony
244	Choir Of Westminster Abbey & Simon Preston
245	Michael Tilson Thomas & San Francisco Symphony
246	Chor der Wiener Staatsoper, Herbert Von Karajan & Wiener Philharmoniker
247	The King's Singers
248	Berliner Philharmoniker & Herbert Von Karajan
249	Sir Georg Solti, Sumi Jo & Wiener Philharmoniker
250	Christopher O'Riley
251	Fretwork
252	Amy Winehouse
253	Calexico
254	Otto Klemperer & Philharmonia Orchestra
255	Yehudi Menuhin
256	Philharmonia Orchestra & Sir Neville Marriner
257	Academy of St. Martin in the Fields, Sir Neville Marriner & Thurston Dart
258	Les Arts Florissants & William Christie
259	The 12 Cellists of The Berlin Philharmonic
260	Adrian Leaper & Doreen de Feis
261	Roger Norrington, London Classical Players
263	Equale Brass Ensemble, John Eliot Gardiner & Munich Monteverdi Orchestra and Choir
265	Julian Bream
266	Martin Roscoe
268	Itzhak Perlman
269	Michele Campanella
270	Gerald Moore
271	Mela Tenenbaum, Pro Musica Prague & Richard Kapp
272	Emerson String Quartet
273	C. Monteverdi, Nigel Rogers - Chiaroscuro; London Baroque; London Cornett & Sackbu
274	Nash Ensemble
275	Philip Glass Ensemble
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY customer (customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid) FROM stdin;
14	Mark	Philips	Telus	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	+1 (780) 434-4554	+1 (780) 434-5565	mphilips12@shaw.ca	5
15	Jennifer	Peterson	Rogers Canada	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	+1 (604) 688-2255	+1 (604) 688-8756	jenniferp@rogers.ca	3
16	Frank	Harris	Google Inc.	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	+1 (650) 253-0000	+1 (650) 253-0000	fharris@google.com	4
17	Jack	Smith	Microsoft Corporation	1 Microsoft Way	Redmond	WA	USA	98052-8300	+1 (425) 882-8080	+1 (425) 882-8081	jacksmith@microsoft.com	5
18	Michelle	Brooks		627 Broadway	New York	NY	USA	10012-2612	+1 (212) 221-3546	+1 (212) 221-4679	michelleb@aol.com	3
19	Tim	Goyer	Apple Inc.	1 Infinite Loop	Cupertino	CA	USA	95014	+1 (408) 996-1010	+1 (408) 996-1011	tgoyer@apple.com	3
20	Dan	Miller		541 Del Medio Avenue	Mountain View	CA	USA	94040-111	+1 (650) 644-3358		dmiller@comcast.com	4
21	Kathy	Chase		801 W 4th Street	Reno	NV	USA	89503	+1 (775) 223-7665		kachase@hotmail.com	5
22	Heather	Leacock		120 S Orange Ave	Orlando	FL	USA	32801	+1 (407) 999-7788		hleacock@gmail.com	4
23	John	Gordon		69 Salem Street	Boston	MA	USA	2113	+1 (617) 522-1333		johngordon22@yahoo.com	4
24	Frank	Ralston		162 E Superior Street	Chicago	IL	USA	60611	+1 (312) 332-3232		fralston@gmail.com	3
25	Victor	Stevens		319 N. Frances Street	Madison	WI	USA	53703	+1 (608) 257-0597		vstevens@yahoo.com	5
26	Richard	Cunningham		2211 W Berry Street	Fort Worth	TX	USA	76110	+1 (817) 924-7272		ricunningham@hotmail.com	4
27	Patrick	Gray		1033 N Park Ave	Tucson	AZ	USA	85719	+1 (520) 622-4200		patrick.gray@aol.com	4
28	Julia	Barnett		302 S 700 E	Salt Lake City	UT	USA	84102	+1 (801) 531-7272		jubarnett@gmail.com	5
29	Robert	Brown		796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	+1 (416) 363-8888		robbrown@shaw.ca	3
30	Edward	Francis		230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	+1 (613) 234-3322		edfrancis@yachoo.ca	3
31	Martha	Silk		194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	+1 (902) 450-0450		marthasilk@gmail.com	5
32	Aaron	Mitchell		696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	+1 (204) 452-6452		aaronmitchell@yahoo.ca	4
33	Ellie	Sullivan		5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	+1 (867) 920-2233		ellie.sullivan@shaw.ca	3
39	Camille	Bernard		4, Rue Milton	Paris		France	75009	+33 01 49 70 65 65		camille.bernard@yahoo.fr	4
40	Dominique	Lefebvre		8, Rue Hanovre	Paris		France	75002	+33 01 47 42 71 71		dominiquelefebvre@gmail.com	4
41	Marc	Dubois		11, Place Bellecour	Lyon		France	69002	+33 04 78 30 30 30		marc.dubois@hotmail.com	5
42	Wyatt	Girard		9, Place Louis Barthou	Bordeaux		France	33000	+33 05 56 96 96 96		wyatt.girard@yahoo.fr	3
43	Isabelle	Mercier		68, Rue Jouvence	Dijon		France	21000	+33 03 80 73 66 99		isabelle_mercier@apple.fr	3
46	Hugh	O'Reilly		3 Chatham Street	Dublin	Dublin	Ireland		+353 01 6792424		hughoreilly@apple.ie	3
47	Lucas	Mancini		Via Degli Scipioni, 43	Rome	RM	Italy	00192	+39 06 39733434		lucas.mancini@yahoo.it	5
48	Johannes	Van der Berg		Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	+31 020 6223130		johavanderberg@yahoo.nl	5
51	Joakim	Johansson		Celsiusg. 9	Stockholm		Sweden	11230	+46 08-651 52 52		joakim.johansson@yahoo.se	5
52	Emma	Jones		202 Hoxton Street	London		United Kingdom	N1 5LH	+44 020 7707 0707		emma_jones@hotmail.com	3
53	Phil	Hughes		113 Lupus St	London		United Kingdom	SW1V 3EN	+44 020 7976 5722		phil.hughes@gmail.com	3
54	Steve	Murray		110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	+44 0131 315 3300		steve.murray@yahoo.uk	5
55	Mark	Taylor		421 Bourke Street	Sidney	NSW	Australia	2010	+61 (02) 9332 3633		mark.taylor@yahoo.au	4
57	Luis	Rojas		Calle Lira, 198	Santiago		Chile		+56 (0)2 635 4444		luisrojas@yahoo.cl	5
58	Manoj	Pareek		12,Community Centre	Delhi		India	110017	+91 0124 39883988		manoj.pareek@rediff.com	3
59	Puja	Srivastava		3,Raj Bhavan Road	Bangalore		India	560001	+91 080 22289999		puja_srivastava@yahoo.in	3
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) FROM stdin;
1	Adams	Andrew	General Manager	\N	1962-02-18 00:00:00	2002-08-14 00:00:00	11120 Jasper Ave NW	Edmonton	AB	Canada	T5K 2N1	+1 (780) 428-9482	+1 (780) 428-3457	andrew@chinookcorp.com
2	Edwards	Nancy	Sales Manager	1	1958-12-08 00:00:00	2002-05-01 00:00:00	825 8 Ave SW	Calgary	AB	Canada	T2P 2T3	+1 (403) 262-3443	+1 (403) 262-3322	nancy@chinookcorp.com
3	Peacock	Jane	Sales Support Agent	2	1973-08-29 00:00:00	2002-04-01 00:00:00	1111 6 Ave SW	Calgary	AB	Canada	T2P 5M5	+1 (403) 262-3443	+1 (403) 262-6712	jane@chinookcorp.com
4	Park	Margaret	Sales Support Agent	2	1947-09-19 00:00:00	2003-05-03 00:00:00	683 10 Street SW	Calgary	AB	Canada	T2P 5G3	+1 (403) 263-4423	+1 (403) 263-4289	margaret@chinookcorp.com
5	Johnson	Steve	Sales Support Agent	2	1965-03-03 00:00:00	2003-10-17 00:00:00	7727B 41 Ave	Calgary	AB	Canada	T3B 1Y7	1 (780) 836-9987	1 (780) 836-9543	steve@chinookcorp.com
6	Mitchell	Michael	IT Manager	1	1973-07-01 00:00:00	2003-10-17 00:00:00	5827 Bowness Road NW	Calgary	AB	Canada	T3B 0C5	+1 (403) 246-9887	+1 (403) 246-9899	michael@chinookcorp.com
7	King	Robert	IT Staff	6	1970-05-29 00:00:00	2004-01-02 00:00:00	590 Columbia Boulevard West	Lethbridge	AB	Canada	T1K 5N8	+1 (403) 456-9986	+1 (403) 456-8485	robert@chinookcorp.com
8	Callahan	Laura	IT Staff	6	1968-01-09 00:00:00	2004-03-04 00:00:00	923 7 ST NW	Lethbridge	AB	Canada	T1H 1Y8	+1 (403) 467-3351	+1 (403) 467-8772	laura@chinookcorp.com
\.


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY genero (generoid, name) FROM stdin;
1	Rock
2	Jazz
3	Metal
4	Alternative & Punk
5	Rock And Roll
6	Blues
7	Latin
8	Reggae
9	Pop
10	Soundtrack
11	Bossa Nova
12	Easy Listening
13	Heavy Metal
14	R&B/Soul
15	Electronica/Dance
16	World
17	Hip Hop/Rap
18	Science Fiction
19	TV Shows
20	Sci Fi & Fantasy
21	Drama
22	Comedy
23	Alternative
24	Classical
25	Opera
\.


--
-- Data for Name: invoice; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY invoice (invoiceid, customerid, invoicedate, billingaddress, billingcity, billingstate, billingcountry, billingpostalcode, total) FROM stdin;
4	14	2009-01-06 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 891,00
5	23	2009-01-11 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 1.386,00
8	40	2009-02-01 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 198,00
9	42	2009-02-02 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 396,00
10	46	2009-02-03 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 594,00
11	52	2009-02-06 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 891,00
13	16	2009-02-19 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 99,00
14	17	2009-03-04 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 198,00
15	19	2009-03-04 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 198,00
16	21	2009-03-05 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 396,00
17	25	2009-03-06 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 594,00
18	31	2009-03-09 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 891,00
19	40	2009-03-14 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 1.386,00
20	54	2009-03-22 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 99,00
21	55	2009-04-04 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 198,00
22	57	2009-04-04 00:00:00	Calle Lira, 198	Santiago		Chile		$b 198,00
23	59	2009-04-05 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 396,00
26	19	2009-04-14 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 1.386,00
27	33	2009-04-22 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 99,00
31	42	2009-05-07 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 594,00
32	48	2009-05-10 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 891,00
33	57	2009-05-15 00:00:00	Calle Lira, 198	Santiago		Chile		$b 1.386,00
36	15	2009-06-05 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 198,00
37	17	2009-06-06 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 396,00
38	21	2009-06-07 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 594,00
39	27	2009-06-10 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 891,00
42	51	2009-07-06 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 198,00
43	53	2009-07-06 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 198,00
44	55	2009-07-07 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 396,00
45	59	2009-07-08 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 594,00
47	15	2009-07-16 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 1.386,00
48	29	2009-07-24 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 99,00
49	30	2009-08-06 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 198,00
50	32	2009-08-06 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 198,00
54	53	2009-08-16 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 1.386,00
59	17	2009-09-08 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 594,00
60	23	2009-09-11 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 891,00
61	32	2009-09-16 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 1.386,00
62	46	2009-09-24 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 99,00
63	47	2009-10-07 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 198,00
65	51	2009-10-08 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 396,00
66	55	2009-10-09 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 594,00
69	25	2009-10-25 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 99,00
70	26	2009-11-07 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 198,00
71	28	2009-11-07 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 198,00
72	30	2009-11-08 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 396,00
74	40	2009-11-12 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 891,00
81	19	2009-12-13 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 891,00
82	28	2009-12-18 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 1.386,00
83	42	2009-12-26 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 99,00
84	43	2010-01-08 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 198,00
86	47	2010-01-09 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 396,00
87	51	2010-01-10 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 694,00
88	57	2010-01-13 00:00:00	Calle Lira, 198	Santiago		Chile		$b 1.791,00
90	21	2010-01-26 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 99,00
91	22	2010-02-08 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 198,00
92	24	2010-02-08 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 198,00
93	26	2010-02-09 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 396,00
94	30	2010-02-10 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 594,00
97	59	2010-02-26 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 199,00
102	15	2010-03-16 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 991,00
103	24	2010-03-21 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 1.586,00
105	39	2010-04-11 00:00:00	4, Rue Milton	Paris		France	75009	$b 198,00
106	41	2010-04-11 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 198,00
107	43	2010-04-12 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 396,00
108	47	2010-04-13 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 594,00
109	53	2010-04-16 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 891,00
111	17	2010-04-29 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 99,00
112	18	2010-05-12 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 198,00
113	20	2010-05-12 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 198,00
114	22	2010-05-13 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 396,00
115	26	2010-05-14 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 594,00
116	32	2010-05-17 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 891,00
117	41	2010-05-22 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 1.386,00
118	55	2010-05-30 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 99,00
120	58	2010-06-12 00:00:00	12,Community Centre	Delhi		India	110017	$b 198,00
124	20	2010-06-22 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 1.386,00
128	39	2010-07-14 00:00:00	4, Rue Milton	Paris		France	75009	$b 396,00
129	43	2010-07-15 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 594,00
131	58	2010-07-23 00:00:00	12,Community Centre	Delhi		India	110017	$b 1.386,00
133	14	2010-08-13 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 198,00
134	16	2010-08-13 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 198,00
135	18	2010-08-14 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 396,00
136	22	2010-08-15 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 594,00
137	28	2010-08-18 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 891,00
139	51	2010-08-31 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 99,00
140	52	2010-09-13 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 198,00
141	54	2010-09-13 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 198,00
145	16	2010-09-23 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 1.386,00
146	30	2010-10-01 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 99,00
147	31	2010-10-14 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 198,00
148	33	2010-10-14 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 198,00
150	39	2010-10-16 00:00:00	4, Rue Milton	Paris		France	75009	$b 594,00
152	54	2010-10-24 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 1.386,00
156	14	2010-11-15 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 396,00
157	18	2010-11-16 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 594,00
158	24	2010-11-19 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 891,00
159	33	2010-11-24 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 1.386,00
160	47	2010-12-02 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 99,00
161	48	2010-12-15 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 198,00
163	52	2010-12-16 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 396,00
167	26	2011-01-02 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 99,00
168	27	2011-01-15 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 198,00
169	29	2011-01-15 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 198,00
170	31	2011-01-16 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 396,00
172	41	2011-01-20 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 891,00
178	14	2011-02-17 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 594,00
179	20	2011-02-20 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 891,00
180	29	2011-02-25 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 1.386,00
181	43	2011-03-05 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 99,00
183	46	2011-03-18 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 198,00
184	48	2011-03-19 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 396,00
185	52	2011-03-20 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 594,00
186	58	2011-03-23 00:00:00	12,Community Centre	Delhi		India	110017	$b 891,00
188	22	2011-04-05 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 99,00
189	23	2011-04-18 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 198,00
190	25	2011-04-18 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 198,00
191	27	2011-04-19 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 396,00
192	31	2011-04-20 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 594,00
194	46	2011-04-28 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 2.186,00
200	16	2011-05-24 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 891,00
201	25	2011-05-29 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 1.886,00
202	39	2011-06-06 00:00:00	4, Rue Milton	Paris		France	75009	$b 199,00
203	40	2011-06-19 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 298,00
204	42	2011-06-19 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 398,00
206	48	2011-06-21 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 894,00
207	54	2011-06-24 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 891,00
209	18	2011-07-07 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 99,00
210	19	2011-07-20 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 198,00
211	21	2011-07-20 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 198,00
212	23	2011-07-21 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 396,00
213	27	2011-07-22 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 594,00
214	33	2011-07-25 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 891,00
215	42	2011-07-30 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 1.386,00
217	57	2011-08-20 00:00:00	Calle Lira, 198	Santiago		Chile		$b 198,00
218	59	2011-08-20 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 198,00
222	21	2011-08-30 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 1.386,00
226	40	2011-09-21 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 396,00
229	59	2011-09-30 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 1.386,00
230	14	2011-10-08 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 99,00
231	15	2011-10-21 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 198,00
232	17	2011-10-21 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 198,00
233	19	2011-10-22 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 396,00
234	23	2011-10-23 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 594,00
235	29	2011-10-26 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 891,00
237	52	2011-11-08 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 99,00
238	53	2011-11-21 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 198,00
239	55	2011-11-21 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 198,00
240	57	2011-11-22 00:00:00	Calle Lira, 198	Santiago		Chile		$b 396,00
243	17	2011-12-01 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 1.386,00
244	31	2011-12-09 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 99,00
245	32	2011-12-22 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 198,00
248	40	2011-12-24 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 594,00
249	46	2011-12-27 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 891,00
250	55	2012-01-01 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 1.386,00
254	15	2012-01-23 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 396,00
255	19	2012-01-24 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 594,00
256	25	2012-01-27 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 891,00
258	48	2012-02-09 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 99,00
260	51	2012-02-22 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 198,00
261	53	2012-02-23 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 396,00
262	57	2012-02-24 00:00:00	Calle Lira, 198	Santiago		Chile		$b 594,00
265	27	2012-03-11 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 99,00
266	28	2012-03-24 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 198,00
267	30	2012-03-24 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 198,00
268	32	2012-03-25 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 396,00
270	42	2012-03-29 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 891,00
271	51	2012-04-03 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 1.386,00
276	15	2012-04-26 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 594,00
277	21	2012-04-29 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 891,00
278	30	2012-05-04 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 1.386,00
281	47	2012-05-25 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 198,00
283	53	2012-05-27 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 594,00
284	59	2012-05-30 00:00:00	3,Raj Bhavan Road	Bangalore		India	560001	$b 891,00
286	23	2012-06-12 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 99,00
287	24	2012-06-25 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 198,00
288	26	2012-06-25 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 198,00
289	28	2012-06-26 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 396,00
290	32	2012-06-27 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 594,00
292	47	2012-07-05 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 1.386,00
298	17	2012-07-31 00:00:00	1 Microsoft Way	Redmond	WA	USA	98052-8300	$b 1.091,00
299	26	2012-08-05 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 2.386,00
300	40	2012-08-13 00:00:00	8, Rue Hanovre	Paris		France	75002	$b 99,00
301	41	2012-08-26 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 198,00
302	43	2012-08-26 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 198,00
305	55	2012-08-31 00:00:00	421 Bourke Street	Sidney	NSW	Australia	2010	$b 891,00
307	19	2012-09-13 00:00:00	1 Infinite Loop	Cupertino	CA	USA	95014	$b 199,00
308	20	2012-09-26 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 398,00
309	22	2012-09-26 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 398,00
310	24	2012-09-27 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 796,00
311	28	2012-09-28 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 1.194,00
313	43	2012-10-06 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 1.686,00
314	57	2012-10-14 00:00:00	Calle Lira, 198	Santiago		Chile		$b 99,00
315	58	2012-10-27 00:00:00	12,Community Centre	Delhi		India	110017	$b 198,00
320	22	2012-11-06 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 1.386,00
323	39	2012-11-27 00:00:00	4, Rue Milton	Paris		France	75009	$b 198,00
324	41	2012-11-28 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 396,00
326	51	2012-12-02 00:00:00	Celsiusg. 9	Stockholm		Sweden	11230	$b 891,00
328	15	2012-12-15 00:00:00	700 W Pender Street	Vancouver	BC	Canada	V6C 1G8	$b 99,00
329	16	2012-12-28 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 198,00
330	18	2012-12-28 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 198,00
331	20	2012-12-29 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 396,00
332	24	2012-12-30 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 594,00
333	30	2013-01-02 00:00:00	230 Elgin Street	Ottawa	ON	Canada	K2P 1L7	$b 891,00
334	39	2013-01-07 00:00:00	4, Rue Milton	Paris		France	75009	$b 1.386,00
335	53	2013-01-15 00:00:00	113 Lupus St	London		United Kingdom	SW1V 3EN	$b 99,00
336	54	2013-01-28 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 198,00
338	58	2013-01-29 00:00:00	12,Community Centre	Delhi		India	110017	$b 396,00
341	18	2013-02-07 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 1.386,00
342	32	2013-02-15 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	$b 99,00
343	33	2013-02-28 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 198,00
346	41	2013-03-02 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 594,00
347	47	2013-03-05 00:00:00	Via Degli Scipioni, 43	Rome	RM	Italy	00192	$b 891,00
351	14	2013-03-31 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 198,00
352	16	2013-04-01 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 396,00
353	20	2013-04-02 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 594,00
354	26	2013-04-05 00:00:00	2211 W Berry Street	Fort Worth	TX	USA	76110	$b 891,00
358	52	2013-05-01 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 198,00
359	54	2013-05-02 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 396,00
360	58	2013-05-03 00:00:00	12,Community Centre	Delhi		India	110017	$b 594,00
362	14	2013-05-11 00:00:00	8210 111 ST NW	Edmonton	AB	Canada	T6G 2C7	$b 1.386,00
363	28	2013-05-19 00:00:00	302 S 700 E	Salt Lake City	UT	USA	84102	$b 99,00
364	29	2013-06-01 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 198,00
365	31	2013-06-01 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 198,00
366	33	2013-06-02 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 396,00
368	43	2013-06-06 00:00:00	68, Rue Jouvence	Dijon		France	21000	$b 891,00
369	52	2013-06-11 00:00:00	202 Hoxton Street	London		United Kingdom	N1 5LH	$b 1.386,00
374	16	2013-07-04 00:00:00	1600 Amphitheatre Parkway	Mountain View	CA	USA	94043-1351	$b 594,00
375	22	2013-07-07 00:00:00	120 S Orange Ave	Orlando	FL	USA	32801	$b 891,00
376	31	2013-07-12 00:00:00	194A Chain Lake Drive	Halifax	NS	Canada	B3S 1C5	$b 1.386,00
378	46	2013-08-02 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 198,00
379	48	2013-08-02 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 198,00
381	54	2013-08-04 00:00:00	110 Raeburn Pl	Edinburgh		United Kingdom	EH4 1HH	$b 594,00
384	24	2013-08-20 00:00:00	162 E Superior Street	Chicago	IL	USA	60611	$b 99,00
385	25	2013-09-02 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 198,00
386	27	2013-09-02 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 198,00
387	29	2013-09-03 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 396,00
388	33	2013-09-04 00:00:00	5112 48 Street	Yellowknife	NT	Canada	X1A 1N6	$b 594,00
389	39	2013-09-07 00:00:00	4, Rue Milton	Paris		France	75009	$b 891,00
390	48	2013-09-12 00:00:00	Lijnbaansgracht 120bg	Amsterdam	VV	Netherlands	1016	$b 1.386,00
396	18	2013-10-08 00:00:00	627 Broadway	New York	NY	USA	10012-2612	$b 891,00
397	27	2013-10-13 00:00:00	1033 N Park Ave	Tucson	AZ	USA	85719	$b 1.386,00
398	41	2013-10-21 00:00:00	11, Place Bellecour	Lyon		France	69002	$b 99,00
399	42	2013-11-03 00:00:00	9, Place Louis Barthou	Bordeaux		France	33000	$b 198,00
401	46	2013-11-04 00:00:00	3 Chatham Street	Dublin	Dublin	Ireland		$b 396,00
405	20	2013-11-21 00:00:00	541 Del Medio Avenue	Mountain View	CA	USA	94040-111	$b 99,00
406	21	2013-12-04 00:00:00	801 W 4th Street	Reno	NV	USA	89503	$b 198,00
407	23	2013-12-04 00:00:00	69 Salem Street	Boston	MA	USA	2113	$b 198,00
408	25	2013-12-05 00:00:00	319 N. Frances Street	Madison	WI	USA	53703	$b 396,00
409	29	2013-12-06 00:00:00	796 Dundas Street West	Toronto	ON	Canada	M6J 1V1	$b 594,00
412	58	2013-12-22 00:00:00	12,Community Centre	Delhi		India	110017	$b 199,00
\.


--
-- Data for Name: invoiceline; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY invoiceline (invoicelineid, invoiceid, trackid, unitprice, quantity) FROM stdin;
13	4	42	$b 99,00	1
14	4	48	$b 99,00	1
15	4	54	$b 99,00	1
16	4	60	$b 99,00	1
19	4	78	$b 99,00	1
20	4	84	$b 99,00	1
21	4	90	$b 99,00	1
22	5	99	$b 99,00	1
23	5	108	$b 99,00	1
24	5	117	$b 99,00	1
25	5	126	$b 99,00	1
26	5	135	$b 99,00	1
27	5	144	$b 99,00	1
28	5	153	$b 99,00	1
29	5	162	$b 99,00	1
30	5	171	$b 99,00	1
31	5	180	$b 99,00	1
32	5	189	$b 99,00	1
33	5	198	$b 99,00	1
35	5	216	$b 99,00	1
39	8	234	$b 99,00	1
40	8	236	$b 99,00	1
42	9	240	$b 99,00	1
56	11	304	$b 99,00	1
74	13	462	$b 99,00	1
75	14	463	$b 99,00	1
76	14	464	$b 99,00	1
77	15	466	$b 99,00	1
78	15	468	$b 99,00	1
79	16	470	$b 99,00	1
80	16	472	$b 99,00	1
81	16	474	$b 99,00	1
82	16	476	$b 99,00	1
83	17	480	$b 99,00	1
84	17	484	$b 99,00	1
85	17	488	$b 99,00	1
86	17	492	$b 99,00	1
87	17	496	$b 99,00	1
88	17	500	$b 99,00	1
90	18	512	$b 99,00	1
91	18	518	$b 99,00	1
92	18	524	$b 99,00	1
96	18	548	$b 99,00	1
97	18	554	$b 99,00	1
99	19	572	$b 99,00	1
100	19	581	$b 99,00	1
101	19	590	$b 99,00	1
102	19	599	$b 99,00	1
103	19	608	$b 99,00	1
104	19	617	$b 99,00	1
105	19	626	$b 99,00	1
106	19	635	$b 99,00	1
107	19	644	$b 99,00	1
111	19	680	$b 99,00	1
112	20	694	$b 99,00	1
113	21	695	$b 99,00	1
114	21	696	$b 99,00	1
115	22	698	$b 99,00	1
116	22	700	$b 99,00	1
117	23	702	$b 99,00	1
118	23	704	$b 99,00	1
119	23	706	$b 99,00	1
120	23	708	$b 99,00	1
136	26	795	$b 99,00	1
137	26	804	$b 99,00	1
138	26	813	$b 99,00	1
139	26	822	$b 99,00	1
140	26	831	$b 99,00	1
141	26	840	$b 99,00	1
142	26	849	$b 99,00	1
143	26	858	$b 99,00	1
145	26	876	$b 99,00	1
147	26	894	$b 99,00	1
148	26	903	$b 99,00	1
149	26	912	$b 99,00	1
150	27	926	$b 99,00	1
159	31	944	$b 99,00	1
160	31	948	$b 99,00	1
161	31	952	$b 99,00	1
162	31	956	$b 99,00	1
163	31	960	$b 99,00	1
164	31	964	$b 99,00	1
165	32	970	$b 99,00	1
166	32	976	$b 99,00	1
167	32	982	$b 99,00	1
168	32	988	$b 99,00	1
169	32	994	$b 99,00	1
170	32	1000	$b 99,00	1
171	32	1006	$b 99,00	1
172	32	1012	$b 99,00	1
173	32	1018	$b 99,00	1
174	33	1027	$b 99,00	1
175	33	1036	$b 99,00	1
176	33	1045	$b 99,00	1
177	33	1054	$b 99,00	1
178	33	1063	$b 99,00	1
179	33	1072	$b 99,00	1
181	33	1090	$b 99,00	1
182	33	1099	$b 99,00	1
183	33	1108	$b 99,00	1
185	33	1126	$b 99,00	1
191	36	1162	$b 99,00	1
192	36	1164	$b 99,00	1
193	37	1166	$b 99,00	1
194	37	1168	$b 99,00	1
195	37	1170	$b 99,00	1
196	37	1172	$b 99,00	1
197	38	1176	$b 99,00	1
198	38	1180	$b 99,00	1
199	38	1184	$b 99,00	1
200	38	1188	$b 99,00	1
201	38	1192	$b 99,00	1
202	38	1196	$b 99,00	1
203	39	1202	$b 99,00	1
204	39	1208	$b 99,00	1
205	39	1214	$b 99,00	1
206	39	1220	$b 99,00	1
207	39	1226	$b 99,00	1
208	39	1232	$b 99,00	1
209	39	1238	$b 99,00	1
210	39	1244	$b 99,00	1
211	39	1250	$b 99,00	1
227	42	1391	$b 99,00	1
228	42	1392	$b 99,00	1
229	43	1394	$b 99,00	1
230	43	1396	$b 99,00	1
231	44	1398	$b 99,00	1
232	44	1400	$b 99,00	1
233	44	1402	$b 99,00	1
234	44	1404	$b 99,00	1
235	45	1408	$b 99,00	1
236	45	1412	$b 99,00	1
237	45	1416	$b 99,00	1
238	45	1420	$b 99,00	1
239	45	1424	$b 99,00	1
240	45	1428	$b 99,00	1
250	47	1491	$b 99,00	1
251	47	1500	$b 99,00	1
252	47	1509	$b 99,00	1
253	47	1518	$b 99,00	1
257	47	1554	$b 99,00	1
258	47	1563	$b 99,00	1
259	47	1572	$b 99,00	1
260	47	1581	$b 99,00	1
261	47	1590	$b 99,00	1
262	47	1599	$b 99,00	1
263	47	1608	$b 99,00	1
264	48	1622	$b 99,00	1
265	49	1623	$b 99,00	1
266	49	1624	$b 99,00	1
267	50	1626	$b 99,00	1
268	50	1628	$b 99,00	1
291	54	1750	$b 99,00	1
292	54	1759	$b 99,00	1
294	54	1777	$b 99,00	1
295	54	1786	$b 99,00	1
296	54	1795	$b 99,00	1
297	54	1804	$b 99,00	1
298	54	1813	$b 99,00	1
299	54	1822	$b 99,00	1
300	54	1831	$b 99,00	1
301	54	1840	$b 99,00	1
311	59	1872	$b 99,00	1
312	59	1876	$b 99,00	1
313	59	1880	$b 99,00	1
314	59	1884	$b 99,00	1
315	59	1888	$b 99,00	1
316	59	1892	$b 99,00	1
317	60	1898	$b 99,00	1
318	60	1904	$b 99,00	1
319	60	1910	$b 99,00	1
321	60	1922	$b 99,00	1
322	60	1928	$b 99,00	1
323	60	1934	$b 99,00	1
324	60	1940	$b 99,00	1
330	61	1991	$b 99,00	1
331	61	2000	$b 99,00	1
332	61	2009	$b 99,00	1
339	61	2072	$b 99,00	1
340	62	2086	$b 99,00	1
341	63	2087	$b 99,00	1
342	63	2088	$b 99,00	1
345	65	2094	$b 99,00	1
346	65	2096	$b 99,00	1
347	65	2098	$b 99,00	1
348	65	2100	$b 99,00	1
349	66	2104	$b 99,00	1
350	66	2108	$b 99,00	1
351	66	2112	$b 99,00	1
352	66	2116	$b 99,00	1
353	66	2120	$b 99,00	1
354	66	2124	$b 99,00	1
378	69	2318	$b 99,00	1
379	70	2319	$b 99,00	1
380	70	2320	$b 99,00	1
381	71	2322	$b 99,00	1
382	71	2324	$b 99,00	1
383	72	2326	$b 99,00	1
384	72	2328	$b 99,00	1
385	72	2330	$b 99,00	1
386	72	2332	$b 99,00	1
393	74	2362	$b 99,00	1
394	74	2368	$b 99,00	1
395	74	2374	$b 99,00	1
396	74	2380	$b 99,00	1
397	74	2386	$b 99,00	1
398	74	2392	$b 99,00	1
399	74	2398	$b 99,00	1
400	74	2404	$b 99,00	1
401	74	2410	$b 99,00	1
431	81	2594	$b 99,00	1
432	81	2600	$b 99,00	1
433	81	2606	$b 99,00	1
434	81	2612	$b 99,00	1
435	81	2618	$b 99,00	1
436	81	2624	$b 99,00	1
437	81	2630	$b 99,00	1
438	81	2636	$b 99,00	1
439	81	2642	$b 99,00	1
440	82	2651	$b 99,00	1
441	82	2660	$b 99,00	1
442	82	2669	$b 99,00	1
443	82	2678	$b 99,00	1
444	82	2687	$b 99,00	1
445	82	2696	$b 99,00	1
446	82	2705	$b 99,00	1
447	82	2714	$b 99,00	1
448	82	2723	$b 99,00	1
449	82	2732	$b 99,00	1
450	82	2741	$b 99,00	1
451	82	2750	$b 99,00	1
468	87	2820	$b 199,00	1
469	88	2826	$b 199,00	1
470	88	2832	$b 199,00	1
471	88	2838	$b 199,00	1
472	88	2844	$b 199,00	1
473	88	2850	$b 199,00	1
474	88	2856	$b 199,00	1
475	88	2862	$b 199,00	1
476	88	2868	$b 199,00	1
477	88	2874	$b 199,00	1
492	90	3014	$b 99,00	1
493	91	3015	$b 99,00	1
494	91	3016	$b 99,00	1
495	92	3018	$b 99,00	1
496	92	3020	$b 99,00	1
497	93	3022	$b 99,00	1
498	93	3024	$b 99,00	1
499	93	3026	$b 99,00	1
500	93	3028	$b 99,00	1
501	94	3032	$b 99,00	1
502	94	3036	$b 99,00	1
503	94	3040	$b 99,00	1
504	94	3044	$b 99,00	1
505	94	3048	$b 99,00	1
506	94	3052	$b 99,00	1
530	97	3246	$b 199,00	1
545	102	3290	$b 99,00	1
546	102	3296	$b 99,00	1
547	102	3302	$b 99,00	1
548	102	3308	$b 99,00	1
549	102	3314	$b 99,00	1
550	102	3320	$b 99,00	1
551	102	3326	$b 99,00	1
552	102	3332	$b 99,00	1
553	102	3338	$b 199,00	1
554	103	3347	$b 199,00	1
555	103	3356	$b 99,00	1
556	103	3365	$b 99,00	1
557	103	3374	$b 99,00	1
558	103	3383	$b 99,00	1
559	103	3392	$b 99,00	1
560	103	3401	$b 99,00	1
561	103	3410	$b 99,00	1
563	103	3428	$b 199,00	1
564	103	3437	$b 99,00	1
565	103	3446	$b 99,00	1
566	103	3455	$b 99,00	1
567	103	3464	$b 99,00	1
569	105	3479	$b 99,00	1
571	106	3482	$b 99,00	1
572	106	3484	$b 99,00	1
573	107	3486	$b 99,00	1
574	107	3488	$b 99,00	1
575	107	3490	$b 99,00	1
576	107	3492	$b 99,00	1
578	108	3500	$b 99,00	1
579	108	1	$b 99,00	1
580	108	5	$b 99,00	1
581	108	9	$b 99,00	1
582	108	13	$b 99,00	1
583	109	19	$b 99,00	1
584	109	25	$b 99,00	1
585	109	31	$b 99,00	1
586	109	37	$b 99,00	1
587	109	43	$b 99,00	1
588	109	49	$b 99,00	1
589	109	55	$b 99,00	1
590	109	61	$b 99,00	1
607	112	208	$b 99,00	1
608	112	209	$b 99,00	1
609	113	211	$b 99,00	1
610	113	213	$b 99,00	1
611	114	215	$b 99,00	1
613	114	219	$b 99,00	1
616	115	229	$b 99,00	1
618	115	237	$b 99,00	1
619	115	241	$b 99,00	1
630	117	308	$b 99,00	1
634	117	344	$b 99,00	1
635	117	353	$b 99,00	1
636	117	362	$b 99,00	1
637	117	371	$b 99,00	1
642	117	416	$b 99,00	1
643	117	425	$b 99,00	1
644	118	439	$b 99,00	1
647	120	443	$b 99,00	1
648	120	445	$b 99,00	1
669	124	549	$b 99,00	1
670	124	558	$b 99,00	1
672	124	576	$b 99,00	1
674	124	594	$b 99,00	1
675	124	603	$b 99,00	1
676	124	612	$b 99,00	1
677	124	621	$b 99,00	1
678	124	630	$b 99,00	1
679	124	639	$b 99,00	1
687	128	679	$b 99,00	1
688	128	681	$b 99,00	1
689	128	683	$b 99,00	1
690	128	685	$b 99,00	1
691	129	689	$b 99,00	1
692	129	693	$b 99,00	1
693	129	697	$b 99,00	1
694	129	701	$b 99,00	1
695	129	705	$b 99,00	1
696	129	709	$b 99,00	1
706	131	772	$b 99,00	1
707	131	781	$b 99,00	1
708	131	790	$b 99,00	1
709	131	799	$b 99,00	1
710	131	808	$b 99,00	1
711	131	817	$b 99,00	1
712	131	826	$b 99,00	1
713	131	835	$b 99,00	1
714	131	844	$b 99,00	1
715	131	853	$b 99,00	1
716	131	862	$b 99,00	1
717	131	871	$b 99,00	1
721	133	904	$b 99,00	1
722	133	905	$b 99,00	1
723	134	907	$b 99,00	1
724	134	909	$b 99,00	1
725	135	911	$b 99,00	1
726	135	913	$b 99,00	1
727	135	915	$b 99,00	1
728	135	917	$b 99,00	1
729	136	921	$b 99,00	1
730	136	925	$b 99,00	1
731	136	929	$b 99,00	1
732	136	933	$b 99,00	1
733	136	937	$b 99,00	1
734	136	941	$b 99,00	1
735	137	947	$b 99,00	1
736	137	953	$b 99,00	1
737	137	959	$b 99,00	1
738	137	965	$b 99,00	1
739	137	971	$b 99,00	1
740	137	977	$b 99,00	1
741	137	983	$b 99,00	1
742	137	989	$b 99,00	1
743	137	995	$b 99,00	1
760	140	1137	$b 99,00	1
761	141	1139	$b 99,00	1
762	141	1141	$b 99,00	1
782	145	1236	$b 99,00	1
783	145	1245	$b 99,00	1
784	145	1254	$b 99,00	1
785	145	1263	$b 99,00	1
786	145	1272	$b 99,00	1
787	145	1281	$b 99,00	1
788	145	1290	$b 99,00	1
789	145	1299	$b 99,00	1
790	145	1308	$b 99,00	1
791	145	1317	$b 99,00	1
792	145	1326	$b 99,00	1
793	145	1335	$b 99,00	1
794	145	1344	$b 99,00	1
795	145	1353	$b 99,00	1
796	146	1367	$b 99,00	1
797	147	1368	$b 99,00	1
798	147	1369	$b 99,00	1
799	148	1371	$b 99,00	1
800	148	1373	$b 99,00	1
805	150	1385	$b 99,00	1
806	150	1389	$b 99,00	1
807	150	1393	$b 99,00	1
808	150	1397	$b 99,00	1
809	150	1401	$b 99,00	1
810	150	1405	$b 99,00	1
820	152	1468	$b 99,00	1
821	152	1477	$b 99,00	1
822	152	1486	$b 99,00	1
823	152	1495	$b 99,00	1
824	152	1504	$b 99,00	1
825	152	1513	$b 99,00	1
826	152	1522	$b 99,00	1
827	152	1531	$b 99,00	1
829	152	1549	$b 99,00	1
830	152	1558	$b 99,00	1
831	152	1567	$b 99,00	1
832	152	1576	$b 99,00	1
833	152	1585	$b 99,00	1
839	156	1607	$b 99,00	1
840	156	1609	$b 99,00	1
841	156	1611	$b 99,00	1
842	156	1613	$b 99,00	1
843	157	1617	$b 99,00	1
844	157	1621	$b 99,00	1
845	157	1625	$b 99,00	1
846	157	1629	$b 99,00	1
847	157	1633	$b 99,00	1
848	157	1637	$b 99,00	1
849	158	1643	$b 99,00	1
850	158	1649	$b 99,00	1
851	158	1655	$b 99,00	1
852	158	1661	$b 99,00	1
853	158	1667	$b 99,00	1
859	159	1709	$b 99,00	1
863	159	1745	$b 99,00	1
864	159	1754	$b 99,00	1
865	159	1763	$b 99,00	1
866	159	1772	$b 99,00	1
867	159	1781	$b 99,00	1
868	159	1790	$b 99,00	1
869	159	1799	$b 99,00	1
870	159	1808	$b 99,00	1
871	159	1817	$b 99,00	1
872	160	1831	$b 99,00	1
873	161	1832	$b 99,00	1
874	161	1833	$b 99,00	1
877	163	1839	$b 99,00	1
878	163	1841	$b 99,00	1
879	163	1843	$b 99,00	1
880	163	1845	$b 99,00	1
912	168	2065	$b 99,00	1
913	169	2067	$b 99,00	1
914	169	2069	$b 99,00	1
915	170	2071	$b 99,00	1
916	170	2073	$b 99,00	1
917	170	2075	$b 99,00	1
925	172	2107	$b 99,00	1
926	172	2113	$b 99,00	1
927	172	2119	$b 99,00	1
928	172	2125	$b 99,00	1
929	172	2131	$b 99,00	1
930	172	2137	$b 99,00	1
931	172	2143	$b 99,00	1
932	172	2149	$b 99,00	1
933	172	2155	$b 99,00	1
957	178	2313	$b 99,00	1
958	178	2317	$b 99,00	1
959	178	2321	$b 99,00	1
960	178	2325	$b 99,00	1
961	178	2329	$b 99,00	1
962	178	2333	$b 99,00	1
964	179	2345	$b 99,00	1
965	179	2351	$b 99,00	1
966	179	2357	$b 99,00	1
967	179	2363	$b 99,00	1
968	179	2369	$b 99,00	1
969	179	2375	$b 99,00	1
970	179	2381	$b 99,00	1
971	179	2387	$b 99,00	1
972	180	2396	$b 99,00	1
973	180	2405	$b 99,00	1
974	180	2414	$b 99,00	1
975	180	2423	$b 99,00	1
976	180	2432	$b 99,00	1
977	180	2441	$b 99,00	1
979	180	2459	$b 99,00	1
981	180	2477	$b 99,00	1
982	180	2486	$b 99,00	1
983	180	2495	$b 99,00	1
984	180	2504	$b 99,00	1
985	180	2513	$b 99,00	1
986	181	2527	$b 99,00	1
989	183	2531	$b 99,00	1
990	183	2533	$b 99,00	1
991	184	2535	$b 99,00	1
992	184	2537	$b 99,00	1
993	184	2539	$b 99,00	1
994	184	2541	$b 99,00	1
995	185	2545	$b 99,00	1
996	185	2549	$b 99,00	1
997	185	2553	$b 99,00	1
998	185	2557	$b 99,00	1
999	185	2561	$b 99,00	1
1000	185	2565	$b 99,00	1
1001	186	2571	$b 99,00	1
1002	186	2577	$b 99,00	1
1003	186	2583	$b 99,00	1
1004	186	2589	$b 99,00	1
1005	186	2595	$b 99,00	1
1006	186	2601	$b 99,00	1
1007	186	2607	$b 99,00	1
1008	186	2613	$b 99,00	1
1009	186	2619	$b 99,00	1
1027	190	2763	$b 99,00	1
1031	191	2771	$b 99,00	1
1048	194	2860	$b 199,00	1
1049	194	2869	$b 199,00	1
1050	194	2878	$b 199,00	1
1051	194	2887	$b 199,00	1
1052	194	2896	$b 199,00	1
1053	194	2905	$b 199,00	1
1054	194	2914	$b 199,00	1
1055	194	2923	$b 199,00	1
1056	194	2932	$b 99,00	1
1057	194	2941	$b 99,00	1
1058	194	2950	$b 99,00	1
1059	194	2959	$b 99,00	1
1060	194	2968	$b 99,00	1
1061	194	2977	$b 99,00	1
1077	200	3035	$b 99,00	1
1078	200	3041	$b 99,00	1
1079	200	3047	$b 99,00	1
1080	200	3053	$b 99,00	1
1081	200	3059	$b 99,00	1
1082	200	3065	$b 99,00	1
1083	200	3071	$b 99,00	1
1084	200	3077	$b 99,00	1
1085	200	3083	$b 99,00	1
1086	201	3092	$b 99,00	1
1087	201	3101	$b 99,00	1
1088	201	3110	$b 99,00	1
1091	201	3137	$b 99,00	1
1093	201	3155	$b 99,00	1
1094	201	3164	$b 99,00	1
1095	201	3173	$b 199,00	1
1096	201	3182	$b 199,00	1
1097	201	3191	$b 199,00	1
1098	201	3200	$b 199,00	1
1099	201	3209	$b 199,00	1
1100	202	3223	$b 199,00	1
1101	203	3224	$b 199,00	1
1102	203	3225	$b 99,00	1
1103	204	3227	$b 199,00	1
1104	204	3229	$b 199,00	1
1109	206	3241	$b 199,00	1
1110	206	3245	$b 199,00	1
1111	206	3249	$b 199,00	1
1112	206	3253	$b 99,00	1
1113	206	3257	$b 99,00	1
1114	206	3261	$b 99,00	1
1115	207	3267	$b 99,00	1
1116	207	3273	$b 99,00	1
1117	207	3279	$b 99,00	1
1118	207	3285	$b 99,00	1
1119	207	3291	$b 99,00	1
1120	207	3297	$b 99,00	1
1121	207	3303	$b 99,00	1
1122	207	3309	$b 99,00	1
1123	207	3315	$b 99,00	1
1138	209	3455	$b 99,00	1
1139	210	3456	$b 99,00	1
1140	210	3457	$b 99,00	1
1141	211	3459	$b 99,00	1
1142	211	3461	$b 99,00	1
1143	212	3463	$b 99,00	1
1144	212	3465	$b 99,00	1
1145	212	3467	$b 99,00	1
1146	212	3469	$b 99,00	1
1147	213	3473	$b 99,00	1
1148	213	3477	$b 99,00	1
1149	213	3481	$b 99,00	1
1152	213	3493	$b 99,00	1
1153	214	3499	$b 99,00	1
1154	214	2	$b 99,00	1
1155	214	8	$b 99,00	1
1156	214	14	$b 99,00	1
1157	214	20	$b 99,00	1
1158	214	26	$b 99,00	1
1159	214	32	$b 99,00	1
1160	214	38	$b 99,00	1
1161	214	44	$b 99,00	1
1162	215	53	$b 99,00	1
1163	215	62	$b 99,00	1
1165	215	80	$b 99,00	1
1166	215	89	$b 99,00	1
1167	215	98	$b 99,00	1
1168	215	107	$b 99,00	1
1169	215	116	$b 99,00	1
1170	215	125	$b 99,00	1
1171	215	134	$b 99,00	1
1172	215	143	$b 99,00	1
1173	215	152	$b 99,00	1
1174	215	161	$b 99,00	1
1175	215	170	$b 99,00	1
1177	217	185	$b 99,00	1
1178	217	186	$b 99,00	1
1179	218	188	$b 99,00	1
1180	218	190	$b 99,00	1
1202	222	303	$b 99,00	1
1206	222	339	$b 99,00	1
1207	222	348	$b 99,00	1
1208	222	357	$b 99,00	1
1209	222	366	$b 99,00	1
1210	222	375	$b 99,00	1
1219	226	424	$b 99,00	1
1220	226	426	$b 99,00	1
1221	226	428	$b 99,00	1
1222	226	430	$b 99,00	1
1238	229	517	$b 99,00	1
1239	229	526	$b 99,00	1
1241	229	544	$b 99,00	1
1242	229	553	$b 99,00	1
1244	229	571	$b 99,00	1
1245	229	580	$b 99,00	1
1246	229	589	$b 99,00	1
1247	229	598	$b 99,00	1
1248	229	607	$b 99,00	1
1249	229	616	$b 99,00	1
1250	229	625	$b 99,00	1
1251	229	634	$b 99,00	1
1262	234	670	$b 99,00	1
1264	234	678	$b 99,00	1
1265	234	682	$b 99,00	1
1266	234	686	$b 99,00	1
1267	235	692	$b 99,00	1
1268	235	698	$b 99,00	1
1269	235	704	$b 99,00	1
1270	235	710	$b 99,00	1
1297	240	892	$b 99,00	1
1298	240	894	$b 99,00	1
1314	243	981	$b 99,00	1
1315	243	990	$b 99,00	1
1316	243	999	$b 99,00	1
1317	243	1008	$b 99,00	1
1318	243	1017	$b 99,00	1
1319	243	1026	$b 99,00	1
1320	243	1035	$b 99,00	1
1321	243	1044	$b 99,00	1
1322	243	1053	$b 99,00	1
1324	243	1071	$b 99,00	1
1326	243	1089	$b 99,00	1
1327	243	1098	$b 99,00	1
1328	244	1112	$b 99,00	1
1329	245	1113	$b 99,00	1
1337	248	1130	$b 99,00	1
1338	248	1134	$b 99,00	1
1339	248	1138	$b 99,00	1
1340	248	1142	$b 99,00	1
1341	248	1146	$b 99,00	1
1342	248	1150	$b 99,00	1
1343	249	1156	$b 99,00	1
1344	249	1162	$b 99,00	1
1345	249	1168	$b 99,00	1
1346	249	1174	$b 99,00	1
1347	249	1180	$b 99,00	1
1348	249	1186	$b 99,00	1
1349	249	1192	$b 99,00	1
1350	249	1198	$b 99,00	1
1351	249	1204	$b 99,00	1
1352	250	1213	$b 99,00	1
1353	250	1222	$b 99,00	1
1354	250	1231	$b 99,00	1
1355	250	1240	$b 99,00	1
1356	250	1249	$b 99,00	1
1357	250	1258	$b 99,00	1
1358	250	1267	$b 99,00	1
1359	250	1276	$b 99,00	1
1360	250	1285	$b 99,00	1
1361	250	1294	$b 99,00	1
1362	250	1303	$b 99,00	1
1363	250	1312	$b 99,00	1
1364	250	1321	$b 99,00	1
1365	250	1330	$b 99,00	1
1371	254	1352	$b 99,00	1
1372	254	1354	$b 99,00	1
1373	254	1356	$b 99,00	1
1374	254	1358	$b 99,00	1
1375	255	1362	$b 99,00	1
1376	255	1366	$b 99,00	1
1377	255	1370	$b 99,00	1
1378	255	1374	$b 99,00	1
1379	255	1378	$b 99,00	1
1380	255	1382	$b 99,00	1
1381	256	1388	$b 99,00	1
1382	256	1394	$b 99,00	1
1383	256	1400	$b 99,00	1
1384	256	1406	$b 99,00	1
1385	256	1412	$b 99,00	1
1386	256	1418	$b 99,00	1
1387	256	1424	$b 99,00	1
1388	256	1430	$b 99,00	1
1389	256	1436	$b 99,00	1
1404	258	1576	$b 99,00	1
1407	260	1580	$b 99,00	1
1408	260	1582	$b 99,00	1
1409	261	1584	$b 99,00	1
1410	261	1586	$b 99,00	1
1411	261	1588	$b 99,00	1
1412	261	1590	$b 99,00	1
1413	262	1594	$b 99,00	1
1414	262	1598	$b 99,00	1
1415	262	1602	$b 99,00	1
1416	262	1606	$b 99,00	1
1417	262	1610	$b 99,00	1
1418	262	1614	$b 99,00	1
1442	265	1808	$b 99,00	1
1443	266	1809	$b 99,00	1
1444	266	1810	$b 99,00	1
1445	267	1812	$b 99,00	1
1446	267	1814	$b 99,00	1
1447	268	1816	$b 99,00	1
1448	268	1818	$b 99,00	1
1449	268	1820	$b 99,00	1
1450	268	1822	$b 99,00	1
1457	270	1852	$b 99,00	1
1458	270	1858	$b 99,00	1
1459	270	1864	$b 99,00	1
1460	270	1870	$b 99,00	1
1461	270	1876	$b 99,00	1
1462	270	1882	$b 99,00	1
1463	270	1888	$b 99,00	1
1464	270	1894	$b 99,00	1
1465	270	1900	$b 99,00	1
1466	271	1909	$b 99,00	1
1469	271	1936	$b 99,00	1
1475	271	1990	$b 99,00	1
1476	271	1999	$b 99,00	1
1477	271	2008	$b 99,00	1
1492	276	2070	$b 99,00	1
1493	276	2074	$b 99,00	1
1495	277	2084	$b 99,00	1
1496	277	2090	$b 99,00	1
1497	277	2096	$b 99,00	1
1498	277	2102	$b 99,00	1
1499	277	2108	$b 99,00	1
1500	277	2114	$b 99,00	1
1501	277	2120	$b 99,00	1
1502	277	2126	$b 99,00	1
1503	277	2132	$b 99,00	1
1504	278	2141	$b 99,00	1
1505	278	2150	$b 99,00	1
1506	278	2159	$b 99,00	1
1507	278	2168	$b 99,00	1
1508	278	2177	$b 99,00	1
1509	278	2186	$b 99,00	1
1510	278	2195	$b 99,00	1
1511	278	2204	$b 99,00	1
1512	278	2213	$b 99,00	1
1513	278	2222	$b 99,00	1
1514	278	2231	$b 99,00	1
1517	278	2258	$b 99,00	1
1521	281	2276	$b 99,00	1
1522	281	2278	$b 99,00	1
1527	283	2290	$b 99,00	1
1528	283	2294	$b 99,00	1
1529	283	2298	$b 99,00	1
1530	283	2302	$b 99,00	1
1531	283	2306	$b 99,00	1
1532	283	2310	$b 99,00	1
1533	284	2316	$b 99,00	1
1534	284	2322	$b 99,00	1
1535	284	2328	$b 99,00	1
1538	284	2346	$b 99,00	1
1540	284	2358	$b 99,00	1
1541	284	2364	$b 99,00	1
1556	286	2504	$b 99,00	1
1557	287	2505	$b 99,00	1
1558	287	2506	$b 99,00	1
1559	288	2508	$b 99,00	1
1560	288	2510	$b 99,00	1
1561	289	2512	$b 99,00	1
1562	289	2514	$b 99,00	1
1563	289	2516	$b 99,00	1
1564	289	2518	$b 99,00	1
1565	290	2522	$b 99,00	1
1566	290	2526	$b 99,00	1
1567	290	2530	$b 99,00	1
1568	290	2534	$b 99,00	1
1569	290	2538	$b 99,00	1
1570	290	2542	$b 99,00	1
1580	292	2605	$b 99,00	1
1581	292	2614	$b 99,00	1
1582	292	2623	$b 99,00	1
1583	292	2632	$b 99,00	1
1584	292	2641	$b 99,00	1
1585	292	2650	$b 99,00	1
1586	292	2659	$b 99,00	1
1587	292	2668	$b 99,00	1
1588	292	2677	$b 99,00	1
1589	292	2686	$b 99,00	1
1590	292	2695	$b 99,00	1
1591	292	2704	$b 99,00	1
1592	292	2713	$b 99,00	1
1593	292	2722	$b 99,00	1
1609	298	2780	$b 99,00	1
1616	298	2822	$b 199,00	1
1617	298	2828	$b 199,00	1
1618	299	2837	$b 199,00	1
1619	299	2846	$b 199,00	1
1620	299	2855	$b 199,00	1
1621	299	2864	$b 199,00	1
1622	299	2873	$b 199,00	1
1623	299	2882	$b 199,00	1
1624	299	2891	$b 199,00	1
1626	299	2909	$b 199,00	1
1627	299	2918	$b 199,00	1
1628	299	2927	$b 99,00	1
1629	299	2936	$b 99,00	1
1630	299	2945	$b 99,00	1
1631	299	2954	$b 99,00	1
1632	300	2968	$b 99,00	1
1633	301	2969	$b 99,00	1
1634	301	2970	$b 99,00	1
1635	302	2972	$b 99,00	1
1636	302	2974	$b 99,00	1
1647	305	3012	$b 99,00	1
1648	305	3018	$b 99,00	1
1649	305	3024	$b 99,00	1
1650	305	3030	$b 99,00	1
1651	305	3036	$b 99,00	1
1652	305	3042	$b 99,00	1
1653	305	3048	$b 99,00	1
1654	305	3054	$b 99,00	1
1655	305	3060	$b 99,00	1
1670	307	3200	$b 199,00	1
1671	308	3201	$b 199,00	1
1672	308	3202	$b 199,00	1
1673	309	3204	$b 199,00	1
1674	309	3206	$b 199,00	1
1675	310	3208	$b 199,00	1
1676	310	3210	$b 199,00	1
1677	310	3212	$b 199,00	1
1678	310	3214	$b 199,00	1
1679	311	3218	$b 199,00	1
1680	311	3222	$b 199,00	1
1681	311	3226	$b 199,00	1
1682	311	3230	$b 199,00	1
1683	311	3234	$b 199,00	1
1684	311	3238	$b 199,00	1
1694	313	3301	$b 99,00	1
1695	313	3310	$b 99,00	1
1696	313	3319	$b 99,00	1
1697	313	3328	$b 99,00	1
1698	313	3337	$b 199,00	1
1699	313	3346	$b 199,00	1
1700	313	3355	$b 99,00	1
1701	313	3364	$b 199,00	1
1702	313	3373	$b 99,00	1
1703	313	3382	$b 99,00	1
1704	313	3391	$b 99,00	1
1705	313	3400	$b 99,00	1
1708	314	3432	$b 99,00	1
1709	315	3433	$b 99,00	1
1732	320	30	$b 99,00	1
1733	320	39	$b 99,00	1
1734	320	48	$b 99,00	1
1735	320	57	$b 99,00	1
1738	320	84	$b 99,00	1
1739	320	93	$b 99,00	1
1740	320	102	$b 99,00	1
1741	320	111	$b 99,00	1
1742	320	120	$b 99,00	1
1743	320	129	$b 99,00	1
1744	320	138	$b 99,00	1
1745	320	147	$b 99,00	1
1749	323	165	$b 99,00	1
1750	323	167	$b 99,00	1
1751	324	169	$b 99,00	1
1752	324	171	$b 99,00	1
1753	324	173	$b 99,00	1
1754	324	175	$b 99,00	1
1762	326	211	$b 99,00	1
1764	326	223	$b 99,00	1
1765	326	229	$b 99,00	1
1767	326	241	$b 99,00	1
1793	332	411	$b 99,00	1
1794	332	415	$b 99,00	1
1795	332	419	$b 99,00	1
1796	332	423	$b 99,00	1
1797	332	427	$b 99,00	1
1798	332	431	$b 99,00	1
1799	333	437	$b 99,00	1
1800	333	443	$b 99,00	1
1801	333	449	$b 99,00	1
1802	333	455	$b 99,00	1
1803	333	461	$b 99,00	1
1804	333	467	$b 99,00	1
1805	333	473	$b 99,00	1
1806	333	479	$b 99,00	1
1807	333	485	$b 99,00	1
1808	334	494	$b 99,00	1
1810	334	512	$b 99,00	1
1811	334	521	$b 99,00	1
1814	334	548	$b 99,00	1
1815	334	557	$b 99,00	1
1816	334	566	$b 99,00	1
1817	334	575	$b 99,00	1
1818	334	584	$b 99,00	1
1819	334	593	$b 99,00	1
1820	334	602	$b 99,00	1
1821	334	611	$b 99,00	1
1822	335	625	$b 99,00	1
1823	336	626	$b 99,00	1
1824	336	627	$b 99,00	1
1827	338	633	$b 99,00	1
1828	338	635	$b 99,00	1
1829	338	637	$b 99,00	1
1830	338	639	$b 99,00	1
1849	341	753	$b 99,00	1
1850	341	762	$b 99,00	1
1851	341	771	$b 99,00	1
1852	341	780	$b 99,00	1
1853	341	789	$b 99,00	1
1854	341	798	$b 99,00	1
1855	341	807	$b 99,00	1
1856	341	816	$b 99,00	1
1857	341	825	$b 99,00	1
1858	341	834	$b 99,00	1
1859	341	843	$b 99,00	1
1861	343	858	$b 99,00	1
1862	343	859	$b 99,00	1
1869	346	875	$b 99,00	1
1873	346	891	$b 99,00	1
1874	346	895	$b 99,00	1
1875	347	901	$b 99,00	1
1876	347	907	$b 99,00	1
1877	347	913	$b 99,00	1
1878	347	919	$b 99,00	1
1879	347	925	$b 99,00	1
1880	347	931	$b 99,00	1
1881	347	937	$b 99,00	1
1882	347	943	$b 99,00	1
1883	347	949	$b 99,00	1
1901	351	1093	$b 99,00	1
1902	351	1095	$b 99,00	1
1904	352	1099	$b 99,00	1
1905	352	1101	$b 99,00	1
1907	353	1107	$b 99,00	1
1908	353	1111	$b 99,00	1
1909	353	1115	$b 99,00	1
1910	353	1119	$b 99,00	1
1911	353	1123	$b 99,00	1
1912	353	1127	$b 99,00	1
1914	354	1139	$b 99,00	1
1915	354	1145	$b 99,00	1
1916	354	1151	$b 99,00	1
1917	354	1157	$b 99,00	1
1918	354	1163	$b 99,00	1
1919	354	1169	$b 99,00	1
1920	354	1175	$b 99,00	1
1921	354	1181	$b 99,00	1
1939	358	1325	$b 99,00	1
1940	358	1327	$b 99,00	1
1941	359	1329	$b 99,00	1
1942	359	1331	$b 99,00	1
1943	359	1333	$b 99,00	1
1944	359	1335	$b 99,00	1
1945	360	1339	$b 99,00	1
1946	360	1343	$b 99,00	1
1947	360	1347	$b 99,00	1
1948	360	1351	$b 99,00	1
1949	360	1355	$b 99,00	1
1950	360	1359	$b 99,00	1
1960	362	1422	$b 99,00	1
1961	362	1431	$b 99,00	1
1962	362	1440	$b 99,00	1
1963	362	1449	$b 99,00	1
1964	362	1458	$b 99,00	1
1965	362	1467	$b 99,00	1
1966	362	1476	$b 99,00	1
1967	362	1485	$b 99,00	1
1968	362	1494	$b 99,00	1
1969	362	1503	$b 99,00	1
1971	362	1521	$b 99,00	1
1972	362	1530	$b 99,00	1
1974	363	1553	$b 99,00	1
1975	364	1554	$b 99,00	1
1976	364	1555	$b 99,00	1
1977	365	1557	$b 99,00	1
1978	365	1559	$b 99,00	1
1979	366	1561	$b 99,00	1
1980	366	1563	$b 99,00	1
1981	366	1565	$b 99,00	1
1982	366	1567	$b 99,00	1
1989	368	1597	$b 99,00	1
1990	368	1603	$b 99,00	1
1991	368	1609	$b 99,00	1
1992	368	1615	$b 99,00	1
1993	368	1621	$b 99,00	1
1994	368	1627	$b 99,00	1
1995	368	1633	$b 99,00	1
1996	368	1639	$b 99,00	1
1997	368	1645	$b 99,00	1
1998	369	1654	$b 99,00	1
1999	369	1663	$b 99,00	1
2004	369	1708	$b 99,00	1
2009	369	1753	$b 99,00	1
2010	369	1762	$b 99,00	1
2011	369	1771	$b 99,00	1
2021	374	1803	$b 99,00	1
2022	374	1807	$b 99,00	1
2023	374	1811	$b 99,00	1
2024	374	1815	$b 99,00	1
2025	374	1819	$b 99,00	1
2026	374	1823	$b 99,00	1
2027	375	1829	$b 99,00	1
2028	375	1835	$b 99,00	1
2029	375	1841	$b 99,00	1
2030	375	1847	$b 99,00	1
2031	375	1853	$b 99,00	1
2032	375	1859	$b 99,00	1
2033	375	1865	$b 99,00	1
2034	375	1871	$b 99,00	1
2035	375	1877	$b 99,00	1
2036	376	1886	$b 99,00	1
2037	376	1895	$b 99,00	1
2038	376	1904	$b 99,00	1
2039	376	1913	$b 99,00	1
2040	376	1922	$b 99,00	1
2041	376	1931	$b 99,00	1
2042	376	1940	$b 99,00	1
2048	376	1994	$b 99,00	1
2049	376	2003	$b 99,00	1
2059	381	2035	$b 99,00	1
2060	381	2039	$b 99,00	1
2061	381	2043	$b 99,00	1
2092	386	2255	$b 99,00	1
2093	387	2257	$b 99,00	1
2094	387	2259	$b 99,00	1
2095	387	2261	$b 99,00	1
2096	387	2263	$b 99,00	1
2097	388	2267	$b 99,00	1
2098	388	2271	$b 99,00	1
2099	388	2275	$b 99,00	1
2100	388	2279	$b 99,00	1
2101	388	2283	$b 99,00	1
2102	388	2287	$b 99,00	1
2103	389	2293	$b 99,00	1
2104	389	2299	$b 99,00	1
2105	389	2305	$b 99,00	1
2106	389	2311	$b 99,00	1
2107	389	2317	$b 99,00	1
2108	389	2323	$b 99,00	1
2109	389	2329	$b 99,00	1
2112	390	2350	$b 99,00	1
2113	390	2359	$b 99,00	1
2114	390	2368	$b 99,00	1
2115	390	2377	$b 99,00	1
2116	390	2386	$b 99,00	1
2117	390	2395	$b 99,00	1
2118	390	2404	$b 99,00	1
2119	390	2413	$b 99,00	1
2120	390	2422	$b 99,00	1
2121	390	2431	$b 99,00	1
2122	390	2440	$b 99,00	1
2124	390	2458	$b 99,00	1
2141	396	2525	$b 99,00	1
2142	396	2531	$b 99,00	1
2143	396	2537	$b 99,00	1
2144	396	2543	$b 99,00	1
2145	396	2549	$b 99,00	1
2146	396	2555	$b 99,00	1
2147	396	2561	$b 99,00	1
2148	396	2567	$b 99,00	1
2149	396	2573	$b 99,00	1
2150	397	2582	$b 99,00	1
2151	397	2591	$b 99,00	1
2152	397	2600	$b 99,00	1
2153	397	2609	$b 99,00	1
2154	397	2618	$b 99,00	1
2155	397	2627	$b 99,00	1
2156	397	2636	$b 99,00	1
2157	397	2645	$b 99,00	1
2158	397	2654	$b 99,00	1
2159	397	2663	$b 99,00	1
2160	397	2672	$b 99,00	1
2161	397	2681	$b 99,00	1
2162	397	2690	$b 99,00	1
2163	397	2699	$b 99,00	1
2164	398	2713	$b 99,00	1
2165	399	2714	$b 99,00	1
2166	399	2715	$b 99,00	1
2169	401	2721	$b 99,00	1
2170	401	2723	$b 99,00	1
2171	401	2725	$b 99,00	1
2172	401	2727	$b 99,00	1
2202	405	2945	$b 99,00	1
2203	406	2946	$b 99,00	1
2204	406	2947	$b 99,00	1
2205	407	2949	$b 99,00	1
2206	407	2951	$b 99,00	1
2207	408	2953	$b 99,00	1
2208	408	2955	$b 99,00	1
2209	408	2957	$b 99,00	1
2210	408	2959	$b 99,00	1
2211	409	2963	$b 99,00	1
2212	409	2967	$b 99,00	1
2213	409	2971	$b 99,00	1
2214	409	2975	$b 99,00	1
2215	409	2979	$b 99,00	1
2216	409	2983	$b 99,00	1
2240	412	3177	$b 199,00	1
\.


--
-- Data for Name: mediatype; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY mediatype (mediatypeid, name) FROM stdin;
1	MPEG audio file
2	Protected AAC audio file
3	Protected MPEG-4 video file
4	Purchased AAC audio file
5	ACC Audio File
\.


--
-- Data for Name: playlist; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY playlist (playlistid, name) FROM stdin;
1	Music
2	Movies
3	TV Shows
4	Audiobooks
6	Audiobooks
7	Movies
8	Music
9	Music Videos
10	TV Shows
11	Brazilian Music
12	Classical
13	Classical 101 - Deep Cuts
14	Classical 101 - Next Steps
15	Classical 101 - The Basics
16	Grunge
17	Heavy Metal Classic
18	On-The-Go 1
\.


--
-- Data for Name: playlisttrack; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY playlisttrack (playlistid, trackid) FROM stdin;
1	3402
1	3389
1	3390
1	3391
1	3392
1	3393
1	3394
1	3395
1	3396
1	3397
1	3398
1	3399
1	3400
1	3401
1	3336
1	3478
1	3375
1	3376
1	3377
1	3378
1	3379
1	3380
1	3381
1	3382
1	3383
1	3384
1	3385
1	3386
1	3387
1	3388
1	3365
1	3366
1	3367
1	3368
1	3369
1	3370
1	3371
1	3372
1	3373
1	3374
1	99
1	100
1	101
1	102
1	103
1	104
1	105
1	106
1	107
1	108
1	109
1	110
1	166
1	167
1	168
1	169
1	170
1	171
1	172
1	173
1	174
1	175
1	176
1	177
1	178
1	179
1	180
1	181
1	182
1	2591
1	2592
1	2593
1	2594
1	2595
1	2596
1	2597
1	2598
1	2599
1	2600
1	2601
1	2602
1	2603
1	2604
1	2605
1	2606
1	2607
1	2608
1	923
1	924
1	925
1	926
1	927
1	928
1	929
1	930
1	931
1	932
1	933
1	934
1	935
1	936
1	937
1	938
1	939
1	940
1	941
1	942
1	943
1	944
1	945
1	946
1	947
1	948
1	964
1	965
1	966
1	967
1	968
1	969
1	970
1	971
1	972
1	973
1	974
1	1009
1	1010
1	1011
1	1012
1	1013
1	1014
1	1015
1	1016
1	1017
1	1018
1	1019
1	1134
1	1137
1	1138
1	1139
1	1140
1	1141
1	1142
1	1145
1	468
1	469
1	470
1	471
1	472
1	473
1	474
1	475
1	476
1	477
1	478
1	479
1	480
1	481
1	482
1	483
1	484
1	485
1	486
1	487
1	488
1	1466
1	1467
1	1468
1	1469
1	1470
1	1471
1	1472
1	1473
1	1474
1	1475
1	1476
1	1477
1	1478
1	2165
1	2166
1	2167
1	2168
1	2169
1	2170
1	2171
1	2172
1	2173
1	2174
1	2175
1	2176
1	2177
1	2318
1	2319
1	2320
1	2321
1	2322
1	2323
1	2324
1	2325
1	2326
1	2327
1	2328
1	2329
1	2330
1	2331
1	2332
1	2333
1	2285
1	2286
1	2287
1	2288
1	2289
1	2290
1	2291
1	2292
1	2293
1	2294
1	2295
1	2310
1	2311
1	2312
1	2313
1	2314
1	2315
1	2316
1	2317
1	2282
1	2283
1	2284
1	2358
1	2359
1	2360
1	2361
1	2362
1	2363
1	2364
1	2365
1	2366
1	2367
1	2368
1	2369
1	2370
1	2371
1	2372
1	2373
1	2374
1	2472
1	2473
1	2474
1	2475
1	2476
1	2477
1	2478
1	2479
1	2480
1	2481
1	2482
1	2483
1	2484
1	2485
1	2486
1	2487
1	2488
1	2489
1	2490
1	2491
1	2492
1	2493
1	2494
1	2495
1	2496
1	2497
1	2498
1	2499
1	2500
1	2501
1	2502
1	2503
1	2504
1	2505
1	2705
1	2706
1	2707
1	2708
1	2709
1	2710
1	2711
1	2712
1	2713
1	2714
1	2715
1	2716
1	2717
1	2718
1	2719
1	2720
1	2721
1	2722
1	2723
1	2724
1	2725
1	2726
1	2727
1	2728
1	2729
1	2730
1	2572
1	2573
1	2574
1	2575
1	2576
1	2577
1	2578
1	2579
1	2580
1	2581
1	2582
1	2583
1	2584
1	2585
1	2586
1	2587
1	2588
1	2589
1	2590
1	194
1	195
1	196
1	197
1	198
1	199
1	200
1	201
1	202
1	203
1	204
1	891
1	892
1	893
1	894
1	895
1	896
1	897
1	898
1	899
1	900
1	901
1	902
1	903
1	904
1	905
1	906
1	907
1	908
1	909
1	910
1	911
1	912
1	913
1	914
1	915
1	916
1	917
1	918
1	919
1	920
1	921
1	922
1	1268
1	1269
1	1272
1	1273
1	1274
1	1275
1	1276
1	2532
1	2533
1	2534
1	2535
1	2536
1	2537
1	2538
1	2539
1	2540
1	2541
1	3427
1	3411
1	3412
1	3482
1	3438
1	3403
1	3406
1	3421
1	3436
1	3454
1	3491
1	3413
1	3426
1	3416
1	3501
1	3417
1	3432
1	3443
1	3447
1	3452
1	3441
1	3500
1	3405
1	3488
1	3423
1	3499
1	3445
1	3453
1	3497
1	3439
1	3407
1	3435
1	3490
1	3448
1	3492
1	3425
1	3483
1	3420
1	3424
1	3493
1	3437
1	3498
1	3446
1	3444
1	3502
1	3359
1	3433
1	3479
1	3481
1	3404
1	3486
1	3414
1	3410
1	3431
1	3430
1	3484
1	1034
1	1035
1	1036
1	1037
1	1038
1	1039
1	1040
1	1041
1	1042
1	1043
1	1044
1	1045
1	1046
1	1047
1	1048
1	1049
1	1050
1	1051
1	1052
1	1053
1	1054
1	1055
1	1056
1	3324
1	3331
1	3332
1	3322
1	3329
1	1455
1	1456
1	1457
1	1458
1	1459
1	1460
1	1461
1	1462
1	1463
1	1464
1	1465
1	3352
1	3358
1	3326
1	3327
1	3330
1	3321
1	3319
1	3328
1	3325
1	3323
1	3334
1	3333
1	3335
1	3320
1	1245
1	1246
1	1247
1	1248
1	1249
1	1250
1	1251
1	1252
1	1253
1	1254
1	1255
1	1277
1	1278
1	1279
1	1280
1	1281
1	1283
1	1284
1	1285
1	1286
1	1287
1	1288
1	1300
1	1301
1	1302
1	1303
1	1304
1	3301
1	3300
1	3302
1	3303
1	3304
1	3305
1	3306
1	3307
1	3308
1	3309
1	3310
1	3311
1	3312
1	3313
1	3314
1	3315
1	3316
1	3317
1	3318
1	3357
1	3350
1	3349
1	123
1	124
1	125
1	126
1	127
1	128
1	129
1	130
1	842
1	843
1	844
1	845
1	846
1	847
1	848
1	849
1	850
1	624
1	625
1	626
1	627
1	628
1	629
1	630
1	631
1	632
1	633
1	634
1	635
1	636
1	637
1	638
1	639
1	640
1	641
1	642
1	643
1	644
1	645
1	1188
1	1189
1	1190
1	1191
1	1192
1	1193
1	1194
1	1195
1	1196
1	1197
1	1198
1	1199
1	1200
1	597
1	598
1	599
1	600
1	601
1	602
1	603
1	604
1	605
1	606
1	607
1	608
1	609
1	610
1	611
1	612
1	613
1	614
1	615
1	616
1	617
1	618
1	619
1	1902
1	1903
1	1904
1	1905
1	1906
1	1907
1	1908
1	1909
1	1910
1	1911
1	1912
1	1913
1	1914
1	1915
1	456
1	457
1	458
1	459
1	460
1	461
1	462
1	463
1	464
1	465
1	466
1	467
1	2523
1	2524
1	2525
1	2526
1	2527
1	2528
1	2529
1	2530
1	2531
1	382
1	515
1	516
1	517
1	518
1	519
1	520
1	521
1	522
1	523
1	524
1	525
1	526
1	527
1	528
1	206
1	208
1	209
1	210
1	211
1	213
1	214
1	215
1	216
1	218
1	219
1	220
1	222
1	223
1	224
1	226
1	228
1	229
1	230
1	231
1	232
1	234
1	236
1	237
1	239
1	240
1	241
1	243
1	852
1	853
1	854
1	855
1	858
1	859
1	860
1	862
1	863
1	864
1	865
1	866
1	868
1	869
1	871
1	872
1	873
1	874
1	875
1	876
1	584
1	586
1	587
1	589
1	590
1	591
1	592
1	593
1	594
1	596
1	975
1	976
1	977
1	981
1	982
1	983
1	984
1	985
1	987
1	988
1	390
1	1057
1	1058
1	1059
1	1063
1	1064
1	1065
1	1066
1	1067
1	1069
1	1070
1	1071
1	1072
1	377
1	1088
1	1089
1	1090
1	1091
1	1092
1	1093
1	1094
1	1095
1	1098
1	1099
1	1100
1	1101
1	1105
1	1106
1	1107
1	1108
1	1111
1	1112
1	1113
1	1115
1	1116
1	1118
1	1119
1	501
1	505
1	507
1	509
1	512
1	514
1	378
1	1506
1	1507
1	1508
1	1509
1	1513
1	1516
1	1517
1	1518
1	1519
1	381
1	1520
1	1521
1	1522
1	1523
1	1528
1	1529
1	1530
1	1531
1	3356
1	374
1	1755
1	1762
1	1763
1	1756
1	1764
1	1757
1	1765
1	1766
1	1759
1	1769
1	1770
1	1771
1	1772
1	1917
1	1919
1	1921
1	1922
1	1923
1	1925
1	1926
1	1928
1	1929
1	1931
1	1934
1	1935
1	1936
1	1937
1	1938
1	1939
1	1940
1	375
1	385
1	383
1	2030
1	2032
1	2035
1	2038
1	2039
1	2040
1	2042
1	2043
1	2065
1	2067
1	2068
1	2069
1	2070
1	2071
1	2072
1	2073
1	2074
1	2075
1	2079
1	2080
1	2081
1	2083
1	2084
1	2085
1	2086
1	2087
1	2088
1	2089
1	2090
1	2092
1	386
1	2751
1	2752
1	2753
1	2757
1	2763
1	2764
1	2766
1	2771
1	2772
1	2774
1	2776
1	2780
1	556
1	557
1	558
1	559
1	560
1	561
1	565
1	566
1	569
1	664
1	665
1	667
1	670
1	672
1	673
1	3149
1	3153
1	3155
1	3158
1	3160
1	3162
1	3164
1	77
1	78
1	79
1	80
1	81
1	82
1	83
1	84
1	131
1	132
1	133
1	134
1	135
1	136
1	137
1	138
1	139
1	140
1	141
1	142
1	143
1	144
1	145
1	146
1	147
1	148
1	149
1	150
1	151
1	152
1	153
1	154
1	155
1	156
1	157
1	158
1	159
1	160
1	161
1	162
1	163
1	164
1	165
1	183
1	184
1	185
1	186
1	187
1	188
1	189
1	190
1	191
1	192
1	193
1	1121
1	1122
1	1123
1	1124
1	1125
1	1126
1	1127
1	1128
1	1129
1	1130
1	1131
1	1132
1	1174
1	1175
1	1176
1	1177
1	1178
1	1179
1	1180
1	1181
1	1182
1	1183
1	1184
1	1185
1	1186
1	1187
1	1289
1	1290
1	1291
1	1292
1	1293
1	1294
1	1295
1	1296
1	1297
1	1298
1	1299
1	1325
1	1326
1	1327
1	1328
1	1329
1	1330
1	1331
1	1332
1	1333
1	1334
1	1391
1	1388
1	1394
1	1387
1	1392
1	1389
1	1390
1	1335
1	1336
1	1337
1	1338
1	1339
1	1340
1	1341
1	1342
1	1343
1	1344
1	1345
1	1346
1	1347
1	1348
1	1349
1	1350
1	1351
1	1212
1	1213
1	1214
1	1215
1	1216
1	1217
1	1218
1	1219
1	1220
1	1221
1	1222
1	1223
1	1224
1	1225
1	1226
1	1227
1	1228
1	1229
1	1230
1	1231
1	1232
1	1233
1	1234
1	1352
1	1353
1	1354
1	1355
1	1356
1	1357
1	1358
1	1359
1	1360
1	1361
1	1364
1	1371
1	1372
1	1373
1	1374
1	1375
1	1376
1	1377
1	1378
1	1379
1	1380
1	1381
1	1382
1	1386
1	1383
1	1385
1	1384
1	1546
1	1547
1	1548
1	1549
1	1550
1	1551
1	1552
1	1553
1	1554
1	1555
1	1556
1	1557
1	1558
1	1559
1	1560
1	1561
1	1893
1	1894
1	1895
1	1896
1	1897
1	1898
1	1899
1	1900
1	1901
1	1801
1	1802
1	1803
1	1804
1	1805
1	1806
1	1807
1	1808
1	1809
1	1810
1	1811
1	1812
1	408
1	409
1	410
1	411
1	412
1	413
1	414
1	415
1	416
1	417
1	418
1	1813
1	1814
1	1815
1	1816
1	1817
1	1818
1	1819
1	1820
1	1821
1	1822
1	1823
1	1824
1	1825
1	1826
1	1827
1	1828
1	1829
1	1830
1	1831
1	1832
1	1833
1	1834
1	1835
1	1836
1	1837
1	1838
1	1839
1	1840
1	1841
1	1842
1	1843
1	1844
1	1845
1	1846
1	1847
1	1848
1	1849
1	1850
1	1851
1	1852
1	1853
1	1854
1	1855
1	1856
1	1857
1	1858
1	1859
1	1860
1	1861
1	1862
1	1863
1	1864
1	1865
1	1866
1	1867
1	1868
1	1869
1	1870
1	1871
1	1872
1	1873
1	1874
1	1875
1	1876
1	1877
1	1878
1	1879
1	1880
1	1881
1	1882
1	1883
1	1884
1	1885
1	1886
1	1887
1	1888
1	1889
1	1890
1	1891
1	1892
1	2099
1	2100
1	2101
1	2102
1	2103
1	2104
1	2105
1	2106
1	2107
1	2108
1	2109
1	2110
1	2111
1	2112
1	2554
1	2555
1	2556
1	2557
1	2558
1	2559
1	2560
1	2561
1	2562
1	2563
1	2564
1	3132
1	3133
1	3134
1	3135
1	3136
1	3137
1	3138
1	3139
1	3140
1	3141
1	3142
1	3143
1	3144
1	3145
1	3256
1	3467
1	3468
1	3469
1	3470
1	3471
1	3472
1	3473
1	3474
1	3475
1	3476
1	3477
1	3262
1	3268
1	3263
1	3266
1	3255
1	3259
1	3260
1	3273
1	3265
1	3274
1	3267
1	3261
1	3272
1	3257
1	3258
1	3270
1	3271
1	3254
1	3275
1	3269
1	3253
1	3264
1	3455
1	3456
1	3457
1	3458
1	3459
1	3460
1	3461
1	3462
1	3463
1	3464
1	3465
1	3466
1	1414
1	1415
1	1416
1	1417
1	1418
1	1419
1	1420
1	1421
1	1422
1	1423
1	1424
1	1425
1	1426
1	1427
1	1428
1	1429
1	1430
1	1431
1	1432
1	1433
1	1444
1	1445
1	1446
1	1447
1	1448
1	1449
1	1450
1	1451
1	1452
1	1453
1	1454
1	1773
1	1774
1	1775
1	1776
1	1777
1	1778
1	1779
1	1780
1	1781
1	1782
1	1783
1	1784
1	1785
1	1786
1	1787
1	1788
1	1789
1	1790
1	301
1	302
1	303
1	304
1	305
1	306
1	307
1	308
1	309
1	311
1	2216
1	2217
1	2218
1	2219
1	2220
1	2221
1	2222
1	2223
1	2224
1	2225
1	2226
1	2227
1	2228
1	3038
1	3039
1	3040
1	3041
1	3042
1	3043
1	3044
1	3045
1	3046
1	3047
1	3048
1	3049
1	3050
1	3051
1	1
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
1	21
1	22
1	2
1	3
1	4
1	5
1	23
1	24
1	25
1	26
1	27
1	28
1	29
1	30
1	31
1	32
1	33
1	34
1	35
1	36
1	37
1	38
1	39
1	40
1	41
1	42
1	43
1	44
1	45
1	46
1	47
1	48
1	49
1	50
1	51
1	52
1	53
1	54
1	55
1	56
1	57
1	58
1	59
1	60
1	61
1	62
1	85
1	86
1	87
1	88
1	89
1	90
1	91
1	92
1	93
1	94
1	95
1	96
1	97
1	98
1	675
1	676
1	677
1	678
1	679
1	680
1	681
1	682
1	683
1	684
1	685
1	686
1	687
1	688
1	689
1	690
1	691
1	692
1	693
1	694
1	695
1	696
1	697
1	698
1	699
1	700
1	701
1	702
1	703
1	704
1	705
1	706
1	707
1	708
1	709
1	710
1	711
1	712
1	713
1	714
1	2609
1	2610
1	2611
1	2612
1	2613
1	2614
1	2615
1	2616
1	2617
1	2618
1	2619
1	2620
1	2621
1	2622
1	2623
1	2624
1	2625
1	2626
1	2627
1	2628
1	2629
1	2630
1	2631
1	2632
1	2633
1	2634
1	2635
1	2636
1	2637
1	2638
1	489
1	490
1	491
1	492
1	493
1	494
1	495
1	496
1	497
1	498
1	499
1	500
1	816
1	817
1	818
1	819
1	820
1	821
1	822
1	823
1	824
1	825
1	745
1	746
1	747
1	748
1	749
1	750
1	751
1	752
1	753
1	754
1	755
1	756
1	757
1	758
1	759
1	760
1	620
1	621
1	622
1	623
1	761
1	762
1	763
1	764
1	765
1	766
1	767
1	768
1	769
1	770
1	771
1	772
1	773
1	774
1	775
1	776
1	777
1	778
1	779
1	780
1	781
1	782
1	783
1	784
1	785
1	543
1	544
1	545
1	546
1	547
1	548
1	549
1	786
1	787
1	788
1	789
1	790
1	791
1	792
1	793
1	794
1	795
1	796
1	797
1	798
1	799
1	800
1	801
1	802
1	803
1	804
1	805
1	806
1	807
1	808
1	809
1	810
1	811
1	812
1	813
1	814
1	815
1	826
1	827
1	828
1	829
1	830
1	831
1	832
1	833
1	834
1	835
1	836
1	837
1	838
1	839
1	840
1	841
1	2639
1	2640
1	2641
1	2642
1	2643
1	2644
1	2645
1	2646
1	2647
1	2648
1	2649
1	3225
1	949
1	950
1	951
1	952
1	953
1	954
1	955
1	956
1	957
1	958
1	959
1	960
1	961
1	962
1	963
1	1020
1	1021
1	1022
1	1023
1	1024
1	1025
1	1026
1	1027
1	1028
1	1029
1	1030
1	1031
1	1032
1	989
1	990
1	991
1	992
1	993
1	994
1	995
1	996
1	997
1	998
1	999
1	1000
1	1001
1	1002
1	1003
1	1004
1	1005
1	1006
1	1007
1	1008
1	351
1	352
1	353
1	354
1	355
1	356
1	357
1	358
1	359
1	1146
1	1147
1	1148
1	1149
1	1150
1	1151
1	1152
1	1153
1	1154
1	1155
1	1156
1	1157
1	1158
1	1159
1	1160
1	1161
1	1162
1	1163
1	1164
1	1165
1	1166
1	1167
1	1168
1	1169
1	1170
1	1171
1	1172
1	1173
1	1235
1	1236
1	1237
1	1238
1	1239
1	1240
1	1241
1	1242
1	1243
1	1244
1	1256
1	1257
1	1258
1	1259
1	1260
1	1261
1	1262
1	1263
1	1264
1	1265
1	1266
1	1267
1	1305
1	1306
1	1307
1	1308
1	1309
1	1310
1	1311
1	1312
1	1313
1	1314
1	1315
1	1316
1	1317
1	1318
1	1319
1	1320
1	1321
1	1322
1	1323
1	1324
1	1201
1	1202
1	1203
1	1204
1	1205
1	1206
1	1207
1	1208
1	1209
1	1210
1	1211
1	1393
1	1362
1	1363
1	1365
1	1366
1	1367
1	1368
1	1369
1	1370
1	1406
1	1407
1	1408
1	1409
1	1410
1	1411
1	1412
1	1413
1	1395
1	1396
1	1397
1	1398
1	1399
1	1400
1	1401
1	1402
1	1403
1	1404
1	1405
1	1434
1	1435
1	1436
1	1437
1	1438
1	1439
1	1440
1	1441
1	1442
1	1443
1	1479
1	1480
1	1481
1	1482
1	1483
1	1484
1	1485
1	1486
1	1487
1	1488
1	1489
1	1490
1	1491
1	1492
1	1493
1	1494
1	1495
1	1496
1	1497
1	1498
1	1499
1	1500
1	1501
1	1502
1	1503
1	1504
1	1505
1	436
1	437
1	438
1	439
1	440
1	441
1	442
1	443
1	444
1	445
1	446
1	447
1	448
1	449
1	450
1	451
1	452
1	453
1	454
1	455
1	1562
1	1563
1	1564
1	1565
1	1566
1	1567
1	1568
1	1569
1	1570
1	1571
1	1572
1	1573
1	1574
1	1575
1	1576
1	337
1	338
1	339
1	340
1	341
1	342
1	343
1	344
1	345
1	346
1	347
1	348
1	349
1	350
1	1577
1	1578
1	1579
1	1580
1	1581
1	1582
1	1583
1	1584
1	1585
1	1586
1	1587
1	1588
1	1589
1	1590
1	1591
1	1592
1	1593
1	1594
1	1595
1	1596
1	1597
1	1598
1	1599
1	1600
1	1601
1	1602
1	1603
1	1604
1	1605
1	1606
1	1607
1	1608
1	1609
1	1610
1	1611
1	1612
1	1613
1	1614
1	1615
1	1616
1	1617
1	1618
1	1619
1	1620
1	1621
1	1622
1	1623
1	1624
1	1625
1	1626
1	1627
1	1628
1	1629
1	1630
1	1631
1	1632
1	1633
1	1634
1	1635
1	1636
1	1637
1	1638
1	1639
1	1640
1	1641
1	1642
1	1643
1	1644
1	1645
1	550
1	551
1	552
1	553
1	554
1	555
1	1646
1	1647
1	1648
1	1649
1	1650
1	1651
1	1652
1	1653
1	1654
1	1655
1	1656
1	1657
1	1658
1	1659
1	1660
1	1661
1	1662
1	1663
1	1664
1	1665
1	1666
1	1667
1	1668
1	1669
1	1670
1	1702
1	1703
1	1704
1	1705
1	1706
1	1707
1	1708
1	1709
1	1710
1	1711
1	1712
1	1713
1	1714
1	1715
1	1716
1	1745
1	1746
1	1747
1	1748
1	1749
1	1750
1	1751
1	1752
1	1753
1	1754
1	1791
1	1792
1	1793
1	1794
1	1795
1	1796
1	1797
1	1798
1	1799
1	1800
1	1986
1	1987
1	1988
1	1989
1	1990
1	1991
1	1992
1	1993
1	1994
1	1995
1	1996
1	1997
1	1998
1	1999
1	2000
1	2001
1	2002
1	2003
1	2004
1	2005
1	2006
1	2007
1	2008
1	2009
1	2010
1	2011
1	2012
1	2013
1	2014
1	2093
1	2094
1	2095
1	2096
1	2097
1	2098
1	3276
1	3277
1	3278
1	3279
1	3280
1	3281
1	3282
1	3283
1	3284
1	3285
1	3286
1	3287
1	2113
1	2114
1	2115
1	2116
1	2117
1	2118
1	2119
1	2120
1	2121
1	2122
1	2123
1	2124
1	2139
1	2140
1	2141
1	2142
1	2143
1	2144
1	2145
1	2146
1	2147
1	2148
1	2149
1	2150
1	2151
1	2152
1	2153
1	2154
1	2155
1	2156
1	2157
1	2158
1	2159
1	2160
1	2161
1	2162
1	2163
1	2164
1	2178
1	2179
1	2180
1	2181
1	2182
1	2183
1	2184
1	2185
1	2186
1	2187
1	2188
1	2189
1	2190
1	2191
1	2192
1	2193
1	2194
1	2195
1	2196
1	2197
1	2198
1	2199
1	2200
1	2201
1	2202
1	2203
1	2204
1	2205
1	2206
1	2207
1	2208
1	2209
1	2210
1	2211
1	2212
1	2213
1	2214
1	2215
1	2229
1	2230
1	2231
1	2232
1	2233
1	2234
1	2235
1	2236
1	2237
1	2650
1	2651
1	2652
1	2653
1	2654
1	2655
1	2656
1	2657
1	2658
1	2659
1	2660
1	2661
1	2662
1	2663
1	3353
1	3355
1	2254
1	2255
1	2256
1	2257
1	2258
1	2259
1	2260
1	2261
1	2262
1	2263
1	2264
1	2265
1	2266
1	2267
1	2268
1	2269
1	2270
1	419
1	420
1	421
1	422
1	423
1	424
1	425
1	426
1	427
1	428
1	429
1	430
1	431
1	432
1	433
1	434
1	435
1	2271
1	2272
1	2273
1	2274
1	2275
1	2276
1	2277
1	2278
1	2279
1	2280
1	2281
1	2296
1	2297
1	2298
1	2299
1	2300
1	2301
1	2302
1	2303
1	2304
1	2305
1	2306
1	2307
1	2308
1	2309
1	2344
1	2345
1	2346
1	2347
1	2348
1	2349
1	2350
1	2351
1	2353
1	2357
1	2375
1	2376
1	2377
1	2378
1	2379
1	2380
1	2381
1	2382
1	2383
1	2384
1	2385
1	2386
1	2387
1	2388
1	2389
1	2390
1	2391
1	2392
1	2393
1	2394
1	2395
1	2396
1	2397
1	2398
1	2399
1	2400
1	2401
1	2402
1	2403
1	2404
1	2405
1	2664
1	2665
1	2666
1	2667
1	2668
1	2669
1	2670
1	2671
1	2672
1	2673
1	2674
1	2675
1	2676
1	2677
1	2678
1	2679
1	2680
1	2681
1	2682
1	2683
1	2684
1	2685
1	2686
1	2687
1	2688
1	2689
1	2690
1	2691
1	2692
1	2693
1	2694
1	2695
1	2696
1	2697
1	2698
1	2699
1	2700
1	2701
1	2702
1	2703
1	2704
1	2406
1	2407
1	2408
1	2409
1	2410
1	2411
1	2412
1	2413
1	2414
1	2415
1	2416
1	2417
1	2418
1	2419
1	2420
1	2421
1	2422
1	2423
1	2424
1	2425
1	2426
1	2427
1	2428
1	2429
1	2430
1	2431
1	2432
1	2433
1	570
1	573
1	577
1	580
1	581
1	571
1	579
1	582
1	572
1	575
1	578
1	574
1	576
1	3288
1	3289
1	3290
1	3291
1	3292
1	3293
1	3294
1	3295
1	3296
1	3297
1	3298
1	3299
1	2434
1	2435
1	2436
1	2437
1	2438
1	2439
1	2440
1	2441
1	2442
1	2443
1	2444
1	2445
1	2446
1	2447
1	2448
1	2451
1	2455
1	2458
1	2459
1	2506
1	2507
1	2508
1	2509
1	2510
1	2511
1	2512
1	2513
1	2514
1	2515
1	2516
1	2517
1	2518
1	2519
1	2520
1	2521
1	2522
1	2542
1	2543
1	2544
1	2545
1	2546
1	2547
1	2548
1	2549
1	2550
1	2551
1	2552
1	2553
1	2565
1	2566
1	2567
1	2568
1	2569
1	2570
1	2571
1	2926
1	2927
1	2928
1	2929
1	2930
1	2931
1	2932
1	2933
1	2934
1	2935
1	2936
1	2937
1	2938
1	2939
1	2940
1	2941
1	2942
1	2943
1	2944
1	2945
1	2946
1	2947
1	2948
1	2949
1	2950
1	2951
1	2952
1	2953
1	2954
1	2955
1	2956
1	2957
1	2958
1	2959
1	2960
1	2961
1	2962
1	2963
1	3004
1	3005
1	3006
1	3007
1	3008
1	3009
1	3010
1	3011
1	3012
1	3013
1	3014
1	3015
1	3016
1	3017
1	2964
1	2965
1	2966
1	2967
1	2968
1	2969
1	2970
1	2971
1	2972
1	2973
1	2974
1	2975
1	2976
1	2977
1	2978
1	2979
1	2980
1	2981
1	2982
1	2983
1	2984
1	2985
1	2986
1	2987
1	2988
1	2989
1	2990
1	2991
1	2992
1	2993
1	2994
1	2995
1	2996
1	2997
1	2998
1	2999
1	3000
1	3001
1	3002
1	3003
1	3018
1	3019
1	3020
1	3021
1	3022
1	3023
1	3024
1	3025
1	3026
1	3027
1	3028
1	3029
1	3030
1	3031
1	3032
1	3033
1	3034
1	3035
1	3036
1	3037
1	3064
1	3065
1	3066
1	3067
1	3068
1	3069
1	3070
1	3071
1	3072
1	3073
1	3074
1	3075
1	3076
1	3077
1	3078
1	3079
1	3080
1	3052
1	3053
1	3054
1	3055
1	3056
1	3057
1	3058
1	3059
1	3060
1	3061
1	3062
1	3063
1	3081
1	3082
1	3083
1	3084
1	3085
1	3086
1	3087
1	3088
1	3089
1	3090
1	3091
1	3092
1	3093
1	3094
1	3095
1	3096
1	3097
1	3098
1	3099
1	3100
1	3101
1	3102
1	3103
1	3104
1	3105
1	3106
1	3107
1	3108
1	3109
1	3110
1	3111
1	3112
1	3113
1	3114
1	3115
1	3116
1	2731
1	2732
1	2733
1	2734
1	2735
1	2736
1	2737
1	2738
1	2739
1	2740
1	2741
1	2742
1	2743
1	2744
1	2745
1	2746
1	2747
1	2748
1	2749
1	2750
1	111
1	112
1	113
1	114
1	115
1	116
1	117
1	118
1	119
1	120
1	121
1	122
1	2125
1	2126
1	2127
1	2128
1	2129
1	2130
1	2131
1	2132
1	2133
1	2134
1	2135
1	2136
1	2137
1	2138
1	3503
1	360
1	361
1	362
1	363
1	364
1	365
1	366
1	367
1	368
1	369
1	370
1	371
1	372
1	373
3	3250
3	2819
3	2820
3	2821
3	2822
3	2823
3	2824
3	2825
3	2826
3	2827
3	2828
3	2829
3	2830
3	2831
3	2832
3	2833
3	2834
3	2835
3	2836
3	2837
3	2838
3	3226
3	3227
3	3228
3	3229
3	3230
3	3231
3	3232
3	3233
3	3234
3	3235
3	3236
3	3237
3	3238
3	3239
3	3240
3	3241
3	3242
3	3243
3	3244
3	3245
3	3246
3	3247
3	3248
3	3249
3	2839
3	2840
3	2841
3	2842
3	2843
3	2844
3	2845
3	2846
3	2847
3	2848
3	2849
3	2850
3	2851
3	2852
3	2853
3	2854
3	2855
3	2856
3	3166
3	3167
3	3168
3	3171
3	3223
3	2858
3	2861
3	2865
3	2868
3	2871
3	2873
3	2877
3	2880
3	2883
3	2885
3	2888
3	2893
3	2894
3	2898
3	2901
3	2904
3	2906
3	2911
3	2913
3	2915
3	2917
3	2919
3	2921
3	2923
3	2925
3	2859
3	2860
3	2864
3	2867
3	2869
3	2872
3	2878
3	2879
3	2884
3	2887
3	2889
3	2892
3	2896
3	2897
3	2902
3	2905
3	2907
3	2910
3	2914
3	2916
3	2918
3	2920
3	2922
3	2924
3	2857
3	2862
3	2863
3	2866
3	2870
3	2874
3	2875
3	2876
3	2881
3	2882
3	2886
3	2890
3	2891
3	2895
3	2899
3	2903
3	2908
3	2909
3	2912
3	3165
3	3169
3	3170
3	3252
3	3224
3	3251
3	3340
3	3339
3	3338
3	3337
3	3341
3	3345
3	3342
3	3346
3	3343
3	3347
3	3344
3	3348
3	3360
3	3361
3	3362
3	3363
3	3364
3	3172
3	3173
3	3174
3	3175
3	3176
3	3177
3	3178
3	3179
3	3180
3	3181
3	3182
3	3183
3	3184
3	3185
3	3186
3	3187
3	3188
3	3189
3	3190
3	3191
3	3192
3	3193
3	3194
3	3195
3	3196
3	3197
3	3198
3	3199
3	3200
3	3201
3	3202
3	3203
3	3204
3	3205
3	3206
3	3428
3	3207
3	3208
3	3209
3	3210
3	3211
3	3212
3	3429
3	3213
3	3214
3	3215
3	3216
3	3217
3	3218
3	3219
3	3220
3	3221
3	3222
8	3427
8	3357
8	1
8	6
8	7
8	8
8	9
8	10
8	11
8	12
8	13
8	14
8	15
8	16
8	17
8	18
8	19
8	20
8	21
8	22
8	3411
8	3412
8	2
8	3
8	4
8	5
8	23
8	24
8	25
8	26
8	27
8	28
8	29
8	30
8	31
8	32
8	33
8	34
8	35
8	36
8	37
8	3256
8	3350
8	3349
8	38
8	39
8	40
8	41
8	42
8	43
8	44
8	45
8	46
8	47
8	48
8	49
8	50
8	3403
8	51
8	52
8	53
8	54
8	55
8	56
8	57
8	58
8	59
8	60
8	61
8	62
8	3406
8	77
8	78
8	79
8	80
8	81
8	82
8	83
8	84
8	85
8	86
8	87
8	88
8	89
8	90
8	91
8	92
8	93
8	94
8	95
8	96
8	97
8	98
8	99
8	100
8	101
8	102
8	103
8	104
8	105
8	106
8	107
8	108
8	109
8	110
8	3402
8	3389
8	3390
8	3391
8	3392
8	3393
8	3394
8	3395
8	3396
8	3397
8	3398
8	3399
8	3400
8	3401
8	3262
8	382
8	111
8	112
8	113
8	114
8	115
8	116
8	117
8	118
8	119
8	120
8	121
8	122
8	3421
8	3268
8	3413
8	3263
8	123
8	124
8	125
8	126
8	127
8	128
8	129
8	130
8	2572
8	2573
8	2574
8	2575
8	2576
8	2577
8	2578
8	2579
8	2580
8	2581
8	2582
8	2583
8	2584
8	2585
8	2586
8	2587
8	2588
8	2589
8	2590
8	3266
8	131
8	132
8	133
8	134
8	135
8	136
8	137
8	138
8	139
8	140
8	141
8	142
8	143
8	144
8	145
8	146
8	147
8	148
8	149
8	150
8	151
8	152
8	153
8	154
8	155
8	156
8	157
8	158
8	159
8	160
8	161
8	162
8	163
8	164
8	165
8	166
8	167
8	168
8	169
8	170
8	171
8	172
8	173
8	174
8	175
8	176
8	177
8	178
8	179
8	180
8	181
8	182
8	3426
8	3416
8	183
8	184
8	185
8	186
8	187
8	188
8	189
8	190
8	191
8	192
8	193
8	194
8	195
8	196
8	197
8	198
8	199
8	200
8	201
8	202
8	203
8	204
8	515
8	516
8	517
8	518
8	519
8	520
8	521
8	522
8	523
8	524
8	525
8	526
8	527
8	528
8	206
8	208
8	209
8	210
8	211
8	213
8	214
8	215
8	216
8	218
8	219
8	220
8	222
8	223
8	224
8	3336
8	3324
8	3417
8	226
8	228
8	229
8	230
8	231
8	232
8	234
8	236
8	237
8	239
8	240
8	241
8	243
8	3375
8	3376
8	3377
8	3378
8	3379
8	3380
8	3381
8	3382
8	3383
8	3384
8	3385
8	3386
8	3387
8	3388
8	3255
8	301
8	302
8	303
8	304
8	305
8	306
8	307
8	308
8	309
8	311
8	2591
8	2592
8	2593
8	2594
8	2595
8	2596
8	2597
8	2598
8	2599
8	2600
8	2601
8	2602
8	2603
8	2604
8	2605
8	2606
8	2607
8	2608
8	3259
8	675
8	676
8	677
8	678
8	679
8	680
8	681
8	682
8	683
8	684
8	685
8	686
8	687
8	688
8	689
8	690
8	691
8	692
8	693
8	694
8	695
8	696
8	697
8	698
8	699
8	700
8	701
8	702
8	703
8	704
8	705
8	706
8	707
8	708
8	709
8	710
8	711
8	712
8	713
8	714
8	2609
8	2610
8	2611
8	2612
8	2613
8	2614
8	2615
8	2616
8	2617
8	2618
8	2619
8	2620
8	2621
8	2622
8	2623
8	2624
8	2625
8	2626
8	2627
8	2628
8	2629
8	2630
8	2631
8	2632
8	2633
8	2634
8	2635
8	2636
8	2637
8	2638
8	489
8	490
8	491
8	492
8	493
8	494
8	495
8	496
8	497
8	498
8	499
8	500
8	816
8	817
8	818
8	819
8	820
8	821
8	822
8	823
8	824
8	825
8	745
8	746
8	747
8	748
8	749
8	750
8	751
8	752
8	753
8	754
8	755
8	756
8	757
8	758
8	759
8	760
8	620
8	621
8	622
8	623
8	761
8	762
8	763
8	764
8	765
8	766
8	767
8	768
8	769
8	770
8	771
8	772
8	773
8	774
8	775
8	776
8	777
8	778
8	779
8	780
8	781
8	782
8	783
8	784
8	785
8	543
8	544
8	545
8	546
8	547
8	548
8	549
8	786
8	787
8	788
8	789
8	790
8	791
8	792
8	793
8	794
8	795
8	796
8	797
8	798
8	799
8	800
8	801
8	802
8	803
8	804
8	805
8	806
8	807
8	808
8	809
8	810
8	811
8	812
8	813
8	814
8	815
8	826
8	827
8	828
8	829
8	830
8	831
8	832
8	833
8	834
8	835
8	836
8	837
8	838
8	839
8	840
8	841
8	842
8	843
8	844
8	845
8	846
8	847
8	848
8	849
8	850
8	3260
8	3331
8	852
8	853
8	854
8	855
8	858
8	859
8	860
8	862
8	863
8	864
8	865
8	866
8	868
8	869
8	871
8	872
8	873
8	874
8	875
8	876
8	2639
8	2640
8	2641
8	2642
8	2643
8	2644
8	2645
8	2646
8	2647
8	2648
8	2649
8	3225
8	584
8	586
8	587
8	589
8	590
8	591
8	592
8	593
8	594
8	596
8	3405
8	891
8	892
8	893
8	894
8	895
8	896
8	897
8	898
8	899
8	900
8	901
8	902
8	903
8	904
8	905
8	906
8	907
8	908
8	909
8	910
8	911
8	912
8	913
8	914
8	915
8	916
8	917
8	918
8	919
8	920
8	921
8	922
8	3423
8	923
8	924
8	925
8	926
8	927
8	928
8	929
8	930
8	931
8	932
8	933
8	934
8	935
8	936
8	937
8	938
8	939
8	940
8	941
8	942
8	943
8	944
8	945
8	946
8	947
8	948
8	949
8	950
8	951
8	952
8	953
8	954
8	955
8	956
8	957
8	958
8	959
8	960
8	961
8	962
8	963
8	964
8	965
8	966
8	967
8	968
8	969
8	970
8	971
8	972
8	973
8	974
8	975
8	976
8	977
8	981
8	982
8	983
8	984
8	985
8	987
8	988
8	390
8	3273
8	1020
8	1021
8	1022
8	1023
8	1024
8	1025
8	1026
8	1027
8	1028
8	1029
8	1030
8	1031
8	1032
8	989
8	990
8	991
8	992
8	993
8	994
8	995
8	996
8	997
8	998
8	999
8	1000
8	1001
8	1002
8	1003
8	1004
8	1005
8	1006
8	1007
8	1008
8	1009
8	1010
8	1011
8	1012
8	1013
8	1014
8	1015
8	1016
8	1017
8	1018
8	1019
8	1034
8	1035
8	1036
8	1037
8	1038
8	1039
8	1040
8	1041
8	1042
8	1043
8	1044
8	1045
8	1046
8	1047
8	1048
8	1049
8	1050
8	1051
8	1052
8	1053
8	1054
8	1055
8	1056
8	351
8	352
8	353
8	354
8	355
8	356
8	357
8	358
8	359
8	3332
8	1057
8	1058
8	1059
8	1063
8	1064
8	1065
8	1066
8	1067
8	1069
8	1070
8	1071
8	1072
8	624
8	625
8	626
8	627
8	628
8	629
8	630
8	631
8	632
8	633
8	634
8	635
8	636
8	637
8	638
8	639
8	640
8	641
8	642
8	643
8	644
8	645
8	377
8	1088
8	1089
8	1090
8	1091
8	1092
8	1093
8	1094
8	1095
8	1098
8	1099
8	1100
8	1101
8	1105
8	1106
8	1107
8	1108
8	1111
8	1112
8	1113
8	1115
8	1116
8	1118
8	1119
8	1121
8	1122
8	1123
8	1124
8	1125
8	1126
8	1127
8	1128
8	1129
8	1130
8	1131
8	1132
8	501
8	505
8	507
8	509
8	512
8	514
8	1134
8	1137
8	1138
8	1139
8	1140
8	1141
8	1142
8	1145
8	3265
8	468
8	469
8	470
8	471
8	472
8	473
8	474
8	475
8	476
8	477
8	478
8	479
8	480
8	481
8	482
8	483
8	484
8	485
8	486
8	487
8	488
8	1146
8	1147
8	1148
8	1149
8	1150
8	1151
8	1152
8	1153
8	1154
8	1155
8	1156
8	1157
8	1158
8	1159
8	1160
8	1161
8	1162
8	1163
8	1164
8	1165
8	1166
8	1167
8	1168
8	1169
8	1170
8	1171
8	1172
8	1173
8	1174
8	1175
8	1176
8	1177
8	1178
8	1179
8	1180
8	1181
8	1182
8	1183
8	1184
8	1185
8	1186
8	1187
8	3322
8	3407
8	3301
8	3300
8	3302
8	3303
8	3304
8	3305
8	3306
8	3307
8	3308
8	3309
8	3310
8	3311
8	3312
8	3313
8	3314
8	3315
8	3316
8	3317
8	3318
8	1188
8	1189
8	1190
8	1191
8	1192
8	1193
8	1194
8	1195
8	1196
8	1197
8	1198
8	1199
8	1200
8	3329
8	1235
8	1236
8	1237
8	1238
8	1239
8	1240
8	1241
8	1242
8	1243
8	1244
8	1245
8	1246
8	1247
8	1248
8	1249
8	1250
8	1251
8	1252
8	1253
8	1254
8	1255
8	1256
8	1257
8	1258
8	1259
8	1260
8	1261
8	1262
8	1263
8	1264
8	1265
8	1266
8	1267
8	1268
8	1269
8	1272
8	1273
8	1274
8	1275
8	1276
8	1277
8	1278
8	1279
8	1280
8	1281
8	1283
8	1284
8	1285
8	1286
8	1287
8	1288
8	1289
8	1290
8	1291
8	1292
8	1293
8	1294
8	1295
8	1296
8	1297
8	1298
8	1299
8	1300
8	1301
8	1302
8	1303
8	1304
8	1305
8	1306
8	1307
8	1308
8	1309
8	1310
8	1311
8	1312
8	1313
8	1314
8	1315
8	1316
8	1317
8	1318
8	1319
8	1320
8	1321
8	1322
8	1323
8	1324
8	1201
8	1202
8	1203
8	1204
8	1205
8	1206
8	1207
8	1208
8	1209
8	1210
8	1211
8	1325
8	1326
8	1327
8	1328
8	1329
8	1330
8	1331
8	1332
8	1333
8	1334
8	1391
8	1393
8	1388
8	1394
8	1387
8	1392
8	1389
8	1390
8	1335
8	1336
8	1337
8	1338
8	1339
8	1340
8	1341
8	1342
8	1343
8	1344
8	1345
8	1346
8	1347
8	1348
8	1349
8	1350
8	1351
8	1212
8	1213
8	1214
8	1215
8	1216
8	1217
8	1218
8	1219
8	1220
8	1221
8	1222
8	1223
8	1224
8	1225
8	1226
8	1227
8	1228
8	1229
8	1230
8	1231
8	1232
8	1233
8	1234
8	1352
8	1353
8	1354
8	1355
8	1356
8	1357
8	1358
8	1359
8	1360
8	1361
8	1362
8	1363
8	1364
8	1365
8	1366
8	1367
8	1368
8	1369
8	1370
8	1371
8	1372
8	1373
8	1374
8	1375
8	1376
8	1377
8	1378
8	1379
8	1380
8	1381
8	1382
8	1386
8	1383
8	1385
8	1384
8	1406
8	1407
8	1408
8	1409
8	1410
8	1411
8	1412
8	1413
8	1395
8	1396
8	1397
8	1398
8	1399
8	1400
8	1401
8	1402
8	1403
8	1404
8	1405
8	3274
8	3267
8	3261
8	3272
8	1414
8	1415
8	1416
8	1417
8	1418
8	1419
8	1420
8	1421
8	1422
8	1423
8	1424
8	1425
8	1426
8	1427
8	1428
8	1429
8	1430
8	1431
8	1432
8	1433
8	1434
8	1435
8	1436
8	1437
8	1438
8	1439
8	1440
8	1441
8	1442
8	1443
8	1455
8	1456
8	1457
8	1458
8	1459
8	1460
8	1461
8	1462
8	1463
8	1464
8	1465
8	1444
8	1445
8	1446
8	1447
8	1448
8	1449
8	1450
8	1451
8	1452
8	1453
8	1454
8	1466
8	1467
8	1468
8	1469
8	1470
8	1471
8	1472
8	1473
8	1474
8	1475
8	1476
8	1477
8	1478
8	1479
8	1480
8	1481
8	1482
8	1483
8	1484
8	1485
8	1486
8	1487
8	1488
8	1489
8	1490
8	1491
8	1492
8	1493
8	1494
8	1495
8	378
8	1496
8	1497
8	1498
8	1499
8	1500
8	1501
8	1502
8	1503
8	1504
8	1505
8	1506
8	1507
8	1508
8	1509
8	1513
8	1516
8	1517
8	1518
8	1519
8	381
8	1520
8	1521
8	1522
8	1523
8	1528
8	1529
8	1530
8	1531
8	1546
8	1547
8	1548
8	1549
8	1550
8	1551
8	1552
8	1553
8	1554
8	1555
8	1556
8	1557
8	1558
8	1559
8	1560
8	1561
8	3352
8	3358
8	436
8	437
8	438
8	439
8	440
8	441
8	442
8	443
8	444
8	445
8	446
8	447
8	448
8	449
8	450
8	451
8	452
8	453
8	454
8	455
8	1562
8	1563
8	1564
8	1565
8	1566
8	1567
8	1568
8	1569
8	1570
8	1571
8	1572
8	1573
8	1574
8	1575
8	1576
8	337
8	338
8	339
8	340
8	341
8	342
8	343
8	344
8	345
8	346
8	347
8	348
8	349
8	350
8	1577
8	1578
8	1579
8	1580
8	1581
8	1582
8	1583
8	1584
8	1585
8	1586
8	1587
8	1588
8	1589
8	1590
8	1591
8	1592
8	1593
8	1594
8	1595
8	1596
8	1597
8	1598
8	1599
8	1600
8	1601
8	1602
8	1603
8	1604
8	1605
8	1606
8	1607
8	1608
8	1609
8	1610
8	1611
8	1612
8	1613
8	1614
8	1615
8	1616
8	1617
8	1618
8	1619
8	1620
8	1621
8	1622
8	1623
8	1624
8	1625
8	1626
8	1627
8	1628
8	1629
8	1630
8	1631
8	1632
8	1633
8	1634
8	1635
8	1636
8	1637
8	1638
8	1639
8	1640
8	1641
8	1642
8	1643
8	1644
8	1645
8	550
8	551
8	552
8	553
8	554
8	555
8	1646
8	1647
8	1648
8	1649
8	1650
8	1651
8	1652
8	1653
8	1654
8	1655
8	1656
8	1657
8	1658
8	1659
8	1660
8	1661
8	1662
8	1663
8	1664
8	1665
8	1666
8	1667
8	1668
8	1669
8	1670
8	1702
8	1703
8	1704
8	1705
8	1706
8	1707
8	1708
8	1709
8	1710
8	1711
8	1712
8	1713
8	1714
8	1715
8	1716
8	3257
8	3425
8	3420
8	3326
8	3258
8	3356
8	3424
8	374
8	1745
8	1746
8	1747
8	1748
8	1749
8	1750
8	1751
8	1752
8	1753
8	1754
8	1755
8	1762
8	1763
8	1756
8	1764
8	1757
8	1765
8	1766
8	1759
8	1769
8	1770
8	1771
8	1772
8	1773
8	1774
8	1775
8	1776
8	1777
8	1778
8	1779
8	1780
8	1781
8	1782
8	1783
8	1784
8	1785
8	1786
8	1787
8	1788
8	1789
8	1790
8	3270
8	1791
8	1792
8	1793
8	1794
8	1795
8	1796
8	1797
8	1798
8	1799
8	1800
8	1893
8	1894
8	1895
8	1896
8	1897
8	1898
8	1899
8	1900
8	1901
8	1801
8	1802
8	1803
8	1804
8	1805
8	1806
8	1807
8	1808
8	1809
8	1810
8	1811
8	1812
8	408
8	409
8	410
8	411
8	412
8	413
8	414
8	415
8	416
8	417
8	418
8	1813
8	1814
8	1815
8	1816
8	1817
8	1818
8	1819
8	1820
8	1821
8	1822
8	1823
8	1824
8	1825
8	1826
8	1827
8	1828
8	1829
8	1830
8	1831
8	1832
8	1833
8	1834
8	1835
8	1836
8	1837
8	1838
8	1839
8	1840
8	1841
8	1842
8	1843
8	1844
8	1845
8	1846
8	1847
8	1848
8	1849
8	1850
8	1851
8	1852
8	1853
8	1854
8	1855
8	1856
8	1857
8	1858
8	1859
8	1860
8	1861
8	1862
8	1863
8	1864
8	1865
8	1866
8	1867
8	1868
8	1869
8	1870
8	1871
8	1872
8	1873
8	1874
8	1875
8	1876
8	1877
8	1878
8	1879
8	1880
8	1881
8	1882
8	1883
8	1884
8	1885
8	1886
8	1887
8	1888
8	1889
8	1890
8	1891
8	1892
8	597
8	598
8	599
8	600
8	601
8	602
8	603
8	604
8	605
8	606
8	607
8	608
8	609
8	610
8	611
8	612
8	613
8	614
8	615
8	616
8	617
8	618
8	619
8	1902
8	1903
8	1904
8	1905
8	1906
8	1907
8	1908
8	1909
8	1910
8	1911
8	1912
8	1913
8	1914
8	1915
8	1917
8	1919
8	1921
8	1922
8	1923
8	1925
8	1926
8	1928
8	1929
8	1931
8	1934
8	1935
8	1936
8	1937
8	1938
8	1939
8	1940
8	375
8	3327
8	3330
8	385
8	3321
8	383
8	3359
8	1986
8	1987
8	1988
8	1989
8	1990
8	1991
8	1992
8	1993
8	1994
8	1995
8	1996
8	1997
8	1998
8	1999
8	2000
8	2001
8	2002
8	2003
8	2004
8	2005
8	2006
8	2007
8	2008
8	2009
8	2010
8	2011
8	2012
8	2013
8	2014
8	3319
8	2030
8	2032
8	2035
8	2038
8	2039
8	2040
8	2042
8	2043
8	2065
8	2067
8	2068
8	2069
8	2070
8	2071
8	2072
8	2073
8	2074
8	2075
8	2079
8	2080
8	2081
8	2083
8	2084
8	2085
8	2086
8	2087
8	2088
8	2089
8	2090
8	2092
8	3328
8	2093
8	2094
8	2095
8	2096
8	2097
8	2098
8	3276
8	3277
8	3278
8	3279
8	3280
8	3281
8	3282
8	3283
8	3284
8	3285
8	3286
8	3287
8	2099
8	2100
8	2101
8	2102
8	2103
8	2104
8	2105
8	2106
8	2107
8	2108
8	2109
8	2110
8	2111
8	2112
8	2113
8	2114
8	2115
8	2116
8	2117
8	2118
8	2119
8	2120
8	2121
8	2122
8	2123
8	2124
8	2125
8	2126
8	2127
8	2128
8	2129
8	2130
8	2131
8	2132
8	2133
8	2134
8	2135
8	2136
8	2137
8	2138
8	2139
8	2140
8	2141
8	2142
8	2143
8	2144
8	2145
8	2146
8	2147
8	2148
8	2149
8	2150
8	2151
8	2152
8	2153
8	2154
8	2155
8	2156
8	2157
8	2158
8	2159
8	2160
8	2161
8	2162
8	2163
8	2164
8	2165
8	2166
8	2167
8	2168
8	2169
8	2170
8	2171
8	2172
8	2173
8	2174
8	2175
8	2176
8	2177
8	2178
8	2179
8	2180
8	2181
8	2182
8	2183
8	2184
8	2185
8	2186
8	2187
8	2188
8	2189
8	2190
8	2191
8	2192
8	2193
8	2194
8	2195
8	2196
8	2197
8	2198
8	2199
8	2200
8	2201
8	2202
8	2203
8	2204
8	2205
8	2206
8	2207
8	2208
8	2209
8	2210
8	2211
8	2212
8	2213
8	2214
8	2215
8	386
8	3325
8	2216
8	2217
8	2218
8	2219
8	2220
8	2221
8	2222
8	2223
8	2224
8	2225
8	2226
8	2227
8	2228
8	2229
8	2230
8	2231
8	2232
8	2233
8	2234
8	2235
8	2236
8	2237
8	2650
8	2651
8	2652
8	2653
8	2654
8	2655
8	2656
8	2657
8	2658
8	2659
8	2660
8	2661
8	2662
8	2663
8	3353
8	3355
8	3271
8	2254
8	2255
8	2256
8	2257
8	2258
8	2259
8	2260
8	2261
8	2262
8	2263
8	2264
8	2265
8	2266
8	2267
8	2268
8	2269
8	2270
8	419
8	420
8	421
8	422
8	423
8	424
8	425
8	426
8	427
8	428
8	429
8	430
8	431
8	432
8	433
8	434
8	435
8	2271
8	2272
8	2273
8	2274
8	2275
8	2276
8	2277
8	2278
8	2279
8	2280
8	2281
8	2318
8	2319
8	2320
8	2321
8	2322
8	2323
8	2324
8	2325
8	2326
8	2327
8	2328
8	2329
8	2330
8	2331
8	2332
8	2333
8	2285
8	2286
8	2287
8	2288
8	2289
8	2290
8	2291
8	2292
8	2293
8	2294
8	2295
8	3254
8	2296
8	2297
8	2298
8	2299
8	2300
8	2301
8	2302
8	2303
8	2304
8	2305
8	2306
8	2307
8	2308
8	2309
8	2310
8	2311
8	2312
8	2313
8	2314
8	2315
8	2316
8	2317
8	2282
8	2283
8	2284
8	2344
8	2345
8	2346
8	2347
8	2348
8	2349
8	2350
8	2351
8	2353
8	2357
8	2358
8	2359
8	2360
8	2361
8	2362
8	2363
8	2364
8	2365
8	2366
8	2367
8	2368
8	2369
8	2370
8	2371
8	2372
8	2373
8	2374
8	2375
8	2376
8	2377
8	2378
8	2379
8	2380
8	2381
8	2382
8	2383
8	2384
8	2385
8	2386
8	2387
8	2388
8	2389
8	2390
8	2391
8	2392
8	2393
8	2394
8	2395
8	2396
8	2397
8	2398
8	2399
8	2400
8	2401
8	2402
8	2403
8	2404
8	2405
8	3275
8	3404
8	3323
8	2664
8	2665
8	2666
8	2667
8	2668
8	2669
8	2670
8	2671
8	2672
8	2673
8	2674
8	2675
8	2676
8	2677
8	2678
8	2679
8	2680
8	2681
8	2682
8	2683
8	2684
8	2685
8	2686
8	2687
8	2688
8	2689
8	2690
8	2691
8	2692
8	2693
8	2694
8	2695
8	2696
8	2697
8	2698
8	2699
8	2700
8	2701
8	2702
8	2703
8	2704
8	3414
8	2406
8	2407
8	2408
8	2409
8	2410
8	2411
8	2412
8	2413
8	2414
8	2415
8	2416
8	2417
8	2418
8	2419
8	3334
8	2420
8	2421
8	2422
8	2423
8	2424
8	2425
8	2426
8	2427
8	2428
8	2429
8	2430
8	2431
8	2432
8	2433
8	570
8	573
8	577
8	580
8	581
8	571
8	579
8	582
8	572
8	575
8	578
8	574
8	576
8	3410
8	3288
8	3289
8	3290
8	3291
8	3292
8	3293
8	3294
8	3295
8	3296
8	3297
8	3298
8	3299
8	3333
8	2434
8	2435
8	2436
8	2437
8	2438
8	2439
8	2440
8	2441
8	2442
8	2443
8	2444
8	2445
8	2446
8	2447
8	2448
8	2451
8	2455
8	2458
8	2459
8	2472
8	2473
8	2474
8	2475
8	2476
8	2477
8	2478
8	2479
8	2480
8	2481
8	2482
8	2483
8	2484
8	2485
8	2486
8	2487
8	2488
8	2489
8	2490
8	2491
8	2492
8	2493
8	2494
8	2495
8	2496
8	2497
8	2498
8	2499
8	2500
8	2501
8	2502
8	2503
8	2504
8	2505
8	3269
8	2506
8	2507
8	2508
8	2509
8	2510
8	2511
8	2512
8	2513
8	2514
8	2515
8	2516
8	2517
8	2518
8	2519
8	2520
8	2521
8	2522
8	456
8	457
8	458
8	459
8	460
8	461
8	462
8	463
8	464
8	465
8	466
8	467
8	2523
8	2524
8	2525
8	2526
8	2527
8	2528
8	2529
8	2530
8	2531
8	3335
8	2532
8	2533
8	2534
8	2535
8	2536
8	2537
8	2538
8	2539
8	2540
8	2541
8	2542
8	2543
8	2544
8	2545
8	2546
8	2547
8	2548
8	2549
8	2550
8	2551
8	2552
8	2553
8	2554
8	2555
8	2556
8	2557
8	2558
8	2559
8	2560
8	2561
8	2562
8	2563
8	2564
8	2705
8	2706
8	2707
8	2708
8	2709
8	2710
8	2711
8	2712
8	2713
8	2714
8	2715
8	2716
8	2717
8	2718
8	2719
8	2720
8	2721
8	2722
8	2723
8	2724
8	2725
8	2726
8	2727
8	2728
8	2729
8	2730
8	3365
8	3366
8	3367
8	3368
8	3369
8	3370
8	3371
8	3372
8	3373
8	3374
8	2565
8	2566
8	2567
8	2568
8	2569
8	2570
8	2571
8	2751
8	2752
8	2753
8	2757
8	2763
8	2764
8	2766
8	2771
8	2772
8	2774
8	2776
8	2780
8	2926
8	2927
8	2928
8	2929
8	2930
8	2931
8	2932
8	2933
8	2934
8	2935
8	2936
8	2937
8	2938
8	2939
8	2940
8	2941
8	2942
8	2943
8	2944
8	2945
8	2946
8	2947
8	2948
8	2949
8	2950
8	2951
8	2952
8	2953
8	2954
8	2955
8	2956
8	2957
8	2958
8	2959
8	2960
8	2961
8	2962
8	2963
8	3004
8	3005
8	3006
8	3007
8	3008
8	3009
8	3010
8	3011
8	3012
8	3013
8	3014
8	3015
8	3016
8	3017
8	2964
8	2965
8	2966
8	2967
8	2968
8	2969
8	2970
8	2971
8	2972
8	2973
8	2974
8	3253
8	2975
8	2976
8	2977
8	2978
8	2979
8	2980
8	2981
8	2982
8	2983
8	2984
8	2985
8	2986
8	2987
8	2988
8	2989
8	2990
8	2991
8	2992
8	2993
8	2994
8	2995
8	2996
8	2997
8	2998
8	2999
8	3000
8	3001
8	3002
8	3003
8	3018
8	3019
8	3020
8	3021
8	3022
8	3023
8	3024
8	3025
8	3026
8	3027
8	3028
8	3029
8	3030
8	3031
8	3032
8	3033
8	3034
8	3035
8	3036
8	3037
8	3038
8	3039
8	3040
8	3041
8	3042
8	3043
8	3044
8	3045
8	3046
8	3047
8	3048
8	3049
8	3050
8	3051
8	3064
8	3065
8	3066
8	3067
8	3068
8	3069
8	3070
8	3071
8	3072
8	3073
8	3074
8	3075
8	3076
8	3077
8	3078
8	3079
8	3080
8	3052
8	3053
8	3054
8	3055
8	3056
8	3057
8	3058
8	3059
8	3060
8	3061
8	3062
8	3063
8	3081
8	3082
8	3083
8	3084
8	3085
8	3086
8	3087
8	3088
8	3089
8	3090
8	3091
8	3092
8	3093
8	3094
8	3095
8	3096
8	3097
8	3098
8	3099
8	3100
8	3101
8	3102
8	3103
8	360
8	361
8	362
8	363
8	364
8	365
8	366
8	367
8	368
8	369
8	370
8	371
8	372
8	373
8	556
8	557
8	558
8	559
8	560
8	561
8	565
8	566
8	569
8	664
8	665
8	667
8	670
8	672
8	673
8	3104
8	3105
8	3106
8	3107
8	3108
8	3109
8	3110
8	3111
8	3112
8	3113
8	3114
8	3115
8	3116
8	3132
8	3133
8	3134
8	3135
8	3136
8	3137
8	3138
8	3139
8	3140
8	3141
8	3142
8	3143
8	3144
8	3145
8	2731
8	2732
8	2733
8	2734
8	2735
8	2736
8	2737
8	2738
8	2739
8	2740
8	2741
8	2742
8	2743
8	2744
8	2745
8	2746
8	2747
8	2748
8	2749
8	2750
8	3320
8	3264
8	3149
8	3153
8	3155
8	3158
8	3160
8	3162
8	3164
8	3438
8	3436
8	3454
8	3432
8	3443
8	3447
8	3452
8	3441
8	3445
8	3453
8	3439
8	3435
8	3448
8	3437
8	3446
8	3444
8	3433
8	3431
8	3430
8	3455
8	3456
8	3457
8	3458
8	3459
8	3460
8	3461
8	3462
8	3463
8	3464
8	3465
8	3466
8	3467
8	3468
8	3469
8	3470
8	3471
8	3472
8	3473
8	3474
8	3475
8	3476
8	3477
8	3478
8	3482
8	3491
8	3501
8	3500
8	3488
8	3499
8	3497
8	3490
8	3492
8	3483
8	3493
8	3498
8	3502
8	3479
8	3481
8	3503
8	3486
8	3484
9	3402
10	3250
10	2819
10	2820
10	2821
10	2822
10	2823
10	2824
10	2825
10	2826
10	2827
10	2828
10	2829
10	2830
10	2831
10	2832
10	2833
10	2834
10	2835
10	2836
10	2837
10	2838
10	3226
10	3227
10	3228
10	3229
10	3230
10	3231
10	3232
10	3233
10	3234
10	3235
10	3236
10	3237
10	3238
10	3239
10	3240
10	3241
10	3242
10	3243
10	3244
10	3245
10	3246
10	3247
10	3248
10	3249
10	2839
10	2840
10	2841
10	2842
10	2843
10	2844
10	2845
10	2846
10	2847
10	2848
10	2849
10	2850
10	2851
10	2852
10	2853
10	2854
10	2855
10	2856
10	3166
10	3167
10	3168
10	3171
10	3223
10	2858
10	2861
10	2865
10	2868
10	2871
10	2873
10	2877
10	2880
10	2883
10	2885
10	2888
10	2893
10	2894
10	2898
10	2901
10	2904
10	2906
10	2911
10	2913
10	2915
10	2917
10	2919
10	2921
10	2923
10	2925
10	2859
10	2860
10	2864
10	2867
10	2869
10	2872
10	2878
10	2879
10	2884
10	2887
10	2889
10	2892
10	2896
10	2897
10	2902
10	2905
10	2907
10	2910
10	2914
10	2916
10	2918
10	2920
10	2922
10	2924
10	2857
10	2862
10	2863
10	2866
10	2870
10	2874
10	2875
10	2876
10	2881
10	2882
10	2886
10	2890
10	2891
10	2895
10	2899
10	2903
10	2908
10	2909
10	2912
10	3165
10	3169
10	3170
10	3252
10	3224
10	3251
10	3340
10	3339
10	3338
10	3337
10	3341
10	3345
10	3342
10	3346
10	3343
10	3347
10	3344
10	3348
10	3360
10	3361
10	3362
10	3363
10	3364
10	3172
10	3173
10	3174
10	3175
10	3176
10	3177
10	3178
10	3179
10	3180
10	3181
10	3182
10	3183
10	3184
10	3185
10	3186
10	3187
10	3188
10	3189
10	3190
10	3191
10	3192
10	3193
10	3194
10	3195
10	3196
10	3197
10	3198
10	3199
10	3200
10	3201
10	3202
10	3203
10	3204
10	3205
10	3206
10	3207
10	3208
10	3209
10	3210
10	3211
10	3212
10	3213
10	3214
10	3215
10	3216
10	3217
10	3218
10	3219
10	3220
10	3221
10	3222
10	3428
10	3429
11	516
11	523
11	219
11	220
11	215
11	228
11	230
11	236
11	852
11	858
11	864
11	874
11	1088
11	1093
11	1099
11	1105
11	501
11	1518
11	1519
11	1928
11	1921
11	2752
11	2753
12	3479
12	3481
12	3482
12	3483
12	3484
12	3486
12	3488
12	3490
12	3491
12	3492
12	3493
12	3497
12	3498
12	3499
12	3500
12	3501
12	3502
12	3503
12	3430
12	3431
12	3432
12	3433
12	3435
12	3436
12	3437
12	3438
12	3439
12	3441
12	3443
12	3444
12	3445
12	3446
12	3447
12	3448
12	3452
12	3453
12	3454
12	3403
12	3404
12	3405
12	3406
12	3407
12	3410
12	3411
12	3412
12	3413
12	3414
12	3416
12	3417
12	3420
12	3421
12	3423
12	3424
12	3425
12	3426
12	3427
13	3479
13	3481
13	3482
13	3483
13	3484
13	3486
13	3488
13	3490
13	3491
13	3492
13	3493
13	3497
13	3498
13	3499
13	3500
13	3501
13	3502
13	3503
14	3430
14	3431
14	3432
14	3433
14	3435
14	3436
14	3437
14	3438
14	3439
14	3441
14	3443
14	3444
14	3445
14	3446
14	3447
14	3448
14	3452
14	3453
14	3454
15	3403
15	3404
15	3405
15	3406
15	3407
15	3410
15	3411
15	3412
15	3413
15	3414
15	3416
15	3417
15	3420
15	3421
15	3423
15	3424
15	3425
15	3426
15	3427
16	3367
16	52
16	2194
16	2195
16	2198
16	2206
16	2512
16	2516
16	2550
16	2003
16	2004
16	2005
16	2007
16	2010
16	2013
17	1
17	2
17	3
17	4
17	5
17	152
17	160
17	1278
17	1283
17	1392
17	1335
17	1345
17	1380
17	1801
17	1830
17	1837
17	1854
17	1876
17	1880
17	2094
17	2095
17	2096
17	3290
18	597
\.


--
-- Data for Name: track; Type: TABLE DATA; Schema: public; Owner: admin_user
--

COPY track (trackid, name, albumid, mediatypeid, generoid, composer, milliseconds, bytes, unitprice) FROM stdin;
1	For Those About To Rock (We Salute You)	1	1	1	Angus Young, Malcolm Young, Brian Johnson	343719	11170334	$b 99,00
2	Balls to the Wall	2	2	1		342562	5510424	$b 99,00
3	Fast As a Shark	3	2	1	F. Baltes, S. Kaufman, U. Dirkscneider & W. Hoffman	230619	3990994	$b 99,00
4	Restless and Wild	3	2	1	F. Baltes, R.A. Smith-Diesel, S. Kaufman, U. Dirkscneider & W. Hoffman	252051	4331779	$b 99,00
5	Princess of the Dawn	3	2	1	Deaffy & R.A. Smith-Diesel	375418	6290521	$b 99,00
6	Put The Finger On You	1	1	1	Angus Young, Malcolm Young, Brian Johnson	205662	6713451	$b 99,00
7	Let's Get It Up	1	1	1	Angus Young, Malcolm Young, Brian Johnson	233926	7636561	$b 99,00
8	Inject The Venom	1	1	1	Angus Young, Malcolm Young, Brian Johnson	210834	6852860	$b 99,00
9	Snowballed	1	1	1	Angus Young, Malcolm Young, Brian Johnson	203102	6599424	$b 99,00
10	Evil Walks	1	1	1	Angus Young, Malcolm Young, Brian Johnson	263497	8611245	$b 99,00
11	C.O.D.	1	1	1	Angus Young, Malcolm Young, Brian Johnson	199836	6566314	$b 99,00
12	Breaking The Rules	1	1	1	Angus Young, Malcolm Young, Brian Johnson	263288	8596840	$b 99,00
13	Night Of The Long Knives	1	1	1	Angus Young, Malcolm Young, Brian Johnson	205688	6706347	$b 99,00
14	Spellbound	1	1	1	Angus Young, Malcolm Young, Brian Johnson	270863	8817038	$b 99,00
15	Go Down	4	1	1	AC/DC	331180	10847611	$b 99,00
16	Dog Eat Dog	4	1	1	AC/DC	215196	7032162	$b 99,00
17	Let There Be Rock	4	1	1	AC/DC	366654	12021261	$b 99,00
18	Bad Boy Boogie	4	1	1	AC/DC	267728	8776140	$b 99,00
19	Problem Child	4	1	1	AC/DC	325041	10617116	$b 99,00
20	Overdose	4	1	1	AC/DC	369319	12066294	$b 99,00
21	Hell Ain't A Bad Place To Be	4	1	1	AC/DC	254380	8331286	$b 99,00
22	Whole Lotta Rosie	4	1	1	AC/DC	323761	10547154	$b 99,00
23	Walk On Water	5	1	1	Steven Tyler, Joe Perry, Jack Blades, Tommy Shaw	295680	9719579	$b 99,00
24	Love In An Elevator	5	1	1	Steven Tyler, Joe Perry	321828	10552051	$b 99,00
25	Rag Doll	5	1	1	Steven Tyler, Joe Perry, Jim Vallance, Holly Knight	264698	8675345	$b 99,00
26	What It Takes	5	1	1	Steven Tyler, Joe Perry, Desmond Child	310622	10144730	$b 99,00
27	Dude (Looks Like A Lady)	5	1	1	Steven Tyler, Joe Perry, Desmond Child	264855	8679940	$b 99,00
28	Janie's Got A Gun	5	1	1	Steven Tyler, Tom Hamilton	330736	10869391	$b 99,00
29	Cryin'	5	1	1	Steven Tyler, Joe Perry, Taylor Rhodes	309263	10056995	$b 99,00
30	Amazing	5	1	1	Steven Tyler, Richie Supa	356519	11616195	$b 99,00
31	Blind Man	5	1	1	Steven Tyler, Joe Perry, Taylor Rhodes	240718	7877453	$b 99,00
32	Deuces Are Wild	5	1	1	Steven Tyler, Jim Vallance	215875	7074167	$b 99,00
33	The Other Side	5	1	1	Steven Tyler, Jim Vallance	244375	7983270	$b 99,00
34	Crazy	5	1	1	Steven Tyler, Joe Perry, Desmond Child	316656	10402398	$b 99,00
35	Eat The Rich	5	1	1	Steven Tyler, Joe Perry, Jim Vallance	251036	8262039	$b 99,00
36	Angel	5	1	1	Steven Tyler, Desmond Child	307617	9989331	$b 99,00
37	Livin' On The Edge	5	1	1	Steven Tyler, Joe Perry, Mark Hudson	381231	12374569	$b 99,00
38	All I Really Want	6	1	1	Alanis Morissette & Glenn Ballard	284891	9375567	$b 99,00
39	You Oughta Know	6	1	1	Alanis Morissette & Glenn Ballard	249234	8196916	$b 99,00
40	Perfect	6	1	1	Alanis Morissette & Glenn Ballard	188133	6145404	$b 99,00
41	Hand In My Pocket	6	1	1	Alanis Morissette & Glenn Ballard	221570	7224246	$b 99,00
42	Right Through You	6	1	1	Alanis Morissette & Glenn Ballard	176117	5793082	$b 99,00
43	Forgiven	6	1	1	Alanis Morissette & Glenn Ballard	300355	9753256	$b 99,00
44	You Learn	6	1	1	Alanis Morissette & Glenn Ballard	239699	7824837	$b 99,00
45	Head Over Feet	6	1	1	Alanis Morissette & Glenn Ballard	267493	8758008	$b 99,00
46	Mary Jane	6	1	1	Alanis Morissette & Glenn Ballard	280607	9163588	$b 99,00
47	Ironic	6	1	1	Alanis Morissette & Glenn Ballard	229825	7598866	$b 99,00
48	Not The Doctor	6	1	1	Alanis Morissette & Glenn Ballard	227631	7604601	$b 99,00
49	Wake Up	6	1	1	Alanis Morissette & Glenn Ballard	293485	9703359	$b 99,00
50	You Oughta Know (Alternate)	6	1	1	Alanis Morissette & Glenn Ballard	491885	16008629	$b 99,00
51	We Die Young	7	1	1	Jerry Cantrell	152084	4925362	$b 99,00
52	Man In The Box	7	1	1	Jerry Cantrell, Layne Staley	286641	9310272	$b 99,00
53	Sea Of Sorrow	7	1	1	Jerry Cantrell	349831	11316328	$b 99,00
54	Bleed The Freak	7	1	1	Jerry Cantrell	241946	7847716	$b 99,00
55	I Can't Remember	7	1	1	Jerry Cantrell, Layne Staley	222955	7302550	$b 99,00
56	Love, Hate, Love	7	1	1	Jerry Cantrell, Layne Staley	387134	12575396	$b 99,00
57	It Ain't Like That	7	1	1	Jerry Cantrell, Michael Starr, Sean Kinney	277577	8993793	$b 99,00
58	Sunshine	7	1	1	Jerry Cantrell	284969	9216057	$b 99,00
59	Put You Down	7	1	1	Jerry Cantrell	196231	6420530	$b 99,00
60	Confusion	7	1	1	Jerry Cantrell, Michael Starr, Layne Staley	344163	11183647	$b 99,00
61	I Know Somethin (Bout You)	7	1	1	Jerry Cantrell	261955	8497788	$b 99,00
62	Real Thing	7	1	1	Jerry Cantrell, Layne Staley	243879	7937731	$b 99,00
77	Enter Sandman	9	1	3	Apocalyptica	221701	7286305	$b 99,00
78	Master Of Puppets	9	1	3	Apocalyptica	436453	14375310	$b 99,00
79	Harvester Of Sorrow	9	1	3	Apocalyptica	374543	12372536	$b 99,00
80	The Unforgiven	9	1	3	Apocalyptica	322925	10422447	$b 99,00
81	Sad But True	9	1	3	Apocalyptica	288208	9405526	$b 99,00
82	Creeping Death	9	1	3	Apocalyptica	308035	10110980	$b 99,00
83	Wherever I May Roam	9	1	3	Apocalyptica	369345	12033110	$b 99,00
84	Welcome Home (Sanitarium)	9	1	3	Apocalyptica	350197	11406431	$b 99,00
85	Cochise	10	1	1	Audioslave/Chris Cornell	222380	5339931	$b 99,00
86	Show Me How to Live	10	1	1	Audioslave/Chris Cornell	277890	6672176	$b 99,00
87	Gasoline	10	1	1	Audioslave/Chris Cornell	279457	6709793	$b 99,00
88	What You Are	10	1	1	Audioslave/Chris Cornell	249391	5988186	$b 99,00
168	Now Sports	18	1	4		4884	161266	$b 99,00
89	Like a Stone	10	1	1	Audioslave/Chris Cornell	294034	7059624	$b 99,00
90	Set It Off	10	1	1	Audioslave/Chris Cornell	263262	6321091	$b 99,00
91	Shadow on the Sun	10	1	1	Audioslave/Chris Cornell	343457	8245793	$b 99,00
92	I am the Highway	10	1	1	Audioslave/Chris Cornell	334942	8041411	$b 99,00
93	Exploder	10	1	1	Audioslave/Chris Cornell	206053	4948095	$b 99,00
94	Hypnotize	10	1	1	Audioslave/Chris Cornell	206628	4961887	$b 99,00
95	Bring'em Back Alive	10	1	1	Audioslave/Chris Cornell	329534	7911634	$b 99,00
96	Light My Way	10	1	1	Audioslave/Chris Cornell	303595	7289084	$b 99,00
97	Getaway Car	10	1	1	Audioslave/Chris Cornell	299598	7193162	$b 99,00
98	The Last Remaining Light	10	1	1	Audioslave/Chris Cornell	317492	7622615	$b 99,00
99	Your Time Has Come	11	1	4	Cornell, Commerford, Morello, Wilk	255529	8273592	$b 99,00
100	Out Of Exile	11	1	4	Cornell, Commerford, Morello, Wilk	291291	9506571	$b 99,00
101	Be Yourself	11	1	4	Cornell, Commerford, Morello, Wilk	279484	9106160	$b 99,00
102	Doesn't Remind Me	11	1	4	Cornell, Commerford, Morello, Wilk	255869	8357387	$b 99,00
103	Drown Me Slowly	11	1	4	Cornell, Commerford, Morello, Wilk	233691	7609178	$b 99,00
104	Heaven's Dead	11	1	4	Cornell, Commerford, Morello, Wilk	276688	9006158	$b 99,00
105	The Worm	11	1	4	Cornell, Commerford, Morello, Wilk	237714	7710800	$b 99,00
106	Man Or Animal	11	1	4	Cornell, Commerford, Morello, Wilk	233195	7542942	$b 99,00
107	Yesterday To Tomorrow	11	1	4	Cornell, Commerford, Morello, Wilk	273763	8944205	$b 99,00
108	Dandelion	11	1	4	Cornell, Commerford, Morello, Wilk	278125	9003592	$b 99,00
109	#1 Zero	11	1	4	Cornell, Commerford, Morello, Wilk	299102	9731988	$b 99,00
110	The Curse	11	1	4	Cornell, Commerford, Morello, Wilk	309786	10029406	$b 99,00
111	Money	12	1	5	Berry Gordy, Jr./Janie Bradford	147591	2365897	$b 99,00
112	Long Tall Sally	12	1	5	Enotris Johnson/Little Richard/Robert "Bumps" Blackwell	106396	1707084	$b 99,00
113	Bad Boy	12	1	5	Larry Williams	116088	1862126	$b 99,00
114	Twist And Shout	12	1	5	Bert Russell/Phil Medley	161123	2582553	$b 99,00
115	Please Mr. Postman	12	1	5	Brian Holland/Freddie Gorman/Georgia Dobbins/Robert Bateman/William Garrett	137639	2206986	$b 99,00
116	C'Mon Everybody	12	1	5	Eddie Cochran/Jerry Capehart	140199	2247846	$b 99,00
117	Rock 'N' Roll Music	12	1	5	Chuck Berry	141923	2276788	$b 99,00
118	Slow Down	12	1	5	Larry Williams	163265	2616981	$b 99,00
119	Roadrunner	12	1	5	Bo Diddley	143595	2301989	$b 99,00
120	Carol	12	1	5	Chuck Berry	143830	2306019	$b 99,00
121	Good Golly Miss Molly	12	1	5	Little Richard	106266	1704918	$b 99,00
122	20 Flight Rock	12	1	5	Ned Fairchild	107807	1299960	$b 99,00
123	Quadrant	13	1	2	Billy Cobham	261851	8538199	$b 99,00
124	Snoopy's search-Red baron	13	1	2	Billy Cobham	456071	15075616	$b 99,00
125	Spanish moss-"A sound portrait"-Spanish moss	13	1	2	Billy Cobham	248084	8217867	$b 99,00
126	Moon germs	13	1	2	Billy Cobham	294060	9714812	$b 99,00
127	Stratus	13	1	2	Billy Cobham	582086	19115680	$b 99,00
128	The pleasant pheasant	13	1	2	Billy Cobham	318066	10630578	$b 99,00
129	Solo-Panhandler	13	1	2	Billy Cobham	246151	8230661	$b 99,00
130	Do what cha wanna	13	1	2	George Duke	274155	9018565	$b 99,00
131	Intro/ Low Down	14	1	3		323683	10642901	$b 99,00
132	13 Years Of Grief	14	1	3		246987	8137421	$b 99,00
133	Stronger Than Death	14	1	3		300747	9869647	$b 99,00
134	All For You	14	1	3		235833	7726948	$b 99,00
135	Super Terrorizer	14	1	3		319373	10513905	$b 99,00
136	Phoney Smile Fake Hellos	14	1	3		273606	9011701	$b 99,00
137	Lost My Better Half	14	1	3		284081	9355309	$b 99,00
138	Bored To Tears	14	1	3		247327	8130090	$b 99,00
139	A.N.D.R.O.T.A.Z.	14	1	3		266266	8574746	$b 99,00
140	Born To Booze	14	1	3		282122	9257358	$b 99,00
141	World Of Trouble	14	1	3		359157	11820932	$b 99,00
142	No More Tears	14	1	3		555075	18041629	$b 99,00
143	The Begining... At Last	14	1	3		365662	11965109	$b 99,00
144	Heart Of Gold	15	1	3		194873	6417460	$b 99,00
145	Snowblind	15	1	3		420022	13842549	$b 99,00
146	Like A Bird	15	1	3		276532	9115657	$b 99,00
147	Blood In The Wall	15	1	3		284368	9359475	$b 99,00
148	The Beginning...At Last	15	1	3		271960	8975814	$b 99,00
149	Black Sabbath	16	1	3		382066	12440200	$b 99,00
150	The Wizard	16	1	3		264829	8646737	$b 99,00
151	Behind The Wall Of Sleep	16	1	3		217573	7169049	$b 99,00
152	N.I.B.	16	1	3		368770	12029390	$b 99,00
153	Evil Woman	16	1	3		204930	6655170	$b 99,00
154	Sleeping Village	16	1	3		644571	21128525	$b 99,00
155	Warning	16	1	3		212062	6893363	$b 99,00
156	Wheels Of Confusion / The Straightener	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	494524	16065830	$b 99,00
157	Tomorrow's Dream	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	192496	6252071	$b 99,00
158	Changes	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	286275	9175517	$b 99,00
159	FX	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	103157	3331776	$b 99,00
160	Supernaut	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	285779	9245971	$b 99,00
161	Snowblind	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	331676	10813386	$b 99,00
162	Cornucopia	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	234814	7653880	$b 99,00
163	Laguna Sunrise	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	173087	5671374	$b 99,00
164	St. Vitus Dance	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	149655	4884969	$b 99,00
165	Under The Sun/Every Day Comes and Goes	17	1	3	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	350458	11360486	$b 99,00
166	Smoked Pork	18	1	4		47333	1549074	$b 99,00
167	Body Count's In The House	18	1	4		204251	6715413	$b 99,00
169	Body Count	18	1	4		317936	10489139	$b 99,00
170	A Statistic	18	1	4		6373	211997	$b 99,00
171	Bowels Of The Devil	18	1	4		223216	7324125	$b 99,00
172	The Real Problem	18	1	4		11650	387360	$b 99,00
173	KKK Bitch	18	1	4		173008	5709631	$b 99,00
174	D Note	18	1	4		95738	3067064	$b 99,00
175	Voodoo	18	1	4		300721	9875962	$b 99,00
176	The Winner Loses	18	1	4		392254	12843821	$b 99,00
177	There Goes The Neighborhood	18	1	4		350171	11443471	$b 99,00
178	Oprah	18	1	4		6635	224313	$b 99,00
179	Evil Dick	18	1	4		239020	7828873	$b 99,00
180	Body Count Anthem	18	1	4		166426	5463690	$b 99,00
181	Momma's Gotta Die Tonight	18	1	4		371539	12122946	$b 99,00
182	Freedom Of Speech	18	1	4		281234	9337917	$b 99,00
183	King In Crimson	19	1	3	Roy Z	283167	9218499	$b 99,00
184	Chemical Wedding	19	1	3	Roy Z	246177	8022764	$b 99,00
185	The Tower	19	1	3	Roy Z	285257	9435693	$b 99,00
186	Killing Floor	19	1	3	Adrian Smith	269557	8854240	$b 99,00
187	Book Of Thel	19	1	3	Eddie Casillas/Roy Z	494393	16034404	$b 99,00
188	Gates Of Urizen	19	1	3	Roy Z	265351	8627004	$b 99,00
189	Jerusalem	19	1	3	Roy Z	402390	13194463	$b 99,00
190	Trupets Of Jericho	19	1	3	Roy Z	359131	11820908	$b 99,00
191	Machine Men	19	1	3	Adrian Smith	341655	11138147	$b 99,00
192	The Alchemist	19	1	3	Roy Z	509413	16545657	$b 99,00
193	Realword	19	1	3	Roy Z	237531	7802095	$b 99,00
194	First Time I Met The Blues	20	1	6	Eurreal Montgomery	140434	4604995	$b 99,00
195	Let Me Love You Baby	20	1	6	Willie Dixon	175386	5716994	$b 99,00
196	Stone Crazy	20	1	6	Buddy Guy	433397	14184984	$b 99,00
197	Pretty Baby	20	1	6	Willie Dixon	237662	7848282	$b 99,00
198	When My Left Eye Jumps	20	1	6	Al Perkins/Willie Dixon	235311	7685363	$b 99,00
199	Leave My Girl Alone	20	1	6	Buddy Guy	204721	6859518	$b 99,00
200	She Suits Me To A Tee	20	1	6	Buddy Guy	136803	4456321	$b 99,00
201	Keep It To Myself (Aka Keep It To Yourself)	20	1	6	Sonny Boy Williamson [I]	166060	5487056	$b 99,00
202	My Time After Awhile	20	1	6	Robert Geddins/Ron Badger/Sheldon Feinberg	182491	6022698	$b 99,00
203	Too Many Ways (Alternate)	20	1	6	Willie Dixon	135053	4459946	$b 99,00
204	Talkin' 'Bout Women Obviously	20	1	6	Amos Blakemore/Buddy Guy	589531	19161377	$b 99,00
206	Prenda Minha	21	1	7	Tradicional	99369	3225364	$b 99,00
208	Terra	21	1	7	Caetano Veloso	482429	15889054	$b 99,00
209	Eclipse Oculto	21	1	7	Caetano Veloso	221936	7382703	$b 99,00
210	Texto "Verdade Tropical"	21	1	7	Caetano Veloso	84088	2752161	$b 99,00
211	Bem Devagar	21	1	7	Gilberto Gil	133172	4333651	$b 99,00
213	Saudosismo	21	1	7	Caetano Veloso	144326	4726981	$b 99,00
214	Carolina	21	1	7	Chico Buarque	181812	5924159	$b 99,00
215	Sozinho	21	1	7	Peninha	190589	6253200	$b 99,00
216	Esse Cara	21	1	7	Caetano Veloso	223111	7217126	$b 99,00
218	Linha Do Equador	21	1	7	Caetano Veloso - Djavan	299337	10003747	$b 99,00
219	Odara	21	1	7	Caetano Veloso	141270	4704104	$b 99,00
220	A Luz De Tieta	21	1	7	Caetano Veloso	251742	8507446	$b 99,00
222	Vida Boa	21	1	7	Fausto Nilo - Armandinho	281730	9411272	$b 99,00
223	Sozinho (Hitmakers Classic Mix)	22	1	7		436636	14462072	$b 99,00
224	Sozinho (Hitmakers Classic Radio Edit)	22	1	7		195004	6455134	$b 99,00
226	Carolina	23	1	7		163056	5375395	$b 99,00
228	Vai Passar	23	1	7		369763	12359161	$b 99,00
229	Samba De Orly	23	1	7		162429	5431854	$b 99,00
230	Bye, Bye Brasil	23	1	7		283402	9499590	$b 99,00
231	Atras Da Porta	23	1	7		189675	6132843	$b 99,00
232	Tatuagem	23	1	7		172120	5645703	$b 99,00
234	Morena De Angola	23	1	7		186801	6373932	$b 99,00
236	A Banda	23	1	7		132493	4349539	$b 99,00
237	Minha Historia	23	1	7		182256	6029673	$b 99,00
239	Brejo Da Cruz	23	1	7		214099	7270749	$b 99,00
240	Meu Caro Amigo	23	1	7		260257	8778172	$b 99,00
241	Geni E O Zepelim	23	1	7		317570	10342226	$b 99,00
243	Vai Trabalhar Vagabundo	23	1	7		139154	4693941	$b 99,00
301	A Sombra Da Maldade	27	1	8	Da Gama/Toni Garrido	285231	9544383	$b 99,00
302	A Estrada	27	1	8	Da Gama/Lazao/Toni Garrido	282174	9344477	$b 99,00
303	Falar A Verdade	27	1	8	Bino/Da Gama/Ras Bernardo	244950	8189093	$b 99,00
304	Firmamento	27	1	8	Harry Lawes/Winston Foster-Vers	225488	7507866	$b 99,00
305	Pensamento	27	1	8	Bino/Da Gama/Ras Bernardo	192391	6399761	$b 99,00
306	Realidade Virtual	27	1	8	Bino/Da Gamma/Lazao/Toni Garrido	240300	8069934	$b 99,00
307	Doutor	27	1	8	Bino/Da Gama/Toni Garrido	178155	5950952	$b 99,00
308	Na Frente Da TV	27	1	8	Bino/Da Gama/Lazao/Ras Bernardo	289750	9633659	$b 99,00
309	Downtown	27	1	8	Cidade Negra	239725	8024386	$b 99,00
311	A Cor Do Sol	27	1	8	Bernardo Vilhena/Da Gama/Lazao	273031	9142937	$b 99,00
337	You Shook Me	30	1	1	J B Lenoir/Willie Dixon	315951	10249958	$b 99,00
338	I Can't Quit You Baby	30	1	1	Willie Dixon	263836	8581414	$b 99,00
339	Communication Breakdown	30	1	1	Jimmy Page/John Bonham/John Paul Jones	192653	6287257	$b 99,00
340	Dazed and Confused	30	1	1	Jimmy Page	401920	13035765	$b 99,00
341	The Girl I Love She Got Long Black Wavy Hair	30	1	1	Jimmy Page/John Bonham/John Estes/John Paul Jones/Robert Plant	183327	5995686	$b 99,00
342	What is and Should Never Be	30	1	1	Jimmy Page/Robert Plant	260675	8497116	$b 99,00
343	Communication Breakdown(2)	30	1	1	Jimmy Page/John Bonham/John Paul Jones	161149	5261022	$b 99,00
344	Travelling Riverside Blues	30	1	1	Jimmy Page/Robert Johnson/Robert Plant	312032	10232581	$b 99,00
345	Whole Lotta Love	30	1	1	Jimmy Page/John Bonham/John Paul Jones/Robert Plant/Willie Dixon	373394	12258175	$b 99,00
346	Somethin' Else	30	1	1	Bob Cochran/Sharon Sheeley	127869	4165650	$b 99,00
347	Communication Breakdown(3)	30	1	1	Jimmy Page/John Bonham/John Paul Jones	185260	6041133	$b 99,00
348	I Can't Quit You Baby(2)	30	1	1	Willie Dixon	380551	12377615	$b 99,00
349	You Shook Me(2)	30	1	1	J B Lenoir/Willie Dixon	619467	20138673	$b 99,00
350	How Many More Times	30	1	1	Chester Burnett/Jimmy Page/John Bonham/John Paul Jones/Robert Plant	711836	23092953	$b 99,00
351	Debra Kadabra	31	1	1	Frank Zappa	234553	7649679	$b 99,00
352	Carolina Hard-Core Ecstasy	31	1	1	Frank Zappa	359680	11731061	$b 99,00
353	Sam With The Showing Scalp Flat Top	31	1	1	Don Van Vliet	171284	5572993	$b 99,00
354	Poofter's Froth Wyoming Plans Ahead	31	1	1	Frank Zappa	183902	6007019	$b 99,00
355	200 Years Old	31	1	1	Frank Zappa	272561	8912465	$b 99,00
356	Cucamonga	31	1	1	Frank Zappa	144483	4728586	$b 99,00
357	Advance Romance	31	1	1	Frank Zappa	677694	22080051	$b 99,00
358	Man With The Woman Head	31	1	1	Don Van Vliet	88894	2922044	$b 99,00
359	Muffin Man	31	1	1	Frank Zappa	332878	10891682	$b 99,00
360	Vai-Vai 2001	32	1	10		276349	9402241	$b 99,00
361	X-9 2001	32	1	10		273920	9310370	$b 99,00
362	Gavioes 2001	32	1	10		282723	9616640	$b 99,00
363	Nene 2001	32	1	10		284969	9694508	$b 99,00
364	Rosas De Ouro 2001	32	1	10		284342	9721084	$b 99,00
365	Mocidade Alegre 2001	32	1	10		282488	9599937	$b 99,00
366	Camisa Verde 2001	32	1	10		283454	9633755	$b 99,00
367	Leandro De Itaquera 2001	32	1	10		274808	9451845	$b 99,00
368	Tucuruvi 2001	32	1	10		287921	9883335	$b 99,00
369	Aguia De Ouro 2001	32	1	10		284160	9698729	$b 99,00
370	Ipiranga 2001	32	1	10		248293	8522591	$b 99,00
371	Morro Da Casa Verde 2001	32	1	10		284708	9718778	$b 99,00
372	Perola Negra 2001	32	1	10		281626	9619196	$b 99,00
373	Sao Lucas 2001	32	1	10		296254	10020122	$b 99,00
374	Guanabara	33	1	7	Marcos Valle	247614	8499591	$b 99,00
375	Mas Que Nada	33	1	7	Jorge Ben	248398	8255254	$b 99,00
377	A Paz	33	1	7	Donato/Gilberto Gil	263183	8619173	$b 99,00
378	Wave (Vou te Contar)	33	1	7	Antonio Carlos Jobim	271647	9057557	$b 99,00
381	Pode Parar	33	1	7	Jorge Vercilo/Jota Maranhao	179408	6046678	$b 99,00
382	Menino do Rio	33	1	7	Caetano Veloso	262713	8737489	$b 99,00
383	Ando Meio Desligado	33	1	7	Caetano Veloso	195813	6547648	$b 99,00
385	All Star	33	1	7	Nando Reis	176326	5891697	$b 99,00
386	Menina Bonita	33	1	7	Alexandre Brazil/Pedro Luis/Rodrigo Cabelo	237087	7938246	$b 99,00
390	Sambassim (dj patife remix)	33	1	7	Alba Carvalho/Fernando Porto	213655	7243166	$b 99,00
408	Free Speech For The Dumb	35	1	3	Molaney/Morris/Roberts/Wainwright	155428	5076048	$b 99,00
409	It's Electric	35	1	3	Harris/Tatler	213995	6978601	$b 99,00
410	Sabbra Cadabra	35	1	3	Black Sabbath	380342	12418147	$b 99,00
411	Turn The Page	35	1	3	Seger	366524	11946327	$b 99,00
412	Die Die My Darling	35	1	3	Danzig	149315	4867667	$b 99,00
413	Loverman	35	1	3	Cave	472764	15446975	$b 99,00
414	Mercyful Fate	35	1	3	Diamond/Shermann	671712	21942829	$b 99,00
415	Astronomy	35	1	3	A.Bouchard/J.Bouchard/S.Pearlman	397531	13065612	$b 99,00
416	Whiskey In The Jar	35	1	3	Traditional	305005	9943129	$b 99,00
417	Tuesday's Gone	35	1	3	Collins/Van Zandt	545750	17900787	$b 99,00
418	The More I See	35	1	3	Molaney/Morris/Roberts/Wainwright	287973	9378873	$b 99,00
419	A Kind Of Magic	36	1	1	Roger Taylor	262608	8689618	$b 99,00
420	Under Pressure	36	1	1	Queen & David Bowie	236617	7739042	$b 99,00
421	Radio GA GA	36	1	1	Roger Taylor	343745	11358573	$b 99,00
422	I Want It All	36	1	1	Queen	241684	7876564	$b 99,00
423	I Want To Break Free	36	1	1	John Deacon	259108	8552861	$b 99,00
424	Innuendo	36	1	1	Queen	387761	12664591	$b 99,00
425	It's A Hard Life	36	1	1	Freddie Mercury	249417	8112242	$b 99,00
426	Breakthru	36	1	1	Queen	249234	8150479	$b 99,00
427	Who Wants To Live Forever	36	1	1	Brian May	297691	9577577	$b 99,00
428	Headlong	36	1	1	Queen	273057	8921404	$b 99,00
429	The Miracle	36	1	1	Queen	294974	9671923	$b 99,00
430	I'm Going Slightly Mad	36	1	1	Queen	248032	8192339	$b 99,00
431	The Invisible Man	36	1	1	Queen	238994	7920353	$b 99,00
432	Hammer To Fall	36	1	1	Brian May	220316	7255404	$b 99,00
433	Friends Will Be Friends	36	1	1	Freddie Mercury & John Deacon	248920	8114582	$b 99,00
434	The Show Must Go On	36	1	1	Queen	263784	8526760	$b 99,00
435	One Vision	36	1	1	Queen	242599	7936928	$b 99,00
436	Detroit Rock City	37	1	1	Paul Stanley, B. Ezrin	218880	7146372	$b 99,00
437	Black Diamond	37	1	1	Paul Stanley	314148	10266007	$b 99,00
438	Hard Luck Woman	37	1	1	Paul Stanley	216032	7109267	$b 99,00
439	Sure Know Something	37	1	1	Paul Stanley, Vincent Poncia	242468	7939886	$b 99,00
440	Love Gun	37	1	1	Paul Stanley	196257	6424915	$b 99,00
441	Deuce	37	1	1	Gene Simmons	185077	6097210	$b 99,00
442	Goin' Blind	37	1	1	Gene Simmons, S. Coronel	216215	7045314	$b 99,00
443	Shock Me	37	1	1	Ace Frehley	227291	7529336	$b 99,00
444	Do You Love Me	37	1	1	Paul Stanley, B. Ezrin, K. Fowley	214987	6976194	$b 99,00
445	She	37	1	1	Gene Simmons, S. Coronel	248346	8229734	$b 99,00
446	I Was Made For Loving You	37	1	1	Paul Stanley, Vincent Poncia, Desmond Child	271360	9018078	$b 99,00
447	Shout It Out Loud	37	1	1	Paul Stanley, Gene Simmons, B. Ezrin	219742	7194424	$b 99,00
448	God Of Thunder	37	1	1	Paul Stanley	255791	8309077	$b 99,00
449	Calling Dr. Love	37	1	1	Gene Simmons	225332	7395034	$b 99,00
450	Beth	37	1	1	S. Penridge, Bob Ezrin, Peter Criss	166974	5360574	$b 99,00
451	Strutter	37	1	1	Paul Stanley, Gene Simmons	192496	6317021	$b 99,00
452	Rock And Roll All Nite	37	1	1	Paul Stanley, Gene Simmons	173609	5735902	$b 99,00
453	Cold Gin	37	1	1	Ace Frehley	262243	8609783	$b 99,00
454	Plaster Caster	37	1	1	Gene Simmons	207333	6801116	$b 99,00
455	God Gave Rock 'n' Roll To You	37	1	1	Paul Stanley, Gene Simmons, Rus Ballard, Bob Ezrin	320444	10441590	$b 99,00
456	Heart of the Night	38	1	2		273737	9098263	$b 99,00
457	De La Luz	38	1	2		315219	10518284	$b 99,00
458	Westwood Moon	38	1	2		295627	9765802	$b 99,00
459	Midnight	38	1	2		266866	8851060	$b 99,00
460	Playtime	38	1	2		273580	9070880	$b 99,00
461	Surrender	38	1	2		287634	9422926	$b 99,00
462	Valentino's	38	1	2		296124	9848545	$b 99,00
463	Believe	38	1	2		310778	10317185	$b 99,00
464	As We Sleep	38	1	2		316865	10429398	$b 99,00
465	When Evening Falls	38	1	2		298135	9863942	$b 99,00
466	J Squared	38	1	2		288757	9480777	$b 99,00
467	Best Thing	38	1	2		274259	9069394	$b 99,00
468	Maria	39	1	4	Billie Joe Armstrong -Words Green Day -Music	167262	5484747	$b 99,00
469	Poprocks And Coke	39	1	4	Billie Joe Armstrong -Words Green Day -Music	158354	5243078	$b 99,00
470	Longview	39	1	4	Billie Joe Armstrong -Words Green Day -Music	234083	7714939	$b 99,00
471	Welcome To Paradise	39	1	4	Billie Joe Armstrong -Words Green Day -Music	224208	7406008	$b 99,00
472	Basket Case	39	1	4	Billie Joe Armstrong -Words Green Day -Music	181629	5951736	$b 99,00
473	When I Come Around	39	1	4	Billie Joe Armstrong -Words Green Day -Music	178364	5839426	$b 99,00
474	She	39	1	4	Billie Joe Armstrong -Words Green Day -Music	134164	4425128	$b 99,00
475	J.A.R. (Jason Andrew Relva)	39	1	4	Mike Dirnt -Words Green Day -Music	170997	5645755	$b 99,00
476	Geek Stink Breath	39	1	4	Billie Joe Armstrong -Words Green Day -Music	135888	4408983	$b 99,00
477	Brain Stew	39	1	4	Billie Joe Armstrong -Words Green Day -Music	193149	6305550	$b 99,00
478	Jaded	39	1	4	Billie Joe Armstrong -Words Green Day -Music	90331	2950224	$b 99,00
479	Walking Contradiction	39	1	4	Billie Joe Armstrong -Words Green Day -Music	151170	4932366	$b 99,00
480	Stuck With Me	39	1	4	Billie Joe Armstrong -Words Green Day -Music	135523	4431357	$b 99,00
481	Hitchin' A Ride	39	1	4	Billie Joe Armstrong -Words Green Day -Music	171546	5616891	$b 99,00
482	Good Riddance (Time Of Your Life)	39	1	4	Billie Joe Armstrong -Words Green Day -Music	153600	5075241	$b 99,00
483	Redundant	39	1	4	Billie Joe Armstrong -Words Green Day -Music	198164	6481753	$b 99,00
484	Nice Guys Finish Last	39	1	4	Billie Joe Armstrong -Words Green Day -Music	170187	5604618	$b 99,00
485	Minority	39	1	4	Billie Joe Armstrong -Words Green Day -Music	168803	5535061	$b 99,00
486	Warning	39	1	4	Billie Joe Armstrong -Words Green Day -Music	221910	7343176	$b 99,00
487	Waiting	39	1	4	Billie Joe Armstrong -Words Green Day -Music	192757	6316430	$b 99,00
488	Macy's Day Parade	39	1	4	Billie Joe Armstrong -Words Green Day -Music	213420	7075573	$b 99,00
489	Into The Light	40	1	1	David Coverdale	76303	2452653	$b 99,00
490	River Song	40	1	1	David Coverdale	439510	14359478	$b 99,00
491	She Give Me ...	40	1	1	David Coverdale	252551	8385478	$b 99,00
492	Don't You Cry	40	1	1	David Coverdale	347036	11269612	$b 99,00
493	Love Is Blind	40	1	1	David Coverdale/Earl Slick	344999	11409720	$b 99,00
494	Slave	40	1	1	David Coverdale/Earl Slick	291892	9425200	$b 99,00
495	Cry For Love	40	1	1	Bossi/David Coverdale/Earl Slick	293015	9567075	$b 99,00
496	Living On Love	40	1	1	Bossi/David Coverdale/Earl Slick	391549	12785876	$b 99,00
497	Midnight Blue	40	1	1	David Coverdale/Earl Slick	298631	9750990	$b 99,00
498	Too Many Tears	40	1	1	Adrian Vanderberg/David Coverdale	359497	11810238	$b 99,00
499	Don't Lie To Me	40	1	1	David Coverdale/Earl Slick	283585	9288007	$b 99,00
500	Wherever You May Go	40	1	1	David Coverdale	239699	7803074	$b 99,00
501	Grito De Alerta	41	1	7	Gonzaga Jr.	202213	6539422	$b 99,00
505	Sangrando	41	1	7	Gonzaga Jr/Gonzaguinha	169717	5494406	$b 99,00
507	Lindo Lago Do Amor	41	1	7	Gonzaga Jr.	249678	8353191	$b 99,00
509	Com A Perna No Mundo	41	1	7	Gonzaga Jr.	227448	7747108	$b 99,00
512	Comportamento Geral	41	1	7	Gonzaga Jr	181577	5997444	$b 99,00
514	Espere Por Mim, Morena	41	1	7	Gonzaguinha	207072	6796523	$b 99,00
515	Meia-Lua Inteira	23	1	7		222093	7466288	$b 99,00
516	Voce e Linda	23	1	7		242938	8050268	$b 99,00
517	Um Indio	23	1	7		195944	6453213	$b 99,00
518	Podres Poderes	23	1	7		259761	8622495	$b 99,00
519	Voce Nao Entende Nada - Cotidiano	23	1	7		421982	13885612	$b 99,00
520	O Estrangeiro	23	1	7		374700	12472890	$b 99,00
521	Menino Do Rio	23	1	7		147670	4862277	$b 99,00
522	Qualquer Coisa	23	1	7		193410	6372433	$b 99,00
523	Sampa	23	1	7		185051	6151831	$b 99,00
524	Queixa	23	1	7		299676	9953962	$b 99,00
525	O Leaozinho	23	1	7		184398	6098150	$b 99,00
526	Fora Da Ordem	23	1	7		354011	11746781	$b 99,00
527	Terra	23	1	7		401319	13224055	$b 99,00
528	Alegria, Alegria	23	1	7		169221	5497025	$b 99,00
543	Burn	43	1	1	Coverdale/Lord/Paice	453955	14775708	$b 99,00
544	Stormbringer	43	1	1	Coverdale	277133	9050022	$b 99,00
545	Gypsy	43	1	1	Coverdale/Hughes/Lord/Paice	339173	11046952	$b 99,00
546	Lady Double Dealer	43	1	1	Coverdale	233586	7608759	$b 99,00
547	Mistreated	43	1	1	Coverdale	758648	24596235	$b 99,00
548	Smoke On The Water	43	1	1	Gillan/Glover/Lord/Paice	618031	20103125	$b 99,00
549	You Fool No One	43	1	1	Coverdale/Lord/Paice	804101	26369966	$b 99,00
550	Custard Pie	44	1	1	Jimmy Page/Robert Plant	253962	8348257	$b 99,00
551	The Rover	44	1	1	Jimmy Page/Robert Plant	337084	11011286	$b 99,00
552	In My Time Of Dying	44	1	1	John Bonham/John Paul Jones	666017	21676727	$b 99,00
553	Houses Of The Holy	44	1	1	Jimmy Page/Robert Plant	242494	7972503	$b 99,00
554	Trampled Under Foot	44	1	1	John Paul Jones	336692	11154468	$b 99,00
555	Kashmir	44	1	1	John Bonham	508604	16686580	$b 99,00
556	Imperatriz	45	1	7	Guga/Marquinho Lessa/Tuninho Professor	339173	11348710	$b 99,00
557	Beija-Flor	45	1	7	Caruso/Cleber/Deo/Osmar	327000	10991159	$b 99,00
558	Viradouro	45	1	7	Dadinho/Gilbreto Gomes/Gustavo/P.C. Portugal/R. Mocoto	344320	11484362	$b 99,00
559	Mocidade	45	1	7	Domenil/J. Brito/Joaozinho/Rap, Marcelo Do	261720	8817757	$b 99,00
560	Unidos Da Tijuca	45	1	7	Douglas/Neves, Vicente Das/Silva, Gilmar L./Toninho Gentil/Wantuir	338834	11440689	$b 99,00
561	Salgueiro	45	1	7	Augusto/Craig Negoescu/Rocco Filho/Saara, Ze Carlos Da	305920	10294741	$b 99,00
565	Portela	45	1	7	Flavio Bororo/Paulo Apparicio/Wagner Alves/Zeca Sereno	319608	10712216	$b 99,00
566	Caprichosos	45	1	7	Gule/Jorge 101/Lequinho/Luiz Piao	351320	11870956	$b 99,00
569	Tuiuti	45	1	7	Claudio Martins/David Lima/Kleber Rodrigues/Livre, Cesare Som	259657	8749492	$b 99,00
570	(Da Le) Yaleo	46	1	1	Santana	353488	11769507	$b 99,00
571	Love Of My Life	46	1	1	Carlos Santana & Dave Matthews	347820	11634337	$b 99,00
572	Put Your Lights On	46	1	1	E. Shrody	285178	9394769	$b 99,00
573	Africa Bamba	46	1	1	I. Toure, S. Tidiane Toure, Carlos Santana & K. Perazzo	282827	9492487	$b 99,00
574	Smooth	46	1	1	M. Itaal Shur & Rob Thomas	298161	9867455	$b 99,00
575	Do You Like The Way	46	1	1	L. Hill	354899	11741062	$b 99,00
576	Maria Maria	46	1	1	W. Jean, J. Duplessis, Carlos Santana, K. Perazzo & R. Rekow	262635	8664601	$b 99,00
577	Migra	46	1	1	R. Taha, Carlos Santana & T. Lindsay	329064	10963305	$b 99,00
578	Corazon Espinado	46	1	1	F. Olivera	276114	9206802	$b 99,00
579	Wishing It Was	46	1	1	Eale-Eye Cherry, M. Simpson, J. King & M. Nishita	292832	9771348	$b 99,00
580	El Farol	46	1	1	Carlos Santana & KC Porter	291160	9599353	$b 99,00
581	Primavera	46	1	1	KC Porter & JB Eckl	378618	12504234	$b 99,00
582	The Calling	46	1	1	Carlos Santana & C. Thompson	747755	24703884	$b 99,00
584	Manuel	47	1	7		230269	7677671	$b 99,00
586	Um Contrato Com Deus	47	1	7		202501	6636465	$b 99,00
587	Um Jantar Pra Dois	47	1	7		244009	8021589	$b 99,00
589	Um Love	47	1	7		181603	6095524	$b 99,00
590	Seis Da Tarde	47	1	7		238445	7935898	$b 99,00
591	Baixo Rio	47	1	7		198008	6521676	$b 99,00
592	Sombras Do Meu Destino	47	1	7		280685	9161539	$b 99,00
593	Do You Have Other Loves?	47	1	7		295235	9604273	$b 99,00
594	Agora Que O Dia Acordou	47	1	7		323213	10572752	$b 99,00
596	A Rua	47	1	7		238027	7930264	$b 99,00
597	Now's The Time	48	1	2	Miles Davis	197459	6358868	$b 99,00
598	Jeru	48	1	2	Miles Davis	193410	6222536	$b 99,00
599	Compulsion	48	1	2	Miles Davis	345025	11254474	$b 99,00
600	Tempus Fugit	48	1	2	Miles Davis	231784	7548434	$b 99,00
601	Walkin'	48	1	2	Miles Davis	807392	26411634	$b 99,00
602	'Round Midnight	48	1	2	Miles Davis	357459	11590284	$b 99,00
603	Bye Bye Blackbird	48	1	2	Miles Davis	476003	15549224	$b 99,00
604	New Rhumba	48	1	2	Miles Davis	277968	9018024	$b 99,00
605	Generique	48	1	2	Miles Davis	168777	5437017	$b 99,00
606	Summertime	48	1	2	Miles Davis	200437	6461370	$b 99,00
607	So What	48	1	2	Miles Davis	564009	18360449	$b 99,00
608	The Pan Piper	48	1	2	Miles Davis	233769	7593713	$b 99,00
609	Someday My Prince Will Come	48	1	2	Miles Davis	544078	17890773	$b 99,00
610	My Funny Valentine (Live)	49	1	2	Miles Davis	907520	29416781	$b 99,00
611	E.S.P.	49	1	2	Miles Davis	330684	11079866	$b 99,00
612	Nefertiti	49	1	2	Miles Davis	473495	15478450	$b 99,00
613	Petits Machins (Little Stuff)	49	1	2	Miles Davis	487392	16131272	$b 99,00
614	Miles Runs The Voodoo Down	49	1	2	Miles Davis	843964	27967919	$b 99,00
615	Little Church (Live)	49	1	2	Miles Davis	196101	6273225	$b 99,00
616	Black Satin	49	1	2	Miles Davis	316682	10529483	$b 99,00
617	Jean Pierre (Live)	49	1	2	Miles Davis	243461	7955114	$b 99,00
618	Time After Time	49	1	2	Miles Davis	220734	7292197	$b 99,00
619	Portia	49	1	2	Miles Davis	378775	12520126	$b 99,00
620	Space Truckin'	50	1	1	Blackmore/Gillan/Glover/Lord/Paice	1196094	39267613	$b 99,00
621	Going Down / Highway Star	50	1	1	Gillan/Glover/Lord/Nix - Blackmore/Paice	913658	29846063	$b 99,00
622	Mistreated (Alternate Version)	50	1	1	Blackmore/Coverdale	854700	27775442	$b 99,00
623	You Fool No One (Alternate Version)	50	1	1	Blackmore/Coverdale/Lord/Paice	763924	24887209	$b 99,00
624	Jeepers Creepers	51	1	2		185965	5991903	$b 99,00
625	Blue Rythm Fantasy	51	1	2		348212	11204006	$b 99,00
626	Drum Boogie	51	1	2		191555	6185636	$b 99,00
627	Let Me Off Uptown	51	1	2		187637	6034685	$b 99,00
628	Leave Us Leap	51	1	2		182726	5898810	$b 99,00
629	Opus No.1	51	1	2		179800	5846041	$b 99,00
630	Boogie Blues	51	1	2		204199	6603153	$b 99,00
631	How High The Moon	51	1	2		201430	6529487	$b 99,00
632	Disc Jockey Jump	51	1	2		193149	6260820	$b 99,00
633	Up An' Atom	51	1	2		179565	5822645	$b 99,00
634	Bop Boogie	51	1	2		189596	6093124	$b 99,00
635	Lemon Drop	51	1	2		194089	6287531	$b 99,00
636	Coronation Drop	51	1	2		176222	5899898	$b 99,00
637	Overtime	51	1	2		163030	5432236	$b 99,00
638	Imagination	51	1	2		289306	9444385	$b 99,00
639	Don't Take Your Love From Me	51	1	2		282331	9244238	$b 99,00
640	Midget	51	1	2		217025	7257663	$b 99,00
641	I'm Coming Virginia	51	1	2		280163	9209827	$b 99,00
642	Payin' Them Dues Blues	51	1	2		198556	6536918	$b 99,00
643	Jungle Drums	51	1	2		199627	6546063	$b 99,00
644	Showcase	51	1	2		201560	6697510	$b 99,00
645	Swedish Schnapps	51	1	2		191268	6359750	$b 99,00
664	Marina (Dorival Caymmi)	53	1	7		172643	5523628	$b 99,00
665	Aquarela (Toquinho)	53	1	7		259944	8480140	$b 99,00
667	Dona (Roupa Nova)	53	1	7		243356	7991295	$b 99,00
670	Romaria (Renato Teixeira)	53	1	7		244793	8033885	$b 99,00
672	Wave (Os Cariocas)	53	1	7		130063	4298006	$b 99,00
673	Garota de Ipanema (Dick Farney)	53	1	7		174367	5767474	$b 99,00
675	Susie Q	54	1	1	Hawkins-Lewis-Broadwater	275565	9043825	$b 99,00
676	I Put A Spell On You	54	1	1	Jay Hawkins	272091	8943000	$b 99,00
677	Proud Mary	54	1	1	J. C. Fogerty	189022	6229590	$b 99,00
678	Bad Moon Rising	54	1	1	J. C. Fogerty	140146	4609835	$b 99,00
679	Lodi	54	1	1	J. C. Fogerty	191451	6260214	$b 99,00
680	Green River	54	1	1	J. C. Fogerty	154279	5105874	$b 99,00
681	Commotion	54	1	1	J. C. Fogerty	162899	5354252	$b 99,00
682	Down On The Corner	54	1	1	J. C. Fogerty	164858	5521804	$b 99,00
683	Fortunate Son	54	1	1	J. C. Fogerty	140329	4617559	$b 99,00
684	Travelin' Band	54	1	1	J. C. Fogerty	129358	4270414	$b 99,00
685	Who'll Stop The Rain	54	1	1	J. C. Fogerty	149394	4899579	$b 99,00
686	Up Around The Bend	54	1	1	J. C. Fogerty	162429	5368701	$b 99,00
687	Run Through The Jungle	54	1	1	J. C. Fogerty	186044	6156567	$b 99,00
688	Lookin' Out My Back Door	54	1	1	J. C. Fogerty	152946	5034670	$b 99,00
689	Long As I Can See The Light	54	1	1	J. C. Fogerty	213237	6924024	$b 99,00
690	I Heard It Through The Grapevine	54	1	1	Whitfield-Strong	664894	21947845	$b 99,00
691	Have You Ever Seen The Rain?	54	1	1	J. C. Fogerty	160052	5263675	$b 99,00
692	Hey Tonight	54	1	1	J. C. Fogerty	162847	5343807	$b 99,00
693	Sweet Hitch-Hiker	54	1	1	J. C. Fogerty	175490	5716603	$b 99,00
694	Someday Never Comes	54	1	1	J. C. Fogerty	239360	7945235	$b 99,00
695	Walking On The Water	55	1	1	J.C. Fogerty	281286	9302129	$b 99,00
696	Suzie-Q, Pt. 2	55	1	1	J.C. Fogerty	244114	7986637	$b 99,00
697	Born On The Bayou	55	1	1	J.C. Fogerty	316630	10361866	$b 99,00
698	Good Golly Miss Molly	55	1	1	J.C. Fogerty	163604	5348175	$b 99,00
699	Tombstone Shadow	55	1	1	J.C. Fogerty	218880	7209080	$b 99,00
700	Wrote A Song For Everyone	55	1	1	J.C. Fogerty	296385	9675875	$b 99,00
701	Night Time Is The Right Time	55	1	1	J.C. Fogerty	190119	6211173	$b 99,00
702	Cotton Fields	55	1	1	J.C. Fogerty	178181	5919224	$b 99,00
703	It Came Out Of The Sky	55	1	1	J.C. Fogerty	176718	5807474	$b 99,00
704	Don't Look Now	55	1	1	J.C. Fogerty	131918	4366455	$b 99,00
705	The Midnight Special	55	1	1	J.C. Fogerty	253596	8297482	$b 99,00
706	Before You Accuse Me	55	1	1	J.C. Fogerty	207804	6815126	$b 99,00
707	My Baby Left Me	55	1	1	J.C. Fogerty	140460	4633440	$b 99,00
708	Pagan Baby	55	1	1	J.C. Fogerty	385619	12713813	$b 99,00
709	(Wish I Could) Hideaway	55	1	1	J.C. Fogerty	228466	7432978	$b 99,00
710	It's Just A Thought	55	1	1	J.C. Fogerty	237374	7778319	$b 99,00
711	Molina	55	1	1	J.C. Fogerty	163239	5390811	$b 99,00
712	Born To Move	55	1	1	J.C. Fogerty	342804	11260814	$b 99,00
713	Lookin' For A Reason	55	1	1	J.C. Fogerty	209789	6933135	$b 99,00
714	Hello Mary Lou	55	1	1	J.C. Fogerty	132832	4476563	$b 99,00
745	Comin' Home	58	1	1	Bolin/Coverdale/Paice	235781	7644604	$b 99,00
746	Lady Luck	58	1	1	Cook/Coverdale	168202	5501379	$b 99,00
747	Gettin' Tighter	58	1	1	Bolin/Hughes	218044	7176909	$b 99,00
748	Dealer	58	1	1	Bolin/Coverdale	230922	7591066	$b 99,00
749	I Need Love	58	1	1	Bolin/Coverdale	263836	8701064	$b 99,00
750	Drifter	58	1	1	Bolin/Coverdale	242834	8001505	$b 99,00
751	Love Child	58	1	1	Bolin/Coverdale	188160	6173806	$b 99,00
752	This Time Around / Owed to 'G' [Instrumental]	58	1	1	Bolin/Hughes/Lord	370102	11995679	$b 99,00
753	You Keep On Moving	58	1	1	Coverdale/Hughes	319111	10447868	$b 99,00
754	Speed King	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	264385	8587578	$b 99,00
755	Bloodsucker	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	256261	8344405	$b 99,00
756	Child In Time	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	620460	20230089	$b 99,00
757	Flight Of The Rat	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	478302	15563967	$b 99,00
758	Into The Fire	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	210259	6849310	$b 99,00
759	Living Wreck	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	274886	8993056	$b 99,00
760	Hard Lovin' Man	59	1	1	Blackmore, Gillan, Glover, Lord, Paice	431203	13931179	$b 99,00
761	Fireball	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	204721	6714807	$b 99,00
762	No No No	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	414902	13646606	$b 99,00
763	Strange Kind Of Woman	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	247092	8072036	$b 99,00
764	Anyone's Daughter	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	284682	9354480	$b 99,00
765	The Mule	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	322063	10638390	$b 99,00
766	Fools	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	500427	16279366	$b 99,00
767	No One Came	60	1	1	Ritchie Blackmore, Ian Gillan, Roger Glover, Jon Lord, Ian Paice	385880	12643813	$b 99,00
768	Knocking At Your Back Door	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover	424829	13779332	$b 99,00
769	Bad Attitude	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord	307905	10035180	$b 99,00
770	Child In Time (Son Of Aleric - Instrumental)	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord, Ian Paice	602880	19712753	$b 99,00
771	Nobody's Home	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord, Ian Paice	243017	7929493	$b 99,00
772	Black Night	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord, Ian Paice	368770	12058906	$b 99,00
773	Perfect Strangers	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover	321149	10445353	$b 99,00
774	The Unwritten Law	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Ian Paice	295053	9740361	$b 99,00
844	Groovus Interruptus	68	1	2	Jim Beard	319373	10602166	$b 99,00
775	Call Of The Wild	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord	293851	9575295	$b 99,00
776	Hush	61	1	1	South	213054	6944928	$b 99,00
777	Smoke On The Water	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord, Ian Paice	464378	15180849	$b 99,00
778	Space Trucking	61	1	1	Richie Blackmore, Ian Gillian, Roger Glover, Jon Lord, Ian Paice	341185	11122183	$b 99,00
779	Highway Star	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	368770	12012452	$b 99,00
780	Maybe I'm A Leo	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	290455	9502646	$b 99,00
781	Pictures Of Home	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	303777	9903835	$b 99,00
782	Never Before	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	239830	7832790	$b 99,00
783	Smoke On The Water	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	340871	11246496	$b 99,00
784	Lazy	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	442096	14397671	$b 99,00
785	Space Truckin'	62	1	1	Ian Gillan/Ian Paice/Jon Lord/Ritchie Blckmore/Roger Glover	272796	8981030	$b 99,00
786	Vavoom : Ted The Mechanic	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	257384	8510755	$b 99,00
872	Seduzir	70	1	7	Djavan	277524	9163253	$b 99,00
787	Loosen My Strings	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	359680	11702232	$b 99,00
788	Soon Forgotten	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	287791	9401383	$b 99,00
789	Sometimes I Feel Like Screaming	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	451840	14789410	$b 99,00
790	Cascades : I'm Not Your Lover	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	283689	9209693	$b 99,00
791	The Aviator	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	320992	10532053	$b 99,00
792	Rosa's Cantina	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	312372	10323804	$b 99,00
793	A Castle Full Of Rascals	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	311693	10159566	$b 99,00
794	A Touch Away	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	276323	9098561	$b 99,00
795	Hey Cisco	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	354089	11600029	$b 99,00
796	Somebody Stole My Guitar	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	249443	8180421	$b 99,00
797	The Purpendicular Waltz	63	1	1	Ian Gillan, Roger Glover, Jon Lord, Steve Morse, Ian Paice	283924	9299131	$b 99,00
798	King Of Dreams	64	1	1	Blackmore, Glover, Turner	328385	10733847	$b 99,00
799	The Cut Runs Deep	64	1	1	Blackmore, Glover, Turner, Lord, Paice	342752	11191650	$b 99,00
800	Fire In The Basement	64	1	1	Blackmore, Glover, Turner, Lord, Paice	283977	9267550	$b 99,00
801	Truth Hurts	64	1	1	Blackmore, Glover, Turner	314827	10224612	$b 99,00
802	Breakfast In Bed	64	1	1	Blackmore, Glover, Turner	317126	10323804	$b 99,00
803	Love Conquers All	64	1	1	Blackmore, Glover, Turner	227186	7328516	$b 99,00
804	Fortuneteller	64	1	1	Blackmore, Glover, Turner, Lord, Paice	349335	11369671	$b 99,00
805	Too Much Is Not Enough	64	1	1	Turner, Held, Greenwood	257724	8382800	$b 99,00
806	Wicked Ways	64	1	1	Blackmore, Glover, Turner, Lord, Paice	393691	12826582	$b 99,00
807	Stormbringer	65	1	1	D.Coverdale/R.Blackmore/Ritchie Blackmore	246413	8044864	$b 99,00
808	Love Don't Mean a Thing	65	1	1	D.Coverdale/G.Hughes/Glenn Hughes/I.Paice/Ian Paice/J.Lord/John Lord/R.Blackmore/Ritchie Blackmore	263862	8675026	$b 99,00
809	Holy Man	65	1	1	D.Coverdale/G.Hughes/Glenn Hughes/J.Lord/John Lord	270236	8818093	$b 99,00
810	Hold On	65	1	1	D.Coverdal/G.Hughes/Glenn Hughes/I.Paice/Ian Paice/J.Lord/John Lord	306860	10022428	$b 99,00
811	Lady Double Dealer	65	1	1	D.Coverdale/R.Blackmore/Ritchie Blackmore	201482	6554330	$b 99,00
812	You Can't Do it Right (With the One You Love)	65	1	1	D.Coverdale/G.Hughes/Glenn Hughes/R.Blackmore/Ritchie Blackmore	203755	6709579	$b 99,00
813	High Ball Shooter	65	1	1	D.Coverdale/G.Hughes/Glenn Hughes/I.Paice/Ian Paice/J.Lord/John Lord/R.Blackmore/Ritchie Blackmore	267833	8772471	$b 99,00
814	The Gypsy	65	1	1	D.Coverdale/G.Hughes/Glenn Hughes/I.Paice/Ian Paice/J.Lord/John Lord/R.Blackmore/Ritchie Blackmore	242886	7946614	$b 99,00
815	Soldier Of Fortune	65	1	1	D.Coverdale/R.Blackmore/Ritchie Blackmore	193750	6315321	$b 99,00
816	The Battle Rages On	66	1	1	ian paice/jon lord	356963	11626228	$b 99,00
817	Lick It Up	66	1	1	roger glover	240274	7792604	$b 99,00
818	Anya	66	1	1	jon lord/roger glover	392437	12754921	$b 99,00
819	Talk About Love	66	1	1	roger glover	247823	8072171	$b 99,00
820	Time To Kill	66	1	1	roger glover	351033	11354742	$b 99,00
821	Ramshackle Man	66	1	1	roger glover	334445	10874679	$b 99,00
822	A Twist In The Tail	66	1	1	roger glover	257462	8413103	$b 99,00
823	Nasty Piece Of Work	66	1	1	jon lord/roger glover	276662	9076997	$b 99,00
824	Solitaire	66	1	1	roger glover	282226	9157021	$b 99,00
825	One Man's Meat	66	1	1	roger glover	278804	9068960	$b 99,00
826	Pour Some Sugar On Me	67	1	1		292519	9518842	$b 99,00
827	Photograph	67	1	1		248633	8108507	$b 99,00
828	Love Bites	67	1	1		346853	11305791	$b 99,00
829	Let's Get Rocked	67	1	1		296019	9724150	$b 99,00
830	Two Steps Behind [Acoustic Version]	67	1	1		259787	8523388	$b 99,00
831	Animal	67	1	1		244741	7985133	$b 99,00
832	Heaven Is	67	1	1		214021	6988128	$b 99,00
833	Rocket	67	1	1		247248	8092463	$b 99,00
834	When Love & Hate Collide	67	1	1		257280	8364633	$b 99,00
835	Action	67	1	1		220604	7130830	$b 99,00
836	Make Love Like A Man	67	1	1		255660	8309725	$b 99,00
837	Armageddon It	67	1	1		322455	10522352	$b 99,00
838	Have You Ever Needed Someone So Bad	67	1	1		319320	10400020	$b 99,00
839	Rock Of Ages	67	1	1		248424	8150318	$b 99,00
840	Hysteria	67	1	1		355056	11622738	$b 99,00
841	Bringin' On The Heartbreak	67	1	1		272457	8853324	$b 99,00
842	Roll Call	68	1	2	Jim Beard	321358	10653494	$b 99,00
843	Otay	68	1	2	John Scofield, Robert Aries, Milton Chambers and Gary Grainger	423653	14176083	$b 99,00
845	Paris On Mine	68	1	2	Jon Herington	368875	12059507	$b 99,00
846	In Time	68	1	2	Sylvester Stewart	368953	12287103	$b 99,00
847	Plan B	68	1	2	Dean Brown, Dennis Chambers & Jim Beard	272039	9032315	$b 99,00
848	Outbreak	68	1	2	Jim Beard & Jon Herington	659226	21685807	$b 99,00
849	Baltimore, DC	68	1	2	John Scofield	346932	11394473	$b 99,00
850	Talkin Loud and Saying Nothin	68	1	2	James Brown & Bobby Byrd	360411	11994859	$b 99,00
852	Meu Bem-Querer	69	1	7		255608	8330047	$b 99,00
853	Cigano	69	1	7		304692	10037362	$b 99,00
854	Boa Noite	69	1	7		338755	11283582	$b 99,00
855	Fato Consumado	69	1	7		211565	7018586	$b 99,00
858	Esquinas	69	1	7		280999	9096726	$b 99,00
859	Se...	69	1	7		286432	9413777	$b 99,00
860	Eu Te Devoro	69	1	7		311614	10312775	$b 99,00
862	Acelerou	69	1	7		284081	9396942	$b 99,00
863	Um Amor Puro	69	1	7		327784	10687311	$b 99,00
864	Samurai	70	1	7	Djavan	330997	10872787	$b 99,00
865	Nem Um Dia	70	1	7	Djavan	337423	11181446	$b 99,00
866	Oceano	70	1	7	Djavan	217338	7026441	$b 99,00
868	Serrado	70	1	7	Djavan	295314	9842240	$b 99,00
869	Flor De Lis	70	1	7	Djavan	236355	7801108	$b 99,00
871	Azul	70	1	7	Djavan	253962	8381029	$b 99,00
873	A Carta	70	1	7	Djavan - Gabriel, O Pensador	347297	11493463	$b 99,00
874	Sina	70	1	7	Djavan	268173	8906539	$b 99,00
875	Acelerou	70	1	7	Djavan	284133	9391439	$b 99,00
876	Um Amor Puro	70	1	7	Djavan	327105	10664698	$b 99,00
891	Layla	72	1	6	Clapton/Gordon	430733	14115792	$b 99,00
892	Badge	72	1	6	Clapton/Harrison	163552	5322942	$b 99,00
893	I Feel Free	72	1	6	Bruce/Clapton	174576	5725684	$b 99,00
894	Sunshine Of Your Love	72	1	6	Bruce/Clapton	252891	8225889	$b 99,00
895	Crossroads	72	1	6	Clapton/Robert Johnson Arr: Eric Clapton	253335	8273540	$b 99,00
896	Strange Brew	72	1	6	Clapton/Collins/Pappalardi	167810	5489787	$b 99,00
897	White Room	72	1	6	Bruce/Clapton	301583	9872606	$b 99,00
898	Bell Bottom Blues	72	1	6	Clapton	304744	9946681	$b 99,00
899	Cocaine	72	1	6	Cale/Clapton	215928	7138399	$b 99,00
900	I Shot The Sheriff	72	1	6	Marley	263862	8738973	$b 99,00
901	After Midnight	72	1	6	Clapton/J. J. Cale	191320	6460941	$b 99,00
902	Swing Low Sweet Chariot	72	1	6	Clapton/Trad. Arr. Clapton	208143	6896288	$b 99,00
903	Lay Down Sally	72	1	6	Clapton/Levy	231732	7774207	$b 99,00
904	Knockin On Heavens Door	72	1	6	Clapton/Dylan	264411	8758819	$b 99,00
905	Wonderful Tonight	72	1	6	Clapton	221387	7326923	$b 99,00
906	Let It Grow	72	1	6	Clapton	297064	9742568	$b 99,00
907	Promises	72	1	6	Clapton/F.eldman/Linn	180401	6006154	$b 99,00
908	I Can't Stand It	72	1	6	Clapton	249730	8271980	$b 99,00
909	Signe	73	1	6	Eric Clapton	193515	6475042	$b 99,00
910	Before You Accuse Me	73	1	6	Eugene McDaniel	224339	7456807	$b 99,00
911	Hey Hey	73	1	6	Big Bill Broonzy	196466	6543487	$b 99,00
912	Tears In Heaven	73	1	6	Eric Clapton, Will Jennings	274729	9032835	$b 99,00
913	Lonely Stranger	73	1	6	Eric Clapton	328724	10894406	$b 99,00
914	Nobody Knows You When You're Down & Out	73	1	6	Jimmy Cox	231836	7669922	$b 99,00
915	Layla	73	1	6	Eric Clapton, Jim Gordon	285387	9490542	$b 99,00
916	Running On Faith	73	1	6	Jerry Lynn Williams	378984	12536275	$b 99,00
917	Walkin' Blues	73	1	6	Robert Johnson	226429	7435192	$b 99,00
918	Alberta	73	1	6	Traditional	222406	7412975	$b 99,00
919	San Francisco Bay Blues	73	1	6	Jesse Fuller	203363	6724021	$b 99,00
920	Malted Milk	73	1	6	Robert Johnson	216528	7096781	$b 99,00
921	Old Love	73	1	6	Eric Clapton, Robert Cray	472920	15780747	$b 99,00
922	Rollin' And Tumblin'	73	1	6	McKinley Morgenfield (Muddy Waters)	251768	8407355	$b 99,00
923	Collision	74	1	4	Jon Hudson/Mike Patton	204303	6656596	$b 99,00
924	Stripsearch	74	1	4	Jon Hudson/Mike Bordin/Mike Patton	270106	8861119	$b 99,00
925	Last Cup Of Sorrow	74	1	4	Bill Gould/Mike Patton	251663	8221247	$b 99,00
926	Naked In Front Of The Computer	74	1	4	Mike Patton	128757	4225077	$b 99,00
927	Helpless	74	1	4	Bill Gould/Mike Bordin/Mike Patton	326217	10753135	$b 99,00
928	Mouth To Mouth	74	1	4	Bill Gould/Jon Hudson/Mike Bordin/Mike Patton	228493	7505887	$b 99,00
929	Ashes To Ashes	74	1	4	Bill Gould/Jon Hudson/Mike Bordin/Mike Patton/Roddy Bottum	217391	7093746	$b 99,00
930	She Loves Me Not	74	1	4	Bill Gould/Mike Bordin/Mike Patton	209867	6887544	$b 99,00
931	Got That Feeling	74	1	4	Mike Patton	140852	4643227	$b 99,00
932	Paths Of Glory	74	1	4	Bill Gould/Jon Hudson/Mike Bordin/Mike Patton/Roddy Bottum	257253	8436300	$b 99,00
933	Home Sick Home	74	1	4	Mike Patton	119040	3898976	$b 99,00
934	Pristina	74	1	4	Bill Gould/Mike Patton	232698	7497361	$b 99,00
935	Land Of Sunshine	75	1	4		223921	7353567	$b 99,00
936	Caffeine	75	1	4		267937	8747367	$b 99,00
937	Midlife Crisis	75	1	4		263235	8628841	$b 99,00
938	RV	75	1	4		223242	7288162	$b 99,00
939	Smaller And Smaller	75	1	4		310831	10180103	$b 99,00
940	Everything's Ruined	75	1	4		273658	9010917	$b 99,00
941	Malpractice	75	1	4		241371	7900683	$b 99,00
942	Kindergarten	75	1	4		270680	8853647	$b 99,00
943	Be Aggressive	75	1	4		222432	7298027	$b 99,00
944	A Small Victory	75	1	4		297168	9733572	$b 99,00
945	Crack Hitler	75	1	4		279144	9162435	$b 99,00
946	Jizzlobber	75	1	4		398341	12926140	$b 99,00
947	Midnight Cowboy	75	1	4		251924	8242626	$b 99,00
948	Easy	75	1	4		185835	6073008	$b 99,00
949	Get Out	76	1	1	Mike Bordin, Billy Gould, Mike Patton	137482	4524972	$b 99,00
950	Ricochet	76	1	1	Mike Bordin, Billy Gould, Mike Patton	269400	8808812	$b 99,00
951	Evidence	76	1	1	Mike Bordin, Billy Gould, Mike Patton, Trey Spruance	293590	9626136	$b 99,00
952	The Gentle Art Of Making Enemies	76	1	1	Mike Bordin, Billy Gould, Mike Patton	209319	6908609	$b 99,00
953	Star A.D.	76	1	1	Mike Bordin, Billy Gould, Mike Patton	203807	6747658	$b 99,00
954	Cuckoo For Caca	76	1	1	Mike Bordin, Billy Gould, Mike Patton, Trey Spruance	222902	7388369	$b 99,00
955	Caralho Voador	76	1	1	Mike Bordin, Billy Gould, Mike Patton, Trey Spruance	242102	8029054	$b 99,00
956	Ugly In The Morning	76	1	1	Mike Bordin, Billy Gould, Mike Patton	186435	6224997	$b 99,00
957	Digging The Grave	76	1	1	Mike Bordin, Billy Gould, Mike Patton	185129	6109259	$b 99,00
958	Take This Bottle	76	1	1	Mike Bordin, Billy Gould, Mike Patton, Trey Spruance	298997	9779971	$b 99,00
959	King For A Day	76	1	1	Mike Bordin, Billy Gould, Mike Patton, Trey Spruance	395859	13163733	$b 99,00
960	What A Day	76	1	1	Mike Bordin, Billy Gould, Mike Patton	158275	5203430	$b 99,00
961	The Last To Know	76	1	1	Mike Bordin, Billy Gould, Mike Patton	267833	8736776	$b 99,00
962	Just A Man	76	1	1	Mike Bordin, Billy Gould, Mike Patton	336666	11031254	$b 99,00
963	Absolute Zero	76	1	1	Mike Bordin, Billy Gould, Mike Patton	181995	5929427	$b 99,00
964	From Out Of Nowhere	77	1	4	Faith No More	202527	6587802	$b 99,00
965	Epic	77	1	4	Faith No More	294008	9631296	$b 99,00
966	Falling To Pieces	77	1	4	Faith No More	316055	10333123	$b 99,00
967	Surprise! You're Dead!	77	1	4	Faith No More	147226	4823036	$b 99,00
968	Zombie Eaters	77	1	4	Faith No More	360881	11835367	$b 99,00
969	The Real Thing	77	1	4	Faith No More	493635	16233080	$b 99,00
970	Underwater Love	77	1	4	Faith No More	231993	7634387	$b 99,00
971	The Morning After	77	1	4	Faith No More	223764	7355898	$b 99,00
972	Woodpecker From Mars	77	1	4	Faith No More	340532	11174250	$b 99,00
973	War Pigs	77	1	4	Tony Iommi, Bill Ward, Geezer Butler, Ozzy Osbourne	464770	15267802	$b 99,00
974	Edge Of The World	77	1	4	Faith No More	250357	8235607	$b 99,00
975	Deixa Entrar	78	1	7		33619	1095012	$b 99,00
976	Falamansa Song	78	1	7		237165	7921313	$b 99,00
977	Xote Dos Milagres	78	1	7		269557	8897778	$b 99,00
981	Zeca Violeiro	78	1	7		143673	4781949	$b 99,00
982	Avisa	78	1	7		355030	11844320	$b 99,00
983	Principiando/Decolagem	78	1	7		116767	3923789	$b 99,00
984	Asas	78	1	7		231915	7711669	$b 99,00
985	Medo De Escuro	78	1	7		213760	7056323	$b 99,00
987	Minha Gata	78	1	7		181838	6039502	$b 99,00
988	Desaforo	78	1	7		174524	5853561	$b 99,00
989	In Your Honor	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	230191	7468463	$b 99,00
990	No Way Back	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	196675	6421400	$b 99,00
991	Best Of You	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	255712	8363467	$b 99,00
992	DOA	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	252186	8232342	$b 99,00
993	Hell	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	117080	3819255	$b 99,00
994	The Last Song	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	199523	6496742	$b 99,00
995	Free Me	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	278700	9109340	$b 99,00
996	Resolve	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	288731	9416186	$b 99,00
997	The Deepest Blues Are Black	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	238419	7735473	$b 99,00
998	End Over End	79	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett	352078	11395296	$b 99,00
999	Still	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	313182	10323157	$b 99,00
1000	What If I Do?	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	302994	9929799	$b 99,00
1001	Miracle	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	209684	6877994	$b 99,00
1002	Another Round	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	265848	8752670	$b 99,00
1003	Friend Of A Friend	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	193280	6355088	$b 99,00
1004	Over And Out	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	316264	10428382	$b 99,00
1005	On The Mend	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	271908	9071997	$b 99,00
1006	Virginia Moon	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	229198	7494639	$b 99,00
1007	Cold Day In The Sun	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	200724	6596617	$b 99,00
1008	Razor	80	1	1	Dave Grohl, Taylor Hawkins, Nate Mendel, Chris Shiflett/FOO FIGHTERS	293276	9721373	$b 99,00
1009	All My Life	81	1	4	Foo Fighters	263653	8665545	$b 99,00
1010	Low	81	1	4	Foo Fighters	268120	8847196	$b 99,00
1011	Have It All	81	1	4	Foo Fighters	298057	9729292	$b 99,00
1012	Times Like These	81	1	4	Foo Fighters	266370	8624691	$b 99,00
1013	Disenchanted Lullaby	81	1	4	Foo Fighters	273528	8919111	$b 99,00
1014	Tired Of You	81	1	4	Foo Fighters	311353	10094743	$b 99,00
1015	Halo	81	1	4	Foo Fighters	306442	10026371	$b 99,00
1016	Lonely As You	81	1	4	Foo Fighters	277185	9022628	$b 99,00
1017	Overdrive	81	1	4	Foo Fighters	270550	8793187	$b 99,00
1018	Burn Away	81	1	4	Foo Fighters	298396	9678073	$b 99,00
1019	Come Back	81	1	4	Foo Fighters	469968	15371980	$b 99,00
1020	Doll	82	1	1	Dave, Taylor, Nate, Chris	83487	2702572	$b 99,00
1021	Monkey Wrench	82	1	1	Dave, Taylor, Nate, Chris	231523	7527531	$b 99,00
1022	Hey, Johnny Park!	82	1	1	Dave, Taylor, Nate, Chris	248528	8079480	$b 99,00
1023	My Poor Brain	82	1	1	Dave, Taylor, Nate, Chris	213446	6973746	$b 99,00
1024	Wind Up	82	1	1	Dave, Taylor, Nate, Chris	152163	4950667	$b 99,00
1025	Up In Arms	82	1	1	Dave, Taylor, Nate, Chris	135732	4406227	$b 99,00
1026	My Hero	82	1	1	Dave, Taylor, Nate, Chris	260101	8472365	$b 99,00
1027	See You	82	1	1	Dave, Taylor, Nate, Chris	146782	4888173	$b 99,00
1028	Enough Space	82	1	1	Dave Grohl	157387	5169280	$b 99,00
1029	February Stars	82	1	1	Dave, Taylor, Nate, Chris	289306	9344875	$b 99,00
1030	Everlong	82	1	1	Dave Grohl	250749	8270816	$b 99,00
1031	Walking After You	82	1	1	Dave Grohl	303856	9898992	$b 99,00
1032	New Way Home	82	1	1	Dave, Taylor, Nate, Chris	342230	11205664	$b 99,00
1034	Strangers In The Night	83	1	12	berthold kaempfert/charles singleton/eddie snyder	155794	5055295	$b 99,00
1035	New York, New York	83	1	12	fred ebb/john kander	206001	6707993	$b 99,00
1036	I Get A Kick Out Of You	83	1	12	cole porter	194429	6332441	$b 99,00
1037	Something Stupid	83	1	12	carson c. parks	158615	5210643	$b 99,00
1038	Moon River	83	1	12	henry mancini/johnny mercer	198922	6395808	$b 99,00
1039	What Now My Love	83	1	12	carl sigman/gilbert becaud/pierre leroyer	149995	4913383	$b 99,00
1040	Summer Love	83	1	12	hans bradtke/heinz meier/johnny mercer	174994	5693242	$b 99,00
1041	For Once In My Life	83	1	12	orlando murden/ronald miller	171154	5557537	$b 99,00
1042	Love And Marriage	83	1	12	jimmy van heusen/sammy cahn	89730	2930596	$b 99,00
1043	They Can't Take That Away From Me	83	1	12	george gershwin/ira gershwin	161227	5240043	$b 99,00
1044	My Kind Of Town	83	1	12	jimmy van heusen/sammy cahn	188499	6119915	$b 99,00
1045	Fly Me To The Moon	83	1	12	bart howard	149263	4856954	$b 99,00
1046	I've Got You Under My Skin	83	1	12	cole porter	210808	6883787	$b 99,00
1047	The Best Is Yet To Come	83	1	12	carolyn leigh/cy coleman	173583	5633730	$b 99,00
1048	It Was A Very Good Year	83	1	12	ervin drake	266605	8554066	$b 99,00
1049	Come Fly With Me	83	1	12	jimmy van heusen/sammy cahn	190458	6231029	$b 99,00
1050	That's Life	83	1	12	dean kay thompson/kelly gordon	187010	6095727	$b 99,00
1051	The Girl From Ipanema	83	1	12	antonio carlos jobim/norman gimbel/vinicius de moraes	193750	6410674	$b 99,00
1052	The Lady Is A Tramp	83	1	12	lorenz hart/richard rodgers	184111	5987372	$b 99,00
1053	Bad, Bad Leroy Brown	83	1	12	jim croce	169900	5548581	$b 99,00
1054	Mack The Knife	83	1	12	bert brecht/kurt weill/marc blitzstein	292075	9541052	$b 99,00
1055	Loves Been Good To Me	83	1	12	rod mckuen	203964	6645365	$b 99,00
1056	L.A. Is My Lady	83	1	12	alan bergman/marilyn bergman/peggy lipton jones/quincy jones	193175	6378511	$b 99,00
1057	Entrando Na Sua (Intro)	84	1	7		179252	5840027	$b 99,00
1058	Nervosa	84	1	7		229537	7680421	$b 99,00
1059	Funk De Bamba (Com Fernanda Abreu)	84	1	7		237191	7866165	$b 99,00
1063	Funk Hum	84	1	7		244453	8084475	$b 99,00
1064	Forty Days (Com DJ Hum)	84	1	7		221727	7347172	$b 99,00
1065	Balada Da Paula	84	1	7	Emerson Villani	322821	10603717	$b 99,00
1066	Dujji	84	1	7		324597	10833935	$b 99,00
1067	Meu Guarda-Chuva	84	1	7		248528	8216625	$b 99,00
1069	Whistle Stop	84	1	7		526132	17533664	$b 99,00
1070	16 Toneladas	84	1	7		191634	6390885	$b 99,00
1071	Divirta-Se (Saindo Da Sua)	84	1	7		74919	2439206	$b 99,00
1072	Forty Days Instrumental	84	1	7		292493	9584317	$b 99,00
1088	Palco (Live)	86	1	7		238315	8026622	$b 99,00
1089	Is This Love (Live)	86	1	7		295262	9819759	$b 99,00
1090	Stir It Up (Live)	86	1	7		282409	9594738	$b 99,00
1091	Refavela (Live)	86	1	7		236695	7985305	$b 99,00
1092	Vendedor De Caranguejo (Live)	86	1	7		248842	8358128	$b 99,00
1093	Quanta (Live)	86	1	7		357485	11774865	$b 99,00
1094	Estrela (Live)	86	1	7		285309	9436411	$b 99,00
1095	Pela Internet (Live)	86	1	7		263471	8804401	$b 99,00
1098	Copacabana (Live)	86	1	7		289671	9673672	$b 99,00
1099	A Novidade (Live)	86	1	7		316969	10508000	$b 99,00
1100	Ghandi (Live)	86	1	7		222458	7481950	$b 99,00
1101	De Ouro E Marfim (Live)	86	1	7		234971	7838453	$b 99,00
1105	A Novidade	73	1	7	Gilberto Gil	324780	10765600	$b 99,00
1106	Tenho Sede	73	1	7	Gilberto Gil	261616	8708114	$b 99,00
1107	Refazenda	73	1	7	Gilberto Gil	218305	7237784	$b 99,00
1108	Realce	73	1	7	Gilberto Gil	264489	8847612	$b 99,00
1111	A Paz	73	1	7	Gilberto Gil	293093	9593064	$b 99,00
1112	Beira Mar	73	1	7	Gilberto Gil	295444	9597994	$b 99,00
1113	Sampa	73	1	7	Gilberto Gil	225697	7469905	$b 99,00
1115	Tempo Rei	73	1	7	Gilberto Gil	302733	10019269	$b 99,00
1116	Expresso 2222	73	1	7	Gilberto Gil	284760	9690577	$b 99,00
1118	Palco	73	1	7	Gilberto Gil	270550	9049901	$b 99,00
1119	Toda Menina Baiana	73	1	7	Gilberto Gil	278177	9351000	$b 99,00
1121	Straight Out Of Line	88	1	3	Sully Erna	259213	8511877	$b 99,00
1122	Faceless	88	1	3	Sully Erna	216006	6992417	$b 99,00
1123	Changes	88	1	3	Sully Erna; Tony Rombola	260022	8455835	$b 99,00
1124	Make Me Believe	88	1	3	Sully Erna	248607	8075050	$b 99,00
1125	I Stand Alone	88	1	3	Sully Erna	246125	8017041	$b 99,00
1126	Re-Align	88	1	3	Sully Erna	260884	8513891	$b 99,00
1127	I Fucking Hate You	88	1	3	Sully Erna	247170	8059642	$b 99,00
1128	Releasing The Demons	88	1	3	Sully Erna	252760	8276372	$b 99,00
1129	Dead And Broken	88	1	3	Sully Erna	251454	8206611	$b 99,00
1130	I Am	88	1	3	Sully Erna	239516	7803270	$b 99,00
1131	The Awakening	88	1	3	Sully Erna	89547	3035251	$b 99,00
1132	Serenity	88	1	3	Sully Erna; Tony Rombola	274834	9172976	$b 99,00
1134	Jesus Of Suburbia / City Of The Damned / I Don't Care / Dearly Beloved / Tales Of Another Broken Home	89	1	4	Billie Joe Armstrong/Green Day	548336	17875209	$b 99,00
1137	Are We The Waiting	89	1	4	Green Day	163004	5328329	$b 99,00
1138	St. Jimmy	89	1	4	Green Day	175307	5716589	$b 99,00
1139	Give Me Novacaine	89	1	4	Green Day	205871	6752485	$b 99,00
1140	She's A Rebel	89	1	4	Green Day	120528	3901226	$b 99,00
1141	Extraordinary Girl	89	1	4	Green Day	214021	6975177	$b 99,00
1142	Letterbomb	89	1	4	Green Day	246151	7980902	$b 99,00
1145	Whatsername	89	1	4	Green Day	252316	8244843	$b 99,00
1146	Welcome to the Jungle	90	2	1		273552	4538451	$b 99,00
1147	It's So Easy	90	2	1		202824	3394019	$b 99,00
1148	Nightrain	90	2	1		268537	4457283	$b 99,00
1149	Out Ta Get Me	90	2	1		263893	4382147	$b 99,00
1150	Mr. Brownstone	90	2	1		228924	3816323	$b 99,00
1151	Paradise City	90	2	1		406347	6687123	$b 99,00
1152	My Michelle	90	2	1		219961	3671299	$b 99,00
1153	Think About You	90	2	1		231640	3860275	$b 99,00
1154	Sweet Child O' Mine	90	2	1		356424	5879347	$b 99,00
1155	You're Crazy	90	2	1		197135	3301971	$b 99,00
1156	Anything Goes	90	2	1		206400	3451891	$b 99,00
1157	Rocket Queen	90	2	1		375349	6185539	$b 99,00
1158	Right Next Door to Hell	91	2	1		182321	3175950	$b 99,00
1159	Dust N' Bones	91	2	1		298374	5053742	$b 99,00
1160	Live and Let Die	91	2	1		184016	3203390	$b 99,00
1161	Don't Cry (Original)	91	2	1		284744	4833259	$b 99,00
1162	Perfect Crime	91	2	1		143637	2550030	$b 99,00
1163	You Ain't the First	91	2	1		156268	2754414	$b 99,00
1164	Bad Obsession	91	2	1		328282	5537678	$b 99,00
1165	Back off Bitch	91	2	1		303436	5135662	$b 99,00
1166	Double Talkin' Jive	91	2	1		203637	3520862	$b 99,00
1167	November Rain	91	2	1		537540	8923566	$b 99,00
1168	The Garden	91	2	1		322175	5438862	$b 99,00
1169	Garden of Eden	91	2	1		161539	2839694	$b 99,00
1170	Don't Damn Me	91	2	1		318901	5385886	$b 99,00
1171	Bad Apples	91	2	1		268351	4567966	$b 99,00
1172	Dead Horse	91	2	1		257600	4394014	$b 99,00
1173	Coma	91	2	1		616511	10201342	$b 99,00
1174	Civil War	92	1	3	Duff McKagan/Slash/W. Axl Rose	461165	15046579	$b 99,00
1175	14 Years	92	1	3	Izzy Stradlin'/W. Axl Rose	261355	8543664	$b 99,00
1176	Yesterdays	92	1	3	Billy/Del James/W. Axl Rose/West Arkeen	196205	6398489	$b 99,00
1177	Knockin' On Heaven's Door	92	1	3	Bob Dylan	336457	10986716	$b 99,00
1178	Get In The Ring	92	1	3	Duff McKagan/Slash/W. Axl Rose	341054	11134105	$b 99,00
1179	Shotgun Blues	92	1	3	W. Axl Rose	203206	6623916	$b 99,00
1180	Breakdown	92	1	3	W. Axl Rose	424960	13978284	$b 99,00
1181	Pretty Tied Up	92	1	3	Izzy Stradlin'	287477	9408754	$b 99,00
1182	Locomotive	92	1	3	Slash/W. Axl Rose	522396	17236842	$b 99,00
1183	So Fine	92	1	3	Duff McKagan	246491	8039484	$b 99,00
1184	Estranged	92	1	3	W. Axl Rose	563800	18343787	$b 99,00
1185	You Could Be Mine	92	1	3	Izzy Stradlin'/W. Axl Rose	343875	11207355	$b 99,00
1186	Don't Cry	92	1	3	Izzy Stradlin'/W. Axl Rose	284238	9222458	$b 99,00
1187	My World	92	1	3	W. Axl Rose	84532	2764045	$b 99,00
1188	Colibri	93	1	2	Richard Bull	361012	12055329	$b 99,00
1189	Love Is The Colour	93	1	2	R. Carless	251585	8419165	$b 99,00
1190	Magnetic Ocean	93	1	2	Patrick Claher/Richard Bull	321123	10720741	$b 99,00
1191	Deep Waters	93	1	2	Richard Bull	396460	13075359	$b 99,00
1192	L'Arc En Ciel De Miles	93	1	2	Kevin Robinson/Richard Bull	242390	8053997	$b 99,00
1193	Gypsy	93	1	2	Kevin Robinson	330997	11083374	$b 99,00
1194	Journey Into Sunlight	93	1	2	Jean Paul Maunick	249756	8241177	$b 99,00
1195	Sunchild	93	1	2	Graham Harvey	259970	8593143	$b 99,00
1196	Millenium	93	1	2	Maxton Gig Beesley Jnr.	379167	12511939	$b 99,00
1197	Thinking 'Bout Tomorrow	93	1	2	Fayyaz Virgi/Richard Bull	355395	11865384	$b 99,00
1198	Jacob's Ladder	93	1	2	Julian Crampton	367647	12201595	$b 99,00
1199	She Wears Black	93	1	2	G Harvey/R Hope-Taylor	528666	17617944	$b 99,00
1200	Dark Side Of The Cog	93	1	2	Jean Paul Maunick	377155	12491122	$b 99,00
1201	Different World	94	2	1		258692	4383764	$b 99,00
1202	These Colours Don't Run	94	2	1		412152	6883500	$b 99,00
1203	Brighter Than a Thousand Suns	94	2	1		526255	8721490	$b 99,00
1204	The Pilgrim	94	2	1		307593	5172144	$b 99,00
1205	The Longest Day	94	2	1		467810	7785748	$b 99,00
1206	Out of the Shadows	94	2	1		336896	5647303	$b 99,00
1207	The Reincarnation of Benjamin Breeg	94	2	1		442106	7367736	$b 99,00
1208	For the Greater Good of God	94	2	1		564893	9367328	$b 99,00
1209	Lord of Light	94	2	1		444614	7393698	$b 99,00
1210	The Legacy	94	2	1		562966	9314287	$b 99,00
1211	Hallowed Be Thy Name (Live) [Non Album Bonus Track]	94	2	1		431262	7205816	$b 99,00
1212	The Number Of The Beast	95	1	3	Steve Harris	294635	4718897	$b 99,00
1213	The Trooper	95	1	3	Steve Harris	235311	3766272	$b 99,00
1214	Prowler	95	1	3	Steve Harris	255634	4091904	$b 99,00
1215	Transylvania	95	1	3	Steve Harris	265874	4255744	$b 99,00
1216	Remember Tomorrow	95	1	3	Paul Di'Anno/Steve Harris	352731	5648438	$b 99,00
1217	Where Eagles Dare	95	1	3	Steve Harris	289358	4630528	$b 99,00
1218	Sanctuary	95	1	3	David Murray/Paul Di'Anno/Steve Harris	293250	4694016	$b 99,00
1219	Running Free	95	1	3	Paul Di'Anno/Steve Harris	228937	3663872	$b 99,00
1220	Run To The Hilss	95	1	3	Steve Harris	237557	3803136	$b 99,00
1221	2 Minutes To Midnight	95	1	3	Adrian Smith/Bruce Dickinson	337423	5400576	$b 99,00
1222	Iron Maiden	95	1	3	Steve Harris	324623	5195776	$b 99,00
1223	Hallowed Be Thy Name	95	1	3	Steve Harris	471849	7550976	$b 99,00
1224	Be Quick Or Be Dead	96	1	3	Bruce Dickinson/Janick Gers	196911	3151872	$b 99,00
1225	From Here To Eternity	96	1	3	Steve Harris	259866	4159488	$b 99,00
1226	Can I Play With Madness	96	1	3	Adrian Smith/Bruce Dickinson/Steve Harris	282488	4521984	$b 99,00
1227	Wasting Love	96	1	3	Bruce Dickinson/Janick Gers	347846	5566464	$b 99,00
1228	Tailgunner	96	1	3	Bruce Dickinson/Steve Harris	249469	3993600	$b 99,00
1229	The Evil That Men Do	96	1	3	Adrian Smith/Bruce Dickinson/Steve Harris	325929	5216256	$b 99,00
1230	Afraid To Shoot Strangers	96	1	3	Steve Harris	407980	6529024	$b 99,00
1231	Bring Your Daughter... To The Slaughter	96	1	3	Bruce Dickinson	317727	5085184	$b 99,00
1232	Heaven Can Wait	96	1	3	Steve Harris	448574	7178240	$b 99,00
1233	The Clairvoyant	96	1	3	Steve Harris	269871	4319232	$b 99,00
1234	Fear Of The Dark	96	1	3	Steve Harris	431333	6906078	$b 99,00
1235	The Wicker Man	97	1	1	Adrian Smith/Bruce Dickinson/Steve Harris	275539	11022464	$b 99,00
1236	Ghost Of The Navigator	97	1	1	Bruce Dickinson/Janick Gers/Steve Harris	410070	16404608	$b 99,00
1237	Brave New World	97	1	1	Bruce Dickinson/David Murray/Steve Harris	378984	15161472	$b 99,00
1238	Blood Brothers	97	1	1	Steve Harris	434442	17379456	$b 99,00
1239	The Mercenary	97	1	1	Janick Gers/Steve Harris	282488	11300992	$b 99,00
1240	Dream Of Mirrors	97	1	1	Janick Gers/Steve Harris	561162	22448256	$b 99,00
1241	The Fallen Angel	97	1	1	Adrian Smith/Steve Harris	240718	9629824	$b 99,00
1242	The Nomad	97	1	1	David Murray/Steve Harris	546115	21846144	$b 99,00
1243	Out Of The Silent Planet	97	1	1	Bruce Dickinson/Janick Gers/Steve Harris	385541	15423616	$b 99,00
1244	The Thin Line Between Love & Hate	97	1	1	David Murray/Steve Harris	506801	20273280	$b 99,00
1245	Wildest Dreams	98	1	13	Adrian Smith/Steve Harris	232777	9312384	$b 99,00
1246	Rainmaker	98	1	13	Bruce Dickinson/David Murray/Steve Harris	228623	9146496	$b 99,00
1247	No More Lies	98	1	13	Steve Harris	441782	17672320	$b 99,00
1248	Montsegur	98	1	13	Bruce Dickinson/Janick Gers/Steve Harris	350484	14020736	$b 99,00
1249	Dance Of Death	98	1	13	Janick Gers/Steve Harris	516649	20670727	$b 99,00
1250	Gates Of Tomorrow	98	1	13	Bruce Dickinson/Janick Gers/Steve Harris	312032	12482688	$b 99,00
1251	New Frontier	98	1	13	Adrian Smith/Bruce Dickinson/Nicko McBrain	304509	12181632	$b 99,00
1252	Paschendale	98	1	13	Adrian Smith/Steve Harris	508107	20326528	$b 99,00
1253	Face In The Sand	98	1	13	Adrian Smith/Bruce Dickinson/Steve Harris	391105	15648948	$b 99,00
1254	Age Of Innocence	98	1	13	David Murray/Steve Harris	370468	14823478	$b 99,00
1255	Journeyman	98	1	13	Bruce Dickinson/David Murray/Steve Harris	427023	17082496	$b 99,00
1256	Be Quick Or Be Dead	99	1	1	Bruce Dickinson/Janick Gers	204512	8181888	$b 99,00
1257	From Here To Eternity	99	1	1	Steve Harris	218357	8739038	$b 99,00
1258	Afraid To Shoot Strangers	99	1	1	Steve Harris	416496	16664589	$b 99,00
1259	Fear Is The Key	99	1	1	Bruce Dickinson/Janick Gers	335307	13414528	$b 99,00
1260	Childhood's End	99	1	1	Steve Harris	280607	11225216	$b 99,00
1261	Wasting Love	99	1	1	Bruce Dickinson/Janick Gers	350981	14041216	$b 99,00
1262	The Fugitive	99	1	1	Steve Harris	294112	11765888	$b 99,00
1263	Chains Of Misery	99	1	1	Bruce Dickinson/David Murray	217443	8700032	$b 99,00
1264	The Apparition	99	1	1	Janick Gers/Steve Harris	234605	9386112	$b 99,00
1265	Judas Be My Guide	99	1	1	Bruce Dickinson/David Murray	188786	7553152	$b 99,00
1266	Weekend Warrior	99	1	1	Janick Gers/Steve Harris	339748	13594678	$b 99,00
1267	Fear Of The Dark	99	1	1	Steve Harris	436976	17483789	$b 99,00
1268	01 - Prowler	100	1	6	Steve Harris	236173	5668992	$b 99,00
1269	02 - Sanctuary	100	1	6	David Murray/Paul Di'Anno/Steve Harris	196284	4712576	$b 99,00
1272	05 - Phantom of the Opera	100	1	6	Steve Harris	428016	10276872	$b 99,00
1273	06 - Transylvania	100	1	6	Steve Harris	259343	6226048	$b 99,00
1274	07 - Strange World	100	1	6	Steve Harris	332460	7981184	$b 99,00
1275	08 - Charlotte the Harlot	100	1	6	Murray  Dave	252708	6066304	$b 99,00
1276	09 - Iron Maiden	100	1	6	Steve Harris	216058	5189891	$b 99,00
1277	The Ides Of March	101	1	13	Steve Harris	105926	2543744	$b 99,00
1278	Wrathchild	101	1	13	Steve Harris	174471	4188288	$b 99,00
1279	Murders In The Rue Morgue	101	1	13	Steve Harris	258377	6205786	$b 99,00
1280	Another Life	101	1	13	Steve Harris	203049	4874368	$b 99,00
1281	Genghis Khan	101	1	13	Steve Harris	187141	4493440	$b 99,00
1283	Killers	101	1	13	Steve Harris	300956	7227440	$b 99,00
1284	Prodigal Son	101	1	13	Steve Harris	372349	8937600	$b 99,00
1285	Purgatory	101	1	13	Steve Harris	200150	4804736	$b 99,00
1286	Drifter	101	1	13	Steve Harris	288757	6934660	$b 99,00
1287	Intro- Churchill S Speech	102	1	13		48013	1154488	$b 99,00
1288	Aces High	102	1	13		276375	6635187	$b 99,00
1289	2 Minutes To Midnight	102	1	3	Smith/Dickinson	366550	8799380	$b 99,00
1290	The Trooper	102	1	3	Harris	268878	6455255	$b 99,00
1291	Revelations	102	1	3	Dickinson	371826	8926021	$b 99,00
1292	Flight Of Icarus	102	1	3	Smith/Dickinson	229982	5521744	$b 99,00
1293	Rime Of The Ancient Mariner	102	1	3		789472	18949518	$b 99,00
1294	Powerslave	102	1	3		454974	10921567	$b 99,00
1295	The Number Of The Beast	102	1	3	Harris	275121	6605094	$b 99,00
1296	Hallowed Be Thy Name	102	1	3	Harris	451422	10836304	$b 99,00
1297	Iron Maiden	102	1	3	Harris	261955	6289117	$b 99,00
1298	Run To The Hills	102	1	3	Harris	231627	5561241	$b 99,00
1299	Running Free	102	1	3	Harris/Di Anno	204617	4912986	$b 99,00
1300	Wrathchild	102	1	13	Steve Harris	183666	4410181	$b 99,00
1301	Acacia Avenue	102	1	13		379872	9119118	$b 99,00
1302	Children Of The Damned	102	1	13	Steve Harris	278177	6678446	$b 99,00
1303	Die With Your Boots On	102	1	13	Adrian Smith/Bruce Dickinson/Steve Harris	314174	7542367	$b 99,00
1304	Phantom Of The Opera	102	1	13	Steve Harris	441155	10589917	$b 99,00
1305	Be Quick Or Be Dead	103	1	1		233142	5599853	$b 99,00
1306	The Number Of The Beast	103	1	1		294008	7060625	$b 99,00
1307	Wrathchild	103	1	1		174106	4182963	$b 99,00
1308	From Here To Eternity	103	1	1		284447	6831163	$b 99,00
1309	Can I Play With Madness	103	1	1		213106	5118995	$b 99,00
1310	Wasting Love	103	1	1		336953	8091301	$b 99,00
1311	Tailgunner	103	1	1		247640	5947795	$b 99,00
1312	The Evil That Men Do	103	1	1		478145	11479913	$b 99,00
1313	Afraid To Shoot Strangers	103	1	1		412525	9905048	$b 99,00
1314	Fear Of The Dark	103	1	1		431542	10361452	$b 99,00
1315	Bring Your Daughter... To The Slaughter...	104	1	1		376711	9045532	$b 99,00
1316	The Clairvoyant	104	1	1		262426	6302648	$b 99,00
1317	Heaven Can Wait	104	1	1		440555	10577743	$b 99,00
1318	Run To The Hills	104	1	1		235859	5665052	$b 99,00
1319	2 Minutes To Midnight	104	1	1	Adrian Smith/Bruce Dickinson	338233	8122030	$b 99,00
1320	Iron Maiden	104	1	1		494602	11874875	$b 99,00
1321	Hallowed Be Thy Name	104	1	1		447791	10751410	$b 99,00
1322	The Trooper	104	1	1		232672	5588560	$b 99,00
1323	Sanctuary	104	1	1		318511	7648679	$b 99,00
1324	Running Free	104	1	1		474017	11380851	$b 99,00
1325	Tailgunner	105	1	3	Bruce Dickinson/Steve Harris	255582	4089856	$b 99,00
1326	Holy Smoke	105	1	3	Bruce Dickinson/Steve Harris	229459	3672064	$b 99,00
1327	No Prayer For The Dying	105	1	3	Steve Harris	263941	4225024	$b 99,00
1328	Public Enema Number One	105	1	3	Bruce Dickinson/David Murray	254197	4071587	$b 99,00
1329	Fates Warning	105	1	3	David Murray/Steve Harris	250853	4018088	$b 99,00
1330	The Assassin	105	1	3	Steve Harris	258768	4141056	$b 99,00
1331	Run Silent Run Deep	105	1	3	Bruce Dickinson/Steve Harris	275408	4407296	$b 99,00
1332	Hooks In You	105	1	3	Adrian Smith/Bruce Dickinson	247510	3960832	$b 99,00
1333	Bring Your Daughter... ...To The Slaughter	105	1	3	Bruce Dickinson	284238	4548608	$b 99,00
1334	Mother Russia	105	1	3	Steve Harris	332617	5322752	$b 99,00
1335	Where Eagles Dare	106	1	3	Steve Harris	369554	5914624	$b 99,00
1336	Revelations	106	1	3	Bruce Dickinson	408607	6539264	$b 99,00
1337	Flight Of The Icarus	106	1	3	Adrian Smith/Bruce Dickinson	230269	3686400	$b 99,00
1338	Die With Your Boots On	106	1	3	Adrian Smith/Bruce Dickinson/Steve Harris	325694	5212160	$b 99,00
1339	The Trooper	106	1	3	Steve Harris	251454	4024320	$b 99,00
1340	Still Life	106	1	3	David Murray/Steve Harris	294347	4710400	$b 99,00
1341	Quest For Fire	106	1	3	Steve Harris	221309	3543040	$b 99,00
1342	Sun And Steel	106	1	3	Adrian Smith/Bruce Dickinson	206367	3306324	$b 99,00
1343	To Tame A Land	106	1	3	Steve Harris	445283	7129264	$b 99,00
1344	Aces High	107	1	3	Harris	269531	6472088	$b 99,00
1345	2 Minutes To Midnight	107	1	3	Smith/Dickinson	359810	8638809	$b 99,00
1346	Losfer Words	107	1	3	Steve Harris	252891	6074756	$b 99,00
1347	Flash of The Blade	107	1	3	Dickinson	242729	5828861	$b 99,00
1348	Duelists	107	1	3	Steve Harris	366471	8800686	$b 99,00
1349	Back in the Village	107	1	3	Dickinson/Smith	320548	7696518	$b 99,00
1350	Powerslave	107	1	3	Dickinson	407823	9791106	$b 99,00
1351	Rime of the Ancient Mariner	107	1	3	Harris	816509	19599577	$b 99,00
1352	Intro	108	1	3		115931	4638848	$b 99,00
1353	The Wicker Man	108	1	3	Adrian Smith/Bruce Dickinson/Steve Harris	281782	11272320	$b 99,00
1354	Ghost Of The Navigator	108	1	3	Bruce Dickinson/Janick Gers/Steve Harris	408607	16345216	$b 99,00
1355	Brave New World	108	1	3	Bruce Dickinson/David Murray/Steve Harris	366785	14676148	$b 99,00
1356	Wrathchild	108	1	3	Steve Harris	185808	7434368	$b 99,00
1357	2 Minutes To Midnight	108	1	3	Adrian Smith/Bruce Dickinson	386821	15474816	$b 99,00
1358	Blood Brothers	108	1	3	Steve Harris	435513	17422464	$b 99,00
1359	Sign Of The Cross	108	1	3	Steve Harris	649116	25966720	$b 99,00
1360	The Mercenary	108	1	3	Janick Gers/Steve Harris	282697	11309184	$b 99,00
1361	The Trooper	108	1	3	Steve Harris	273528	10942592	$b 99,00
1362	Dream Of Mirrors	109	1	1	Janick Gers/Steve Harris	578324	23134336	$b 99,00
1363	The Clansman	109	1	1	Steve Harris	559203	22370432	$b 99,00
1364	The Evil That Men Do	109	1	3	Adrian Smith/Bruce Dickinson/Steve Harris	280737	11231360	$b 99,00
1365	Fear Of The Dark	109	1	1	Steve Harris	460695	18430080	$b 99,00
1366	Iron Maiden	109	1	1	Steve Harris	351869	14076032	$b 99,00
1367	The Number Of The Beast	109	1	1	Steve Harris	300434	12022107	$b 99,00
1368	Hallowed Be Thy Name	109	1	1	Steve Harris	443977	17760384	$b 99,00
1369	Sanctuary	109	1	1	David Murray/Paul Di'Anno/Steve Harris	317335	12695680	$b 99,00
1370	Run To The Hills	109	1	1	Steve Harris	292179	11688064	$b 99,00
1371	Moonchild	110	1	3	Adrian Smith; Bruce Dickinson	340767	8179151	$b 99,00
1372	Infinite Dreams	110	1	3	Steve Harris	369005	8858669	$b 99,00
1373	Can I Play With Madness	110	1	3	Adrian Smith; Bruce Dickinson; Steve Harris	211043	5067867	$b 99,00
1374	The Evil That Men Do	110	1	3	Adrian Smith; Bruce Dickinson; Steve Harris	273998	6578930	$b 99,00
1452	Were Do We Go From Here	117	1	14	Jay Kay	313626	10504158	$b 99,00
1375	Seventh Son of a Seventh Son	110	1	3	Steve Harris	593580	14249000	$b 99,00
1376	The Prophecy	110	1	3	Dave Murray; Steve Harris	305475	7334450	$b 99,00
1377	The Clairvoyant	110	1	3	Adrian Smith; Bruce Dickinson; Steve Harris	267023	6411510	$b 99,00
1378	Only the Good Die Young	110	1	3	Bruce Dickinson; Harris	280894	6744431	$b 99,00
1379	Caught Somewhere in Time	111	1	3	Steve Harris	445779	10701149	$b 99,00
1380	Wasted Years	111	1	3	Adrian Smith	307565	7384358	$b 99,00
1381	Sea of Madness	111	1	3	Adrian Smith	341995	8210695	$b 99,00
1382	Heaven Can Wait	111	1	3	Steve Harris	441417	10596431	$b 99,00
1383	Stranger in a Strange Land	111	1	3	Adrian Smith	344502	8270899	$b 99,00
1384	Alexander the Great	111	1	3	Steve Harris	515631	12377742	$b 99,00
1385	De Ja Vu	111	1	3	David Murray/Steve Harris	296176	7113035	$b 99,00
1386	The Loneliness of the Long Dis	111	1	3	Steve Harris	391314	9393598	$b 99,00
1387	22 Acacia Avenue	112	1	3	Adrian Smith/Steve Harris	395572	5542516	$b 99,00
1388	Children of the Damned	112	1	3	Steve Harris	274364	3845631	$b 99,00
1389	Gangland	112	1	3	Adrian Smith/Clive Burr/Steve Harris	228440	3202866	$b 99,00
1390	Hallowed Be Thy Name	112	1	3	Steve Harris	428669	6006107	$b 99,00
1391	Invaders	112	1	3	Steve Harris	203180	2849181	$b 99,00
1392	Run to the Hills	112	1	3	Steve Harris	228884	3209124	$b 99,00
1393	The Number Of The Beast	112	1	1	Steve Harris	293407	11737216	$b 99,00
1394	The Prisoner	112	1	3	Adrian Smith/Steve Harris	361299	5062906	$b 99,00
1395	Sign Of The Cross	113	1	1	Steve Harris	678008	27121792	$b 99,00
1396	Lord Of The Flies	113	1	1	Janick Gers/Steve Harris	303699	12148864	$b 99,00
1397	Man On The Edge	113	1	1	Blaze Bayley/Janick Gers	253413	10137728	$b 99,00
1398	Fortunes Of War	113	1	1	Steve Harris	443977	17760384	$b 99,00
1399	Look For The Truth	113	1	1	Blaze Bayley/Janick Gers/Steve Harris	310230	12411008	$b 99,00
1400	The Aftermath	113	1	1	Blaze Bayley/Janick Gers/Steve Harris	380786	15233152	$b 99,00
1401	Judgement Of Heaven	113	1	1	Steve Harris	312476	12501120	$b 99,00
1402	Blood On The World's Hands	113	1	1	Steve Harris	357799	14313600	$b 99,00
1403	The Edge Of Darkness	113	1	1	Blaze Bayley/Janick Gers/Steve Harris	399333	15974528	$b 99,00
1404	2 A.M.	113	1	1	Blaze Bayley/Janick Gers/Steve Harris	337658	13511087	$b 99,00
1405	The Unbeliever	113	1	1	Janick Gers/Steve Harris	490422	19617920	$b 99,00
1406	Futureal	114	1	1	Blaze Bayley/Steve Harris	175777	7032960	$b 99,00
1407	The Angel And The Gambler	114	1	1	Steve Harris	592744	23711872	$b 99,00
1408	Lightning Strikes Twice	114	1	1	David Murray/Steve Harris	290377	11616384	$b 99,00
1409	The Clansman	114	1	1	Steve Harris	539689	21592327	$b 99,00
1410	When Two Worlds Collide	114	1	1	Blaze Bayley/David Murray/Steve Harris	377312	15093888	$b 99,00
1411	The Educated Fool	114	1	1	Steve Harris	404767	16191616	$b 99,00
1412	Don't Look To The Eyes Of A Stranger	114	1	1	Steve Harris	483657	19347584	$b 99,00
1413	Como Estais Amigos	114	1	1	Blaze Bayley/Janick Gers	330292	13213824	$b 99,00
1414	Please Please Please	115	1	14	James Brown/Johnny Terry	165067	5394585	$b 99,00
1415	Think	115	1	14	Lowman Pauling	166739	5513208	$b 99,00
1416	Night Train	115	1	14	Jimmy Forrest/Lewis C. Simpkins/Oscar Washington	212401	7027377	$b 99,00
1417	Out Of Sight	115	1	14	Ted Wright	143725	4711323	$b 99,00
1418	Papa's Got A Brand New Bag Pt.1	115	1	14	James Brown	127399	4174420	$b 99,00
1419	I Got You (I Feel Good)	115	1	14	James Brown	167392	5468472	$b 99,00
1420	It's A Man's Man's Man's World	115	1	14	Betty Newsome/James Brown	168228	5541611	$b 99,00
1421	Cold Sweat	115	1	14	Alfred Ellis/James Brown	172408	5643213	$b 99,00
1422	Say It Loud, I'm Black And I'm Proud Pt.1	115	1	14	Alfred Ellis/James Brown	167392	5478117	$b 99,00
1423	Get Up (I Feel Like Being A) Sex Machine	115	1	14	Bobby Byrd/James Brown/Ron Lenhoff	316551	10498031	$b 99,00
1424	Hey America	115	1	14	Addie William Jones/Nat Jones	218226	7187857	$b 99,00
1425	Make It Funky Pt.1	115	1	14	Charles Bobbitt/James Brown	196231	6507782	$b 99,00
1426	I'm A Greedy Man Pt.1	115	1	14	Charles Bobbitt/James Brown	217730	7251211	$b 99,00
1427	Get On The Good Foot	115	1	14	Fred Wesley/James Brown/Joseph Mims	215902	7182736	$b 99,00
1428	Get Up Offa That Thing	115	1	14	Deanna Brown/Deidra Jenkins/Yamma Brown	250723	8355989	$b 99,00
1429	It's Too Funky In Here	115	1	14	Brad Shapiro/George Jackson/Robert Miller/Walter Shaw	239072	7973979	$b 99,00
1430	Living In America	115	1	14	Charlie Midnight/Dan Hartman	282880	9432346	$b 99,00
1431	I'm Real	115	1	14	Full Force/James Brown	334236	11183457	$b 99,00
1432	Hot Pants Pt.1	115	1	14	Fred Wesley/James Brown	188212	6295110	$b 99,00
1433	Soul Power (Live)	115	1	14	James Brown	260728	8593206	$b 99,00
1434	When You Gonna Learn (Digeridoo)	116	1	1	Jay Kay/Kay, Jay	230635	7655482	$b 99,00
1435	Too Young To Die	116	1	1	Smith, Toby	365818	12391660	$b 99,00
1436	Hooked Up	116	1	1	Smith, Toby	275879	9301687	$b 99,00
1437	If I Like It, I Do It	116	1	1	Gelder, Nick van	293093	9848207	$b 99,00
1438	Music Of The Wind	116	1	1	Smith, Toby	383033	12870239	$b 99,00
1439	Emergency On Planet Earth	116	1	1	Smith, Toby	245263	8117218	$b 99,00
1440	Whatever It Is, I Just Can't Stop	116	1	1	Jay Kay/Kay, Jay	247222	8249453	$b 99,00
1441	Blow Your Mind	116	1	1	Smith, Toby	512339	17089176	$b 99,00
1442	Revolution 1993	116	1	1	Smith, Toby	616829	20816872	$b 99,00
1443	Didgin' Out	116	1	1	Buchanan, Wallis	157100	5263555	$b 99,00
1444	Canned Heat	117	1	14	Jay Kay	331964	11042037	$b 99,00
1445	Planet Home	117	1	14	Jay Kay/Toby Smith	284447	9566237	$b 99,00
1446	Black Capricorn Day	117	1	14	Jay Kay	341629	11477231	$b 99,00
1447	Soul Education	117	1	14	Jay Kay/Toby Smith	255477	8575435	$b 99,00
1448	Failling	117	1	14	Jay Kay/Toby Smith	225227	7503999	$b 99,00
1449	Destitute Illusions	117	1	14	Derrick McKenzie/Jay Kay/Toby Smith	340218	11452651	$b 99,00
1450	Supersonic	117	1	14	Jay Kay	315872	10699265	$b 99,00
1451	Butterfly	117	1	14	Jay Kay/Toby Smith	268852	8947356	$b 99,00
1453	King For A Day	117	1	14	Jay Kay/Toby Smith	221544	7335693	$b 99,00
1454	Deeper Underground	117	1	14	Toby Smith	281808	9351277	$b 99,00
1455	Just Another Story	118	1	15	Toby Smith	529684	17582818	$b 99,00
1456	Stillness In Time	118	1	15	Toby Smith	257097	8644290	$b 99,00
1457	Half The Man	118	1	15	Toby Smith	289854	9577679	$b 99,00
1458	Light Years	118	1	15	Toby Smith	354560	11796244	$b 99,00
1459	Manifest Destiny	118	1	15	Toby Smith	382197	12676962	$b 99,00
1460	The Kids	118	1	15	Toby Smith	309995	10334529	$b 99,00
1461	Mr. Moon	118	1	15	Stuard Zender/Toby Smith	329534	11043559	$b 99,00
1462	Scam	118	1	15	Stuart Zender	422321	14019705	$b 99,00
1463	Journey To Arnhemland	118	1	15	Toby Smith/Wallis Buchanan	322455	10843832	$b 99,00
1464	Morning Glory	118	1	15	J. Kay/Jay Kay	384130	12777210	$b 99,00
1465	Space Cowboy	118	1	15	J. Kay/Jay Kay	385697	12906520	$b 99,00
1466	Last Chance	119	1	4	C. Cester/C. Muncey	112352	3683130	$b 99,00
1467	Are You Gonna Be My Girl	119	1	4	C. Muncey/N. Cester	213890	6992324	$b 99,00
1468	Rollover D.J.	119	1	4	C. Cester/N. Cester	196702	6406517	$b 99,00
1469	Look What You've Done	119	1	4	N. Cester	230974	7517083	$b 99,00
1470	Get What You Need	119	1	4	C. Cester/C. Muncey/N. Cester	247719	8043765	$b 99,00
1471	Move On	119	1	4	C. Cester/N. Cester	260623	8519353	$b 99,00
1472	Radio Song	119	1	4	C. Cester/C. Muncey/N. Cester	272117	8871509	$b 99,00
1473	Get Me Outta Here	119	1	4	C. Cester/N. Cester	176274	5729098	$b 99,00
1474	Cold Hard Bitch	119	1	4	C. Cester/C. Muncey/N. Cester	243278	7929610	$b 99,00
1475	Come Around Again	119	1	4	C. Muncey/N. Cester	270497	8872405	$b 99,00
1476	Take It Or Leave It	119	1	4	C. Muncey/N. Cester	142889	4643370	$b 99,00
1477	Lazy Gun	119	1	4	C. Cester/N. Cester	282174	9186285	$b 99,00
1478	Timothy	119	1	4	C. Cester	270341	8856507	$b 99,00
1479	Foxy Lady	120	1	1	Jimi Hendrix	199340	6480896	$b 99,00
1480	Manic Depression	120	1	1	Jimi Hendrix	222302	7289272	$b 99,00
1481	Red House	120	1	1	Jimi Hendrix	224130	7285851	$b 99,00
1482	Can You See Me	120	1	1	Jimi Hendrix	153077	4987068	$b 99,00
1483	Love Or Confusion	120	1	1	Jimi Hendrix	193123	6329408	$b 99,00
1484	I Don't Live Today	120	1	1	Jimi Hendrix	235311	7661214	$b 99,00
1485	May This Be Love	120	1	1	Jimi Hendrix	191216	6240028	$b 99,00
1486	Fire	120	1	1	Jimi Hendrix	164989	5383075	$b 99,00
1487	Third Stone From The Sun	120	1	1	Jimi Hendrix	404453	13186975	$b 99,00
1488	Remember	120	1	1	Jimi Hendrix	168150	5509613	$b 99,00
1489	Are You Experienced?	120	1	1	Jimi Hendrix	254537	8292497	$b 99,00
1490	Hey Joe	120	1	1	Billy Roberts	210259	6870054	$b 99,00
1491	Stone Free	120	1	1	Jimi Hendrix	216293	7002331	$b 99,00
1492	Purple Haze	120	1	1	Jimi Hendrix	171572	5597056	$b 99,00
1493	51st Anniversary	120	1	1	Jimi Hendrix	196388	6398044	$b 99,00
1494	The Wind Cries Mary	120	1	1	Jimi Hendrix	200463	6540638	$b 99,00
1495	Highway Chile	120	1	1	Jimi Hendrix	212453	6887949	$b 99,00
1496	Surfing with the Alien	121	2	1		263707	4418504	$b 99,00
1497	Ice 9	121	2	1		239721	4036215	$b 99,00
1498	Crushing Day	121	2	1		314768	5232158	$b 99,00
1499	Always With Me, Always With You	121	2	1		202035	3435777	$b 99,00
1500	Satch Boogie	121	2	1		193560	3300654	$b 99,00
1501	Hill of the Skull	121	2	1	J. Satriani	108435	1944738	$b 99,00
1502	Circles	121	2	1		209071	3548553	$b 99,00
1503	Lords of Karma	121	2	1	J. Satriani	288227	4809279	$b 99,00
1504	Midnight	121	2	1	J. Satriani	102630	1851753	$b 99,00
1505	Echo	121	2	1	J. Satriani	337570	5595557	$b 99,00
1506	Engenho De Dentro	122	1	7		310073	10211473	$b 99,00
1507	Alcohol	122	1	7		355239	12010478	$b 99,00
1508	Mama Africa	122	1	7		283062	9488316	$b 99,00
1509	Salve Simpatia	122	1	7		343484	11314756	$b 99,00
1513	Charles Anjo 45	122	1	7		389276	13022833	$b 99,00
1516	Que Maravilha	122	1	7		338076	10996656	$b 99,00
1517	Santa Clara Clareou	122	1	7		380081	12524725	$b 99,00
1518	Filho Maravilha	122	1	7		227526	7498259	$b 99,00
1519	Taj Mahal	122	1	7		289750	9502898	$b 99,00
1520	Rapidamente	123	1	7		252238	8470107	$b 99,00
1521	As Dores do Mundo	123	1	7	Hyldon	255477	8537092	$b 99,00
1522	Vou Pra Ai	123	1	7		300878	10053718	$b 99,00
1523	My Brother	123	1	7		253231	8431821	$b 99,00
1528	A Tarde	123	1	7		266919	8836127	$b 99,00
1529	Always Be All Right	123	1	7		128078	4299676	$b 99,00
1530	Sem Sentido	123	1	7		250462	8292108	$b 99,00
1531	Onibusfobia	123	1	7		315977	10474904	$b 99,00
1546	The Green Manalishi	125	1	3		205792	6720789	$b 99,00
1547	Living After Midnight	125	1	3		213289	7056785	$b 99,00
1548	Breaking The Law (Live)	125	1	3		144195	4728246	$b 99,00
1549	Hot Rockin'	125	1	3		197328	6509179	$b 99,00
1550	Heading Out To The Highway (Live)	125	1	3		276427	9006022	$b 99,00
1551	The Hellion	125	1	3		41900	1351993	$b 99,00
1552	Electric Eye	125	1	3		222197	7231368	$b 99,00
1553	You've Got Another Thing Comin'	125	1	3		305162	9962558	$b 99,00
1554	Turbo Lover	125	1	3		335542	11068866	$b 99,00
1555	Freewheel Burning	125	1	3		265952	8713599	$b 99,00
1556	Some Heads Are Gonna Roll	125	1	3		249939	8198617	$b 99,00
1557	Metal Meltdown	125	1	3		290664	9390646	$b 99,00
1558	Ram It Down	125	1	3		292179	9554023	$b 99,00
1559	Diamonds And Rust (Live)	125	1	3		219350	7163147	$b 99,00
1560	Victim Of Change (Live)	125	1	3		430942	14067512	$b 99,00
1561	Tyrant (Live)	125	1	3		282253	9190536	$b 99,00
1562	Comin' Home	126	1	1	Paul Stanley, Ace Frehley	172068	5661120	$b 99,00
1563	Plaster Caster	126	1	1	Gene Simmons	198060	6528719	$b 99,00
1564	Goin' Blind	126	1	1	Gene Simmons, Stephen Coronel	217652	7167523	$b 99,00
1565	Do You Love Me	126	1	1	Paul Stanley, Bob Ezrin, Kim Fowley	193619	6343111	$b 99,00
1566	Domino	126	1	1	Gene Simmons	226377	7488191	$b 99,00
1567	Sure Know Something	126	1	1	Paul Stanley, Vincent Poncia	254354	8375190	$b 99,00
1568	A World Without Heroes	126	1	1	Paul Stanley, Gene Simmons, Bob Ezrin, Lewis Reed	177815	5832524	$b 99,00
1569	Rock Bottom	126	1	1	Paul Stanley, Ace Frehley	200594	6560818	$b 99,00
1570	See You Tonight	126	1	1	Gene Simmons	146494	4817521	$b 99,00
1571	I Still Love You	126	1	1	Paul Stanley	369815	12086145	$b 99,00
1572	Every Time I Look At You	126	1	1	Paul Stanley, Vincent Cusano	283898	9290948	$b 99,00
1573	2,000 Man	126	1	1	Mick Jagger, Keith Richard	312450	10292829	$b 99,00
1574	Beth	126	1	1	Peter Criss, Stan Penridge, Bob Ezrin	170187	5577807	$b 99,00
1575	Nothin' To Lose	126	1	1	Gene Simmons	222354	7351460	$b 99,00
1576	Rock And Roll All Nite	126	1	1	Paul Stanley, Gene Simmons	259631	8549296	$b 99,00
1577	Immigrant Song	127	1	1	Robert Plant	201247	6457766	$b 99,00
1578	Heartbreaker	127	1	1	John Bonham/John Paul Jones/Robert Plant	316081	10179657	$b 99,00
1579	Since I've Been Loving You	127	1	1	John Paul Jones/Robert Plant	416365	13471959	$b 99,00
1580	Black Dog	127	1	1	John Paul Jones/Robert Plant	317622	10267572	$b 99,00
1581	Dazed And Confused	127	1	1	Jimmy Page/Led Zeppelin	1116734	36052247	$b 99,00
1582	Stairway To Heaven	127	1	1	Robert Plant	529658	17050485	$b 99,00
1583	Going To California	127	1	1	Robert Plant	234605	7646749	$b 99,00
1584	That's The Way	127	1	1	Robert Plant	343431	11248455	$b 99,00
1585	Whole Lotta Love (Medley)	127	1	1	Arthur Crudup/Bernard Besman/Bukka White/Doc Pomus/John Bonham/John Lee Hooker/John Paul Jones/Mort Shuman/Robert Plant/Willie Dixon	825103	26742545	$b 99,00
1586	Thank You	127	1	1	Robert Plant	398262	12831826	$b 99,00
1587	We're Gonna Groove	128	1	1	Ben E.King/James Bethea	157570	5180975	$b 99,00
1588	Poor Tom	128	1	1	Jimmy Page/Robert Plant	182491	6016220	$b 99,00
1589	I Can't Quit You Baby	128	1	1	Willie Dixon	258168	8437098	$b 99,00
1590	Walter's Walk	128	1	1	Jimmy Page, Robert Plant	270785	8712499	$b 99,00
1591	Ozone Baby	128	1	1	Jimmy Page, Robert Plant	215954	7079588	$b 99,00
1592	Darlene	128	1	1	Jimmy Page, Robert Plant, John Bonham, John Paul Jones	307226	10078197	$b 99,00
1593	Bonzo's Montreux	128	1	1	John Bonham	258925	8557447	$b 99,00
1594	Wearing And Tearing	128	1	1	Jimmy Page, Robert Plant	330004	10701590	$b 99,00
1595	The Song Remains The Same	129	1	1	Jimmy Page/Jimmy Page & Robert Plant/Robert Plant	330004	10708950	$b 99,00
1596	The Rain Song	129	1	1	Jimmy Page/Jimmy Page & Robert Plant/Robert Plant	459180	15029875	$b 99,00
1597	Over The Hills And Far Away	129	1	1	Jimmy Page/Jimmy Page & Robert Plant/Robert Plant	290089	9552829	$b 99,00
1598	The Crunge	129	1	1	John Bonham/John Paul Jones	197407	6460212	$b 99,00
1599	Dancing Days	129	1	1	Jimmy Page/Jimmy Page & Robert Plant/Robert Plant	223216	7250104	$b 99,00
1600	D'Yer Mak'er	129	1	1	John Bonham/John Paul Jones	262948	8645935	$b 99,00
1601	No Quarter	129	1	1	John Paul Jones	420493	13656517	$b 99,00
1602	The Ocean	129	1	1	John Bonham/John Paul Jones	271098	8846469	$b 99,00
1603	In The Evening	130	1	1	Jimmy Page, Robert Plant & John Paul Jones	410566	13399734	$b 99,00
1604	South Bound Saurez	130	1	1	John Paul Jones & Robert Plant	254406	8420427	$b 99,00
1605	Fool In The Rain	130	1	1	Jimmy Page, Robert Plant & John Paul Jones	372950	12371433	$b 99,00
1606	Hot Dog	130	1	1	Jimmy Page & Robert Plant	197198	6536167	$b 99,00
1607	Carouselambra	130	1	1	John Paul Jones, Jimmy Page & Robert Plant	634435	20858315	$b 99,00
1608	All My Love	130	1	1	Robert Plant & John Paul Jones	356284	11684862	$b 99,00
1609	I'm Gonna Crawl	130	1	1	Jimmy Page, Robert Plant & John Paul Jones	329639	10737665	$b 99,00
1610	Black Dog	131	1	1	Jimmy Page, Robert Plant, John Paul Jones	296672	9660588	$b 99,00
1611	Rock & Roll	131	1	1	Jimmy Page, Robert Plant, John Paul Jones, John Bonham	220917	7142127	$b 99,00
1612	The Battle Of Evermore	131	1	1	Jimmy Page, Robert Plant	351555	11525689	$b 99,00
1613	Stairway To Heaven	131	1	1	Jimmy Page, Robert Plant	481619	15706767	$b 99,00
1614	Misty Mountain Hop	131	1	1	Jimmy Page, Robert Plant, John Paul Jones	278857	9092799	$b 99,00
1615	Four Sticks	131	1	1	Jimmy Page, Robert Plant	284447	9481301	$b 99,00
1616	Going To California	131	1	1	Jimmy Page, Robert Plant	215693	7068737	$b 99,00
1617	When The Levee Breaks	131	1	1	Jimmy Page, Robert Plant, John Paul Jones, John Bonham, Memphis Minnie	427702	13912107	$b 99,00
1618	Good Times Bad Times	132	1	1	Jimmy Page/John Bonham/John Paul Jones	166164	5464077	$b 99,00
1619	Babe I'm Gonna Leave You	132	1	1	Jimmy Page/Robert Plant	401475	13189312	$b 99,00
1620	You Shook Me	132	1	1	J. B. Lenoir/Willie Dixon	388179	12643067	$b 99,00
1621	Dazed and Confused	132	1	1	Jimmy Page	386063	12610326	$b 99,00
1622	Your Time Is Gonna Come	132	1	1	Jimmy Page/John Paul Jones	274860	9011653	$b 99,00
1623	Black Mountain Side	132	1	1	Jimmy Page	132702	4440602	$b 99,00
1624	Communication Breakdown	132	1	1	Jimmy Page/John Bonham/John Paul Jones	150230	4899554	$b 99,00
1625	I Can't Quit You Baby	132	1	1	Willie Dixon	282671	9252733	$b 99,00
1626	How Many More Times	132	1	1	Jimmy Page/John Bonham/John Paul Jones	508055	16541364	$b 99,00
1627	Whole Lotta Love	133	1	1	Jimmy Page, Robert Plant, John Paul Jones, John Bonham	334471	11026243	$b 99,00
1628	What Is And What Should Never Be	133	1	1	Jimmy Page, Robert Plant	287973	9369385	$b 99,00
1629	The Lemon Song	133	1	1	Jimmy Page, Robert Plant, John Paul Jones, John Bonham	379141	12463496	$b 99,00
1630	Thank You	133	1	1	Jimmy Page, Robert Plant	287791	9337392	$b 99,00
1631	Heartbreaker	133	1	1	Jimmy Page, Robert Plant, John Paul Jones, John Bonham	253988	8387560	$b 99,00
1632	Living Loving Maid (She's Just A Woman)	133	1	1	Jimmy Page, Robert Plant	159216	5219819	$b 99,00
1633	Ramble On	133	1	1	Jimmy Page, Robert Plant	275591	9199710	$b 99,00
1634	Moby Dick	133	1	1	John Bonham, John Paul Jones, Jimmy Page	260728	8664210	$b 99,00
1635	Bring It On Home	133	1	1	Jimmy Page, Robert Plant	259970	8494731	$b 99,00
1636	Immigrant Song	134	1	1	Jimmy Page, Robert Plant	144875	4786461	$b 99,00
1637	Friends	134	1	1	Jimmy Page, Robert Plant	233560	7694220	$b 99,00
1638	Celebration Day	134	1	1	Jimmy Page, Robert Plant, John Paul Jones	209528	6871078	$b 99,00
1639	Since I've Been Loving You	134	1	1	Jimmy Page, Robert Plant, John Paul Jones	444055	14482460	$b 99,00
1640	Out On The Tiles	134	1	1	Jimmy Page, Robert Plant, John Bonham	246047	8060350	$b 99,00
1641	Gallows Pole	134	1	1	Traditional	296228	9757151	$b 99,00
1642	Tangerine	134	1	1	Jimmy Page	189675	6200893	$b 99,00
1643	That's The Way	134	1	1	Jimmy Page, Robert Plant	337345	11202499	$b 99,00
1644	Bron-Y-Aur Stomp	134	1	1	Jimmy Page, Robert Plant, John Paul Jones	259500	8674508	$b 99,00
1645	Hats Off To (Roy) Harper	134	1	1	Traditional	219376	7236640	$b 99,00
1646	In The Light	135	1	1	John Paul Jones/Robert Plant	526785	17033046	$b 99,00
1647	Bron-Yr-Aur	135	1	1	Jimmy Page	126641	4150746	$b 99,00
1648	Down By The Seaside	135	1	1	Robert Plant	316186	10371282	$b 99,00
1649	Ten Years Gone	135	1	1	Robert Plant	393116	12756366	$b 99,00
1650	Night Flight	135	1	1	John Paul Jones/Robert Plant	217547	7160647	$b 99,00
1651	The Wanton Song	135	1	1	Robert Plant	249887	8180988	$b 99,00
1789	Praise	146	1	14	Marvin Gaye	235833	7839179	$b 99,00
1652	Boogie With Stu	135	1	1	Ian Stewart/John Bonham/John Paul Jones/Mrs. Valens/Robert Plant	233273	7657086	$b 99,00
1653	Black Country Woman	135	1	1	Robert Plant	273084	8951732	$b 99,00
1654	Sick Again	135	1	1	Robert Plant	283036	9279263	$b 99,00
1655	Achilles Last Stand	136	1	1	Jimmy Page/Robert Plant	625502	20593955	$b 99,00
1656	For Your Life	136	1	1	Jimmy Page/Robert Plant	384391	12633382	$b 99,00
1657	Royal Orleans	136	1	1	John Bonham/John Paul Jones	179591	5930027	$b 99,00
1658	Nobody's Fault But Mine	136	1	1	Jimmy Page/Robert Plant	376215	12237859	$b 99,00
1659	Candy Store Rock	136	1	1	Jimmy Page/Robert Plant	252055	8397423	$b 99,00
1660	Hots On For Nowhere	136	1	1	Jimmy Page/Robert Plant	284107	9342342	$b 99,00
1661	Tea For One	136	1	1	Jimmy Page/Robert Plant	566752	18475264	$b 99,00
1662	Rock & Roll	137	1	1	John Bonham/John Paul Jones/Robert Plant	242442	7897065	$b 99,00
1663	Celebration Day	137	1	1	John Paul Jones/Robert Plant	230034	7478487	$b 99,00
1664	The Song Remains The Same	137	1	1	Robert Plant	353358	11465033	$b 99,00
1665	Rain Song	137	1	1	Robert Plant	505808	16273705	$b 99,00
1666	Dazed And Confused	137	1	1	Jimmy Page	1612329	52490554	$b 99,00
1667	No Quarter	138	1	1	John Paul Jones/Robert Plant	749897	24399285	$b 99,00
1668	Stairway To Heaven	138	1	1	Robert Plant	657293	21354766	$b 99,00
1669	Moby Dick	138	1	1	John Bonham/John Paul Jones	766354	25345841	$b 99,00
1670	Whole Lotta Love	138	1	1	John Bonham/John Paul Jones/Robert Plant/Willie Dixon	863895	28191437	$b 99,00
1702	Are You Gonna Go My Way	141	1	1	Craig Ross/Lenny Kravitz	211591	6905135	$b 99,00
1703	Fly Away	141	1	1	Lenny Kravitz	221962	7322085	$b 99,00
1704	Rock And Roll Is Dead	141	1	1	Lenny Kravitz	204199	6680312	$b 99,00
1705	Again	141	1	1	Lenny Kravitz	228989	7490476	$b 99,00
1706	It Ain't Over 'Til It's Over	141	1	1	Lenny Kravitz	242703	8078936	$b 99,00
1707	Can't Get You Off My Mind	141	1	1	Lenny Kravitz	273815	8937150	$b 99,00
1708	Mr. Cab Driver	141	1	1	Lenny Kravitz	230321	7668084	$b 99,00
1709	American Woman	141	1	1	B. Cummings/G. Peterson/M.J. Kale/R. Bachman	261773	8538023	$b 99,00
1710	Stand By My Woman	141	1	1	Henry Kirssch/Lenny Kravitz/S. Pasch A. Krizan	259683	8447611	$b 99,00
1711	Always On The Run	141	1	1	Lenny Kravitz/Slash	232515	7593397	$b 99,00
1712	Heaven Help	141	1	1	Gerry DeVeaux/Terry Britten	190354	6222092	$b 99,00
1713	I Belong To You	141	1	1	Lenny Kravitz	257123	8477980	$b 99,00
1714	Believe	141	1	1	Henry Hirsch/Lenny Kravitz	295131	9661978	$b 99,00
1715	Let Love Rule	141	1	1	Lenny Kravitz	342648	11298085	$b 99,00
1716	Black Velveteen	141	1	1	Lenny Kravitz	290899	9531301	$b 99,00
1745	Pseudo Silk Kimono	144	1	1	Kelly, Mosley, Rothery, Trewaves	134739	4334038	$b 99,00
1746	Kayleigh	144	1	1	Kelly, Mosley, Rothery, Trewaves	234605	7716005	$b 99,00
1747	Lavender	144	1	1	Kelly, Mosley, Rothery, Trewaves	153417	4999814	$b 99,00
1748	Bitter Suite: Brief Encounter / Lost Weekend / Blue Angel	144	1	1	Kelly, Mosley, Rothery, Trewaves	356493	11791068	$b 99,00
1749	Heart Of Lothian: Wide Boy / Curtain Call	144	1	1	Kelly, Mosley, Rothery, Trewaves	366053	11893723	$b 99,00
1750	Waterhole (Expresso Bongo)	144	1	1	Kelly, Mosley, Rothery, Trewaves	133093	4378835	$b 99,00
1751	Lords Of The Backstage	144	1	1	Kelly, Mosley, Rothery, Trewaves	112875	3741319	$b 99,00
1752	Blind Curve: Vocal Under A Bloodlight / Passing Strangers / Mylo / Perimeter Walk / Threshold	144	1	1	Kelly, Mosley, Rothery, Trewaves	569704	18578995	$b 99,00
1753	Childhoods End?	144	1	1	Kelly, Mosley, Rothery, Trewaves	272796	9015366	$b 99,00
1754	White Feather	144	1	1	Kelly, Mosley, Rothery, Trewaves	143595	4711776	$b 99,00
1755	Arrepio	145	1	7	Carlinhos Brown	136254	4511390	$b 99,00
1756	Magamalabares	145	1	7	Carlinhos Brown	215875	7183757	$b 99,00
1757	Chuva No Brejo	145	1	7	Morais	145606	4857761	$b 99,00
1759	Tempos Modernos	145	1	7	Lulu Santos	183066	6066234	$b 99,00
1762	Panis Et Circenses	145	1	7	Caetano Veloso e Gilberto Gil	192339	6318373	$b 99,00
1763	De Noite Na Cama	145	1	7	Caetano Veloso e Gilberto Gil	209005	7012658	$b 99,00
1764	Beija Eu	145	1	7	Caetano Veloso e Gilberto Gil	197276	6512544	$b 99,00
1765	Give Me Love	145	1	7	Caetano Veloso e Gilberto Gil	249808	8196331	$b 99,00
1766	Ainda Lembro	145	1	7	Caetano Veloso e Gilberto Gil	218801	7211247	$b 99,00
1769	Ao Meu Redor	145	1	7	Caetano Veloso e Gilberto Gil	275591	9158834	$b 99,00
1770	Bem Leve	145	1	7	Caetano Veloso e Gilberto Gil	159190	5246835	$b 99,00
1771	Segue O Seco	145	1	7	Caetano Veloso e Gilberto Gil	178207	5922018	$b 99,00
1772	O Xote Das Meninas	145	1	7	Caetano Veloso e Gilberto Gil	291866	9553228	$b 99,00
1773	Wherever I Lay My Hat	146	1	14		136986	4477321	$b 99,00
1774	Get My Hands On Some Lovin'	146	1	14		149054	4860380	$b 99,00
1775	No Good Without You	146	1	14	William "Mickey" Stevenson	161410	5259218	$b 99,00
1776	You've Been A Long Time Coming	146	1	14	Brian Holland/Eddie Holland/Lamont Dozier	137221	4437949	$b 99,00
1777	When I Had Your Love	146	1	14	Robert Rogers/Warren "Pete" Moore/William "Mickey" Stevenson	152424	4972815	$b 99,00
1778	You're What's Happening (In The World Today)	146	1	14	Allen Story/George Gordy/Robert Gordy	142027	4631104	$b 99,00
1779	Loving You Is Sweeter Than Ever	146	1	14	Ivy Hunter/Stevie Wonder	166295	5377546	$b 99,00
1780	It's A Bitter Pill To Swallow	146	1	14	Smokey Robinson/Warren "Pete" Moore	194821	6477882	$b 99,00
1781	Seek And You Shall Find	146	1	14	Ivy Hunter/William "Mickey" Stevenson	223451	7306719	$b 99,00
1782	Gonna Keep On Tryin' Till I Win Your Love	146	1	14	Barrett Strong/Norman Whitfield	176404	5789945	$b 99,00
1783	Gonna Give Her All The Love I've Got	146	1	14	Barrett Strong/Norman Whitfield	210886	6893603	$b 99,00
1784	I Wish It Would Rain	146	1	14	Barrett Strong/Norman Whitfield/Roger Penzabene	172486	5647327	$b 99,00
1785	Abraham, Martin And John	146	1	14	Dick Holler	273057	8888206	$b 99,00
1786	Save The Children	146	1	14	Al Cleveland/Marvin Gaye/Renaldo Benson	194821	6342021	$b 99,00
1787	You Sure Love To Ball	146	1	14	Marvin Gaye	218540	7217872	$b 99,00
1788	Ego Tripping Out	146	1	14	Marvin Gaye	314514	10383887	$b 99,00
1790	Heavy Love Affair	146	1	14	Marvin Gaye	227892	7522232	$b 99,00
1791	Down Under	147	1	1		222171	7366142	$b 99,00
1792	Overkill	147	1	1		225410	7408652	$b 99,00
1793	Be Good Johnny	147	1	1		216320	7139814	$b 99,00
1794	Everything I Need	147	1	1		216476	7107625	$b 99,00
1795	Down by the Sea	147	1	1		408163	13314900	$b 99,00
1796	Who Can It Be Now?	147	1	1		202396	6682850	$b 99,00
1797	It's a Mistake	147	1	1		273371	8979965	$b 99,00
1798	Dr. Heckyll & Mr. Jive	147	1	1		278465	9110403	$b 99,00
1799	Shakes and Ladders	147	1	1		198008	6560753	$b 99,00
1800	No Sign of Yesterday	147	1	1		362004	11829011	$b 99,00
1801	Enter Sandman	148	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	332251	10852002	$b 99,00
1802	Sad But True	148	1	3	Ulrich	324754	10541258	$b 99,00
1803	Holier Than Thou	148	1	3	Ulrich	227892	7462011	$b 99,00
1804	The Unforgiven	148	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	387082	12646886	$b 99,00
1805	Wherever I May Roam	148	1	3	Ulrich	404323	13161169	$b 99,00
1806	Don't Tread On Me	148	1	3	Ulrich	240483	7827907	$b 99,00
1807	Through The Never	148	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	244375	8024047	$b 99,00
1808	Nothing Else Matters	148	1	3	Ulrich	388832	12606241	$b 99,00
1809	Of Wolf And Man	148	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	256835	8339785	$b 99,00
1810	The God That Failed	148	1	3	Ulrich	308610	10055959	$b 99,00
1811	My Friend Of Misery	148	1	3	James Hetfield, Lars Ulrich and Jason Newsted	409547	13293515	$b 99,00
1812	The Struggle Within	148	1	3	Ulrich	234240	7654052	$b 99,00
1813	Helpless	149	1	3	Harris/Tatler	398315	12977902	$b 99,00
1814	The Small Hours	149	1	3	Holocaust	403435	13215133	$b 99,00
1815	The Wait	149	1	3	Killing Joke	295418	9688418	$b 99,00
1816	Crash Course In Brain Surgery	149	1	3	Bourge/Phillips/Shelley	190406	6233729	$b 99,00
1817	Last Caress/Green Hell	149	1	3	Danzig	209972	6854313	$b 99,00
1818	Am I Evil?	149	1	3	Harris/Tatler	470256	15387219	$b 99,00
1819	Blitzkrieg	149	1	3	Jones/Sirotto/Smith	216685	7090018	$b 99,00
1820	Breadfan	149	1	3	Bourge/Phillips/Shelley	341551	11100130	$b 99,00
1821	The Prince	149	1	3	Harris/Tatler	265769	8624492	$b 99,00
1822	Stone Cold Crazy	149	1	3	Deacon/May/Mercury/Taylor	137717	4514830	$b 99,00
1823	So What	149	1	3	Culmer/Exalt	189152	6162894	$b 99,00
1824	Killing Time	149	1	3	Sweet Savage	183693	6021197	$b 99,00
1825	Overkill	149	1	3	Clarke/Kilmister/Tayler	245133	7971330	$b 99,00
1826	Damage Case	149	1	3	Clarke/Farren/Kilmister/Tayler	220212	7212997	$b 99,00
1827	Stone Dead Forever	149	1	3	Clarke/Kilmister/Tayler	292127	9556060	$b 99,00
1828	Too Late Too Late	149	1	3	Clarke/Kilmister/Tayler	192052	6276291	$b 99,00
1829	Hit The Lights	150	1	3	James Hetfield, Lars Ulrich	257541	8357088	$b 99,00
1830	The Four Horsemen	150	1	3	James Hetfield, Lars Ulrich, Dave Mustaine	433188	14178138	$b 99,00
1831	Motorbreath	150	1	3	James Hetfield	188395	6153933	$b 99,00
1832	Jump In The Fire	150	1	3	James Hetfield, Lars Ulrich, Dave Mustaine	281573	9135755	$b 99,00
1833	(Anesthesia) Pulling Teeth	150	1	3	Cliff Burton	254955	8234710	$b 99,00
1834	Whiplash	150	1	3	James Hetfield, Lars Ulrich	249208	8102839	$b 99,00
1835	Phantom Lord	150	1	3	James Hetfield, Lars Ulrich, Dave Mustaine	302053	9817143	$b 99,00
1836	No Remorse	150	1	3	James Hetfield, Lars Ulrich	386795	12672166	$b 99,00
1837	Seek & Destroy	150	1	3	James Hetfield, Lars Ulrich	415817	13452301	$b 99,00
1838	Metal Militia	150	1	3	James Hetfield, Lars Ulrich, Dave Mustaine	311327	10141785	$b 99,00
1839	Ain't My Bitch	151	1	3	James Hetfield, Lars Ulrich	304457	9931015	$b 99,00
1840	2 X 4	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	328254	10732251	$b 99,00
1841	The House Jack Built	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	398942	13005152	$b 99,00
1842	Until It Sleeps	151	1	3	James Hetfield, Lars Ulrich	269740	8837394	$b 99,00
1843	King Nothing	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	328097	10681477	$b 99,00
1844	Hero Of The Day	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	261982	8540298	$b 99,00
1845	Bleeding Me	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	497998	16249420	$b 99,00
1846	Cure	151	1	3	James Hetfield, Lars Ulrich	294347	9648615	$b 99,00
1847	Poor Twisted Me	151	1	3	James Hetfield, Lars Ulrich	240065	7854349	$b 99,00
1848	Wasted My Hate	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	237296	7762300	$b 99,00
1849	Mama Said	151	1	3	James Hetfield, Lars Ulrich	319764	10508310	$b 99,00
1850	Thorn Within	151	1	3	James Hetfield, Lars Ulrich, Kirk Hammett	351738	11486686	$b 99,00
1851	Ronnie	151	1	3	James Hetfield, Lars Ulrich	317204	10390947	$b 99,00
1852	The Outlaw Torn	151	1	3	James Hetfield, Lars Ulrich	588721	19286261	$b 99,00
1853	Battery	152	1	3	J.Hetfield/L.Ulrich	312424	10229577	$b 99,00
1854	Master Of Puppets	152	1	3	K.Hammett	515239	16893720	$b 99,00
1855	The Thing That Should Not Be	152	1	3	K.Hammett	396199	12952368	$b 99,00
1856	Welcome Home (Sanitarium)	152	1	3	K.Hammett	387186	12679965	$b 99,00
1857	Disposable Heroes	152	1	3	J.Hetfield/L.Ulrich	496718	16135560	$b 99,00
1858	Leper Messiah	152	1	3	C.Burton	347428	11310434	$b 99,00
1859	Orion	152	1	3	K.Hammett	500062	16378477	$b 99,00
1860	Damage Inc.	152	1	3	K.Hammett	330919	10725029	$b 99,00
1861	Fuel	153	1	3	Hetfield, Ulrich, Hammett	269557	8876811	$b 99,00
1862	The Memory Remains	153	1	3	Hetfield, Ulrich	279353	9110730	$b 99,00
1863	Devil's Dance	153	1	3	Hetfield, Ulrich	318955	10414832	$b 99,00
1864	The Unforgiven II	153	1	3	Hetfield, Ulrich, Hammett	395520	12886474	$b 99,00
1865	Better Than You	153	1	3	Hetfield, Ulrich	322899	10549070	$b 99,00
1866	Slither	153	1	3	Hetfield, Ulrich, Hammett	313103	10199789	$b 99,00
1867	Carpe Diem Baby	153	1	3	Hetfield, Ulrich, Hammett	372480	12170693	$b 99,00
1868	Bad Seed	153	1	3	Hetfield, Ulrich, Hammett	245394	8019586	$b 99,00
1869	Where The Wild Things Are	153	1	3	Hetfield, Ulrich, Newsted	414380	13571280	$b 99,00
1870	Prince Charming	153	1	3	Hetfield, Ulrich	365061	12009412	$b 99,00
1871	Low Man's Lyric	153	1	3	Hetfield, Ulrich	457639	14855583	$b 99,00
1872	Attitude	153	1	3	Hetfield, Ulrich	315898	10335734	$b 99,00
1873	Fixxxer	153	1	3	Hetfield, Ulrich, Hammett	496065	16190041	$b 99,00
1874	Fight Fire With Fire	154	1	3	Metallica	285753	9420856	$b 99,00
1875	Ride The Lightning	154	1	3	Metallica	397740	13055884	$b 99,00
1876	For Whom The Bell Tolls	154	1	3	Metallica	311719	10159725	$b 99,00
1877	Fade To Black	154	1	3	Metallica	414824	13531954	$b 99,00
1878	Trapped Under Ice	154	1	3	Metallica	244532	7975942	$b 99,00
1879	Escape	154	1	3	Metallica	264359	8652332	$b 99,00
1880	Creeping Death	154	1	3	Metallica	396878	12955593	$b 99,00
1881	The Call Of Ktulu	154	1	3	Metallica	534883	17486240	$b 99,00
1882	Frantic	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	350458	11510849	$b 99,00
1883	St. Anger	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	441234	14363779	$b 99,00
1884	Some Kind Of Monster	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	505626	16557497	$b 99,00
1885	Dirty Window	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	324989	10670604	$b 99,00
1886	Invisible Kid	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	510197	16591800	$b 99,00
1887	My World	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	345626	11253756	$b 99,00
1888	Shoot Me Again	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	430210	14093551	$b 99,00
1889	Sweet Amber	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	327235	10616595	$b 99,00
1890	The Unnamed Feeling	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	429479	14014582	$b 99,00
1891	Purify	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	314017	10232537	$b 99,00
1892	All Within My Hands	155	1	3	Bob Rock/James Hetfield/Kirk Hammett/Lars Ulrich	527986	17162741	$b 99,00
1893	Blackened	156	1	3	James Hetfield, Lars Ulrich & Jason Newsted	403382	13254874	$b 99,00
1894	...And Justice For All	156	1	3	James Hetfield, Lars Ulrich & Kirk Hammett	585769	19262088	$b 99,00
1895	Eye Of The Beholder	156	1	3	James Hetfield, Lars Ulrich & Kirk Hammett	385828	12747894	$b 99,00
1896	One	156	1	3	James Hetfield & Lars Ulrich	446484	14695721	$b 99,00
1897	The Shortest Straw	156	1	3	James Hetfield and Lars Ulrich	395389	13013990	$b 99,00
1898	Harvester Of Sorrow	156	1	3	James Hetfield and Lars Ulrich	345547	11377339	$b 99,00
1899	The Frayed Ends Of Sanity	156	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	464039	15198986	$b 99,00
1900	To Live Is To Die	156	1	3	James Hetfield, Lars Ulrich and Cliff Burton	588564	19243795	$b 99,00
1901	Dyers Eve	156	1	3	James Hetfield, Lars Ulrich and Kirk Hammett	313991	10302828	$b 99,00
1902	Springsville	157	1	2	J. Carisi	207725	6776219	$b 99,00
1903	The Maids Of Cadiz	157	1	2	L. Delibes	233534	7505275	$b 99,00
1904	The Duke	157	1	2	Dave Brubeck	214961	6977626	$b 99,00
1905	My Ship	157	1	2	Ira Gershwin, Kurt Weill	268016	8581144	$b 99,00
1906	Miles Ahead	157	1	2	Miles Davis, Gil Evans	209893	6807707	$b 99,00
1907	Blues For Pablo	157	1	2	Gil Evans	318328	10218398	$b 99,00
1908	New Rhumba	157	1	2	A. Jamal	276871	8980400	$b 99,00
1909	The Meaning Of The Blues	157	1	2	R. Troup, L. Worth	168594	5395412	$b 99,00
1910	Lament	157	1	2	J.J. Johnson	134191	4293394	$b 99,00
1911	I Don't Wanna Be Kissed (By Anyone But You)	157	1	2	H. Spina, J. Elliott	191320	6219487	$b 99,00
1912	Springsville (Alternate Take)	157	1	2	J. Carisi	196388	6382079	$b 99,00
1913	Blues For Pablo (Alternate Take)	157	1	2	Gil Evans	212558	6900619	$b 99,00
1914	The Meaning Of The Blues/Lament (Alternate Take)	157	1	2	J.J. Johnson/R. Troup, L. Worth	309786	9912387	$b 99,00
1915	I Don't Wanna Be Kissed (By Anyone But You) (Alternate Take)	157	1	2	H. Spina, J. Elliott	192078	6254796	$b 99,00
1917	A Noite Do Meu Bem	158	1	7	Dolores Duran	220081	7125225	$b 99,00
1919	Cuitelinho	158	1	7	Folclore	209397	6803970	$b 99,00
1921	Nos Bailes Da Vida	158	1	7	Milton Nascimento, Fernando Brant	275748	9126170	$b 99,00
1922	Menestrel Das Alagoas	158	1	7	Milton Nascimento, Fernando Brant	199758	6542289	$b 99,00
1923	Brasil	158	1	7	Milton Nascimento, Fernando Brant	155428	5252560	$b 99,00
1925	Um Gosto De Sol	158	1	7	Milton Nascimento, Ronaldo Bastos	307200	9893875	$b 99,00
1926	Solar	158	1	7	Milton Nascimento, Fernando Brant	156212	5098288	$b 99,00
1928	Maria, Maria	158	1	7	Milton Nascimento, Fernando Brant	72463	2371543	$b 99,00
1929	Minas	159	1	7	Milton Nascimento, Caetano Veloso	152293	4921056	$b 99,00
1931	Beijo Partido	159	1	7	Toninho Horta	229564	7506969	$b 99,00
1934	Ponta de Areia	159	1	7	Milton Nascimento, Fernando Brant	272796	8874285	$b 99,00
1935	Trastevere	159	1	7	Milton Nascimento, Ronaldo Bastos	265665	8708399	$b 99,00
1936	Idolatrada	159	1	7	Milton Nascimento, Fernando Brant	286249	9426153	$b 99,00
1937	Leila (Venha Ser Feliz)	159	1	7	Milton Nascimento	209737	6898507	$b 99,00
1938	Paula E Bebeto	159	1	7	Milton Nascimento, Caetano Veloso	135732	4583956	$b 99,00
1939	Simples	159	1	7	Nelson Angelo	133093	4326333	$b 99,00
1940	Norwegian Wood	159	1	7	John Lennon, Paul McCartney	413910	13520382	$b 99,00
1986	Intro	163	1	1	Kurt Cobain	52218	1688527	$b 99,00
1987	School	163	1	1	Kurt Cobain	160235	5234885	$b 99,00
1988	Drain You	163	1	1	Kurt Cobain	215196	7013175	$b 99,00
1989	Aneurysm	163	1	1	Nirvana	271516	8862545	$b 99,00
1990	Smells Like Teen Spirit	163	1	1	Nirvana	287190	9425215	$b 99,00
1991	Been A Son	163	1	1	Kurt Cobain	127555	4170369	$b 99,00
1992	Lithium	163	1	1	Kurt Cobain	250017	8148800	$b 99,00
1993	Sliver	163	1	1	Kurt Cobain	116218	3784567	$b 99,00
1994	Spank Thru	163	1	1	Kurt Cobain	190354	6186487	$b 99,00
1995	Scentless Apprentice	163	1	1	Nirvana	211200	6898177	$b 99,00
1996	Heart-Shaped Box	163	1	1	Kurt Cobain	281887	9210982	$b 99,00
1997	Milk It	163	1	1	Kurt Cobain	225724	7406945	$b 99,00
1998	Negative Creep	163	1	1	Kurt Cobain	163761	5354854	$b 99,00
1999	Polly	163	1	1	Kurt Cobain	149995	4885331	$b 99,00
2000	Breed	163	1	1	Kurt Cobain	208378	6759080	$b 99,00
2001	Tourette's	163	1	1	Kurt Cobain	115591	3753246	$b 99,00
2002	Blew	163	1	1	Kurt Cobain	216346	7096936	$b 99,00
2003	Smells Like Teen Spirit	164	1	1	Kurt Cobain	301296	9823847	$b 99,00
2004	In Bloom	164	1	1	Kurt Cobain	254928	8327077	$b 99,00
2005	Come As You Are	164	1	1	Kurt Cobain	219219	7123357	$b 99,00
2006	Breed	164	1	1	Kurt Cobain	183928	5984812	$b 99,00
2007	Lithium	164	1	1	Kurt Cobain	256992	8404745	$b 99,00
2008	Polly	164	1	1	Kurt Cobain	177031	5788407	$b 99,00
2009	Territorial Pissings	164	1	1	Kurt Cobain	143281	4613880	$b 99,00
2010	Drain You	164	1	1	Kurt Cobain	223973	7273440	$b 99,00
2011	Lounge Act	164	1	1	Kurt Cobain	156786	5093635	$b 99,00
2012	Stay Away	164	1	1	Kurt Cobain	212636	6956404	$b 99,00
2013	On A Plain	164	1	1	Kurt Cobain	196440	6390635	$b 99,00
2014	Something In The Way	164	1	1	Kurt Cobain	230556	7472168	$b 99,00
2030	Requebra	166	1	7		240744	8010811	$b 99,00
2032	Olodum - Alegria Geral	166	1	7		233404	7754245	$b 99,00
2035	Todo Amor (Asas Da Liberdade)	166	1	7		245133	8121434	$b 99,00
2038	Cartao Postal	166	1	7		211565	7082301	$b 99,00
2039	Jeito Faceiro	166	1	7		217286	7233608	$b 99,00
2040	Revolta Olodum	166	1	7		230191	7557065	$b 99,00
2042	Protesto Do Olodum (Ao Vivo)	166	1	7		206001	6766104	$b 99,00
2043	Olodum - Smile (Instrumental)	166	1	7		235833	7871409	$b 99,00
2065	Trac Trac	168	1	7	Fito Paez/Herbert Vianna	231653	7638256	$b 99,00
2067	Mensagen De Amor (2000)	168	1	7	Herbert Vianna	183588	6061324	$b 99,00
2068	Lourinha Bombril	168	1	7	Bahiano/Diego Blanco/Herbert Vianna	159895	5301882	$b 99,00
2069	La Bella Luna	168	1	7	Herbert Vianna	192653	6428598	$b 99,00
2070	Busca Vida	168	1	7	Herbert Vianna	176431	5798663	$b 99,00
2071	Uma Brasileira	168	1	7	Carlinhos Brown/Herbert Vianna	217573	7280574	$b 99,00
2072	Luis Inacio (300 Picaretas)	168	1	7	Herbert Vianna	198191	6576790	$b 99,00
2073	Saber Amar	168	1	7	Herbert Vianna	202788	6723733	$b 99,00
2074	Ela Disse Adeus	168	1	7	Herbert Vianna	226298	7608999	$b 99,00
2075	O Amor Nao Sabe Esperar	168	1	7	Herbert Vianna	241084	8042534	$b 99,00
2079	Cinema Mudo	169	1	7		227918	7612168	$b 99,00
2080	Alagados	169	1	7		302393	10255463	$b 99,00
2081	Lanterna Dos Afogados	169	1	7		190197	6264318	$b 99,00
2083	Vital E Sua Moto	169	1	7		210207	6902878	$b 99,00
2084	O Beco	169	1	7		189178	6293184	$b 99,00
2085	Meu Erro	169	1	7		208431	6893533	$b 99,00
2086	Perplexo	169	1	7		161175	5355013	$b 99,00
2087	Me Liga	169	1	7		229590	7565912	$b 99,00
2088	Quase Um Segundo	169	1	7		275644	8971355	$b 99,00
2089	Selvagem	169	1	7		245890	8141084	$b 99,00
2090	Romance Ideal	169	1	7		250070	8260477	$b 99,00
2092	SKA	169	1	7		148871	4943540	$b 99,00
2093	Bark at the Moon	170	2	1	O. Osbourne	257252	4601224	$b 99,00
2094	I Don't Know	171	2	1	B. Daisley, O. Osbourne & R. Rhoads	312980	5525339	$b 99,00
2095	Crazy Train	171	2	1	B. Daisley, O. Osbourne & R. Rhoads	295960	5255083	$b 99,00
2096	Flying High Again	172	2	1	L. Kerslake, O. Osbourne, R. Daisley & R. Rhoads	290851	5179599	$b 99,00
2097	Mama, I'm Coming Home	173	2	1	L. Kilmister, O. Osbourne & Z. Wylde	251586	4302390	$b 99,00
2098	No More Tears	173	2	1	J. Purdell, M. Inez, O. Osbourne, R. Castillo & Z. Wylde	444358	7362964	$b 99,00
2099	I Don't Know	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	283088	9207869	$b 99,00
2100	Crazy Train	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	322716	10517408	$b 99,00
2101	Believer	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	308897	10003794	$b 99,00
2102	Mr. Crowley	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	344241	11184130	$b 99,00
2103	Flying High Again	174	1	3	O. Osbourne, R. Daisley, R. Rhoads, L. Kerslake	261224	8481822	$b 99,00
2104	Relvelation (Mother Earth)	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	349440	11367866	$b 99,00
2105	Steal Away (The Night)	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	485720	15945806	$b 99,00
2106	Suicide Solution (With Guitar Solo)	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	467069	15119938	$b 99,00
2107	Iron Man	174	1	3	A. F. Iommi, W. Ward, T. Butler, J. Osbourne	172120	5609799	$b 99,00
2108	Children Of The Grave	174	1	3	A. F. Iommi, W. Ward, T. Butler, J. Osbourne	357067	11626740	$b 99,00
2109	Paranoid	174	1	3	A. F. Iommi, W. Ward, T. Butler, J. Osbourne	176352	5729813	$b 99,00
2110	Goodbye To Romance	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	334393	10841337	$b 99,00
2111	No Bone Movies	174	1	3	O. Osbourne, R. Daisley, R. Rhoads	249208	8095199	$b 99,00
2112	Dee	174	1	3	R. Rhoads	261302	8555963	$b 99,00
2113	Shining In The Light	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	240796	7951688	$b 99,00
2114	When The World Was Young	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	373394	12198930	$b 99,00
2115	Upon A Golden Horse	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	232359	7594829	$b 99,00
2116	Blue Train	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	405028	13170391	$b 99,00
2117	Please Read The Letter	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	262112	8603372	$b 99,00
2118	Most High	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	336535	10999203	$b 99,00
2119	Heart In Your Hand	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	230896	7598019	$b 99,00
2120	Walking Into Clarksdale	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	318511	10396315	$b 99,00
2121	Burning Up	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	321619	10525136	$b 99,00
2122	When I Was A Child	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	345626	11249456	$b 99,00
2123	House Of Love	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	335699	10990880	$b 99,00
2124	Sons Of Freedom	175	1	1	Jimmy Page, Robert Plant, Charlie Jones, Michael Lee	246465	8087944	$b 99,00
2125	United Colours	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	330266	10939131	$b 99,00
2126	Slug	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	281469	9295950	$b 99,00
2127	Your Blue Room	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	328228	10867860	$b 99,00
2128	Always Forever Now	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	383764	12727928	$b 99,00
2129	A Different Kind Of Blue	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	120816	3884133	$b 99,00
2130	Beach Sequence	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	212297	6928259	$b 99,00
2131	Miss Sarajevo	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	340767	11064884	$b 99,00
2132	Ito Okashi	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	205087	6572813	$b 99,00
2133	One Minute Warning	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	279693	9335453	$b 99,00
2134	Corpse (These Chains Are Way Too Long)	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	214909	6920451	$b 99,00
2135	Elvis Ate America	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	180166	5851053	$b 99,00
2136	Plot 180	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	221596	7253729	$b 99,00
2137	Theme From The Swan	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	203911	6638076	$b 99,00
2138	Theme From Let's Go Native	176	1	10	Brian Eno, Bono, Adam Clayton, The Edge & Larry Mullen Jnr.	186723	6179777	$b 99,00
2139	Wrathchild	177	1	1	Steve Harris	170396	5499390	$b 99,00
2140	Killers	177	1	1	Paul Di'Anno/Steve Harris	309995	10009697	$b 99,00
2141	Prowler	177	1	1	Steve Harris	240274	7782963	$b 99,00
2142	Murders In The Rue Morgue	177	1	1	Steve Harris	258638	8360999	$b 99,00
2143	Women In Uniform	177	1	1	Greg Macainsh	189936	6139651	$b 99,00
2144	Remember Tomorrow	177	1	1	Paul Di'Anno/Steve Harris	326426	10577976	$b 99,00
2145	Sanctuary	177	1	1	David Murray/Paul Di'Anno/Steve Harris	198844	6423543	$b 99,00
2146	Running Free	177	1	1	Paul Di'Anno/Steve Harris	199706	6483496	$b 99,00
2147	Phantom Of The Opera	177	1	1	Steve Harris	418168	13585530	$b 99,00
2148	Iron Maiden	177	1	1	Steve Harris	235232	7600077	$b 99,00
2149	Corduroy	178	1	1	Pearl Jam & Eddie Vedder	305293	9991106	$b 99,00
2150	Given To Fly	178	1	1	Eddie Vedder & Mike McCready	233613	7678347	$b 99,00
2151	Hail, Hail	178	1	1	Stone Gossard & Eddie Vedder & Jeff Ament & Mike McCready	223764	7364206	$b 99,00
2152	Daughter	178	1	1	Dave Abbruzzese & Jeff Ament & Stone Gossard & Mike McCready & Eddie Vedder	407484	13420697	$b 99,00
2153	Elderly Woman Behind The Counter In A Small Town	178	1	1	Dave Abbruzzese & Jeff Ament & Stone Gossard & Mike McCready & Eddie Vedder	229328	7509304	$b 99,00
2154	Untitled	178	1	1	Pearl Jam	122801	3957141	$b 99,00
2155	MFC	178	1	1	Eddie Vedder	148192	4817665	$b 99,00
2156	Go	178	1	1	Dave Abbruzzese & Jeff Ament & Stone Gossard & Mike McCready & Eddie Vedder	161541	5290810	$b 99,00
2157	Red Mosquito	178	1	1	Jeff Ament & Stone Gossard & Jack Irons & Mike McCready & Eddie Vedder	242991	7944923	$b 99,00
2158	Even Flow	178	1	1	Stone Gossard & Eddie Vedder	317100	10394239	$b 99,00
2159	Off He Goes	178	1	1	Eddie Vedder	343222	11245109	$b 99,00
2160	Nothingman	178	1	1	Jeff Ament & Eddie Vedder	278595	9107017	$b 99,00
2161	Do The Evolution	178	1	1	Eddie Vedder & Stone Gossard	225462	7377286	$b 99,00
2162	Better Man	178	1	1	Eddie Vedder	246204	8019563	$b 99,00
2163	Black	178	1	1	Stone Gossard & Eddie Vedder	415712	13580009	$b 99,00
2164	F*Ckin' Up	178	1	1	Neil Young	377652	12360893	$b 99,00
2165	Life Wasted	179	1	4	Stone Gossard	234344	7610169	$b 99,00
2166	World Wide Suicide	179	1	4	Eddie Vedder	209188	6885908	$b 99,00
2167	Comatose	179	1	4	Mike McCready & Stone Gossard	139990	4574516	$b 99,00
2168	Severed Hand	179	1	4	Eddie Vedder	270341	8817438	$b 99,00
2169	Marker In The Sand	179	1	4	Mike McCready	263235	8656578	$b 99,00
2170	Parachutes	179	1	4	Stone Gossard	216555	7074973	$b 99,00
2171	Unemployable	179	1	4	Matt Cameron & Mike McCready	184398	6066542	$b 99,00
2172	Big Wave	179	1	4	Jeff Ament	178573	5858788	$b 99,00
2173	Gone	179	1	4	Eddie Vedder	249547	8158204	$b 99,00
2174	Wasted Reprise	179	1	4	Stone Gossard	53733	1731020	$b 99,00
2175	Army Reserve	179	1	4	Jeff Ament	225567	7393771	$b 99,00
2176	Come Back	179	1	4	Eddie Vedder & Mike McCready	329743	10768701	$b 99,00
2177	Inside Job	179	1	4	Eddie Vedder & Mike McCready	428643	14006924	$b 99,00
2178	Can't Keep	180	1	1	Eddie Vedder	219428	7215713	$b 99,00
2179	Save You	180	1	1	Eddie Vedder/Jeff Ament/Matt Cameron/Mike McCready/Stone Gossard	230112	7609110	$b 99,00
2180	Love Boat Captain	180	1	1	Eddie Vedder	276453	9016789	$b 99,00
2181	Cropduster	180	1	1	Matt Cameron	231888	7588928	$b 99,00
2182	Ghost	180	1	1	Jeff Ament	195108	6383772	$b 99,00
2183	I Am Mine	180	1	1	Eddie Vedder	215719	7086901	$b 99,00
2184	Thumbing My Way	180	1	1	Eddie Vedder	250226	8201437	$b 99,00
2185	You Are	180	1	1	Matt Cameron	270863	8938409	$b 99,00
2186	Get Right	180	1	1	Matt Cameron	158589	5223345	$b 99,00
2187	Green Disease	180	1	1	Eddie Vedder	161253	5375818	$b 99,00
2188	Help Help	180	1	1	Jeff Ament	215092	7033002	$b 99,00
2189	Bushleager	180	1	1	Stone Gossard	237479	7849757	$b 99,00
2190	1/2 Full	180	1	1	Jeff Ament	251010	8197219	$b 99,00
2191	Arc	180	1	1	Pearl Jam	65593	2099421	$b 99,00
2192	All or None	180	1	1	Stone Gossard	277655	9104728	$b 99,00
2193	Once	181	1	1	Stone Gossard	231758	7561555	$b 99,00
2194	Evenflow	181	1	1	Stone Gossard	293720	9622017	$b 99,00
2195	Alive	181	1	1	Stone Gossard	341080	11176623	$b 99,00
2196	Why Go	181	1	1	Jeff Ament	200254	6539287	$b 99,00
2197	Black	181	1	1	Dave Krusen/Stone Gossard	343823	11213314	$b 99,00
2198	Jeremy	181	1	1	Jeff Ament	318981	10447222	$b 99,00
2199	Oceans	181	1	1	Jeff Ament/Stone Gossard	162194	5282368	$b 99,00
2200	Porch	181	1	1	Eddie Vedder	210520	6877475	$b 99,00
2201	Garden	181	1	1	Jeff Ament/Stone Gossard	299154	9740738	$b 99,00
2202	Deep	181	1	1	Jeff Ament/Stone Gossard	258324	8432497	$b 99,00
2203	Release	181	1	1	Jeff Ament/Mike McCready/Stone Gossard	546063	17802673	$b 99,00
2204	Go	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	193123	6351920	$b 99,00
2205	Animal	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	169325	5503459	$b 99,00
2206	Daughter	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	235598	7824586	$b 99,00
2207	Glorified G	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	206968	6772116	$b 99,00
2208	Dissident	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	215510	7034500	$b 99,00
2209	W.M.A.	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	359262	12037261	$b 99,00
2210	Blood	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	170631	5551478	$b 99,00
2211	Rearviewmirror	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	284186	9321053	$b 99,00
2212	Rats	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	255425	8341934	$b 99,00
2213	Elderly Woman Behind The Counter In A Small Town	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	196336	6499398	$b 99,00
2214	Leash	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	189257	6191560	$b 99,00
2215	Indifference	182	1	1	Dave Abbruzzese/Eddie Vedder/Jeff Ament/Mike McCready/Stone Gossard	302053	9756133	$b 99,00
2216	Johnny B. Goode	141	1	8		243200	8092024	$b 99,00
2217	Don't Look Back	141	1	8		221100	7344023	$b 99,00
2218	Jah Seh No	141	1	8		276871	9134476	$b 99,00
2219	I'm The Toughest	141	1	8		230191	7657594	$b 99,00
2220	Nothing But Love	141	1	8		221570	7335228	$b 99,00
2221	Buk-In-Hamm Palace	141	1	8		265665	8964369	$b 99,00
2222	Bush Doctor	141	1	8		239751	7942299	$b 99,00
2223	Wanted Dread And Alive	141	1	8		260310	8670933	$b 99,00
2224	Mystic Man	141	1	8		353671	11812170	$b 99,00
2225	Coming In Hot	141	1	8		213054	7109414	$b 99,00
2226	Pick Myself Up	141	1	8		234684	7788255	$b 99,00
2227	Crystal Ball	141	1	8		309733	10319296	$b 99,00
2228	Equal Rights Downpresser Man	141	1	8		366733	12086524	$b 99,00
2229	Speak To Me/Breathe	183	1	1	Mason/Waters, Gilmour, Wright	234213	7631305	$b 99,00
2230	On The Run	183	1	1	Gilmour, Waters	214595	7206300	$b 99,00
2231	Time	183	1	1	Mason, Waters, Wright, Gilmour	425195	13955426	$b 99,00
2232	The Great Gig In The Sky	183	1	1	Wright, Waters	284055	9147563	$b 99,00
2233	Money	183	1	1	Waters	391888	12930070	$b 99,00
2234	Us And Them	183	1	1	Waters, Wright	461035	15000299	$b 99,00
2235	Any Colour You Like	183	1	1	Gilmour, Mason, Wright, Waters	205740	6707989	$b 99,00
2236	Brain Damage	183	1	1	Waters	230556	7497655	$b 99,00
2237	Eclipse	183	1	1	Waters	125361	4065299	$b 99,00
2254	Bohemian Rhapsody	185	1	1	Mercury, Freddie	358948	11619868	$b 99,00
2255	Another One Bites The Dust	185	1	1	Deacon, John	216946	7172355	$b 99,00
2256	Killer Queen	185	1	1	Mercury, Freddie	182099	5967749	$b 99,00
2257	Fat Bottomed Girls	185	1	1	May, Brian	204695	6630041	$b 99,00
2258	Bicycle Race	185	1	1	Mercury, Freddie	183823	6012409	$b 99,00
2259	You're My Best Friend	185	1	1	Deacon, John	172225	5602173	$b 99,00
2260	Don't Stop Me Now	185	1	1	Mercury, Freddie	211826	6896666	$b 99,00
2261	Save Me	185	1	1	May, Brian	228832	7444624	$b 99,00
2262	Crazy Little Thing Called Love	185	1	1	Mercury, Freddie	164231	5435501	$b 99,00
2263	Somebody To Love	185	1	1	Mercury, Freddie	297351	9650520	$b 99,00
2264	Now I'm Here	185	1	1	May, Brian	255346	8328312	$b 99,00
2265	Good Old-Fashioned Lover Boy	185	1	1	Mercury, Freddie	175960	5747506	$b 99,00
2266	Play The Game	185	1	1	Mercury, Freddie	213368	6915832	$b 99,00
2267	Flash	185	1	1	May, Brian	168489	5464986	$b 99,00
2268	Seven Seas Of Rhye	185	1	1	Mercury, Freddie	170553	5539957	$b 99,00
2269	We Will Rock You	185	1	1	Deacon, John/May, Brian	122880	4026955	$b 99,00
2270	We Are The Champions	185	1	1	Mercury, Freddie	180950	5880231	$b 99,00
2271	We Will Rock You	186	1	1	May	122671	4026815	$b 99,00
2272	We Are The Champions	186	1	1	Mercury	182883	5939794	$b 99,00
2273	Sheer Heart Attack	186	1	1	Taylor	207386	6642685	$b 99,00
2274	All Dead, All Dead	186	1	1	May	190119	6144878	$b 99,00
2275	Spread Your Wings	186	1	1	Deacon	275356	8936992	$b 99,00
2276	Fight From The Inside	186	1	1	Taylor	184737	6078001	$b 99,00
2277	Get Down, Make Love	186	1	1	Mercury	231235	7509333	$b 99,00
2278	Sleep On The Sidewalk	186	1	1	May	187428	6099840	$b 99,00
2279	Who Needs You	186	1	1	Deacon	186958	6292969	$b 99,00
2280	It's Late	186	1	1	May	386194	12519388	$b 99,00
2281	My Melancholy Blues	186	1	1	Mercury	206471	6691838	$b 99,00
2282	Shiny Happy People	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	226298	7475323	$b 99,00
2283	Me In Honey	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	246674	8194751	$b 99,00
2284	Radio Song	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	255477	8421172	$b 99,00
2285	Pop Song 89	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	185730	6132218	$b 99,00
2286	Get Up	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	160235	5264376	$b 99,00
2287	You Are The Everything	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	226298	7373181	$b 99,00
2288	Stand	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	192862	6349090	$b 99,00
2289	World Leader Pretend	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	259761	8537282	$b 99,00
2290	The Wrong Child	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	216633	7065060	$b 99,00
2291	Orange Crush	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	231706	7742894	$b 99,00
2292	Turn You Inside-Out	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	257358	8395671	$b 99,00
2293	Hairshirt	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	235911	7753807	$b 99,00
2294	I Remember California	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	304013	9950311	$b 99,00
2295	Untitled	188	1	4	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	191503	6332426	$b 99,00
2296	How The West Was Won And Where It Got Us	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	271151	8994291	$b 99,00
2297	The Wake-Up Bomb	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	308532	10077337	$b 99,00
2298	New Test Leper	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	326791	10866447	$b 99,00
2299	Undertow	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	309498	10131005	$b 99,00
2300	E-Bow The Letter	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	324963	10714576	$b 99,00
2301	Leave	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	437968	14433365	$b 99,00
2302	Departure	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	209423	6818425	$b 99,00
2303	Bittersweet Me	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	245812	8114718	$b 99,00
2304	Be Mine	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	333087	10790541	$b 99,00
2305	Binky The Doormat	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	301688	9950320	$b 99,00
2306	Zither	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	154148	5032962	$b 99,00
2307	So Fast, So Numb	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	252682	8341223	$b 99,00
2308	Low Desert	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	212062	6989288	$b 99,00
2309	Electrolite	189	1	1	Bill Berry-Peter Buck-Mike Mills-Michael Stipe	245315	8051199	$b 99,00
2310	Losing My Religion	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	269035	8885672	$b 99,00
2311	Low	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	296777	9633860	$b 99,00
2312	Near Wild Heaven	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	199862	6610009	$b 99,00
2313	Endgame	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	230687	7664479	$b 99,00
2314	Belong	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	247013	8219375	$b 99,00
2315	Half A World Away	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	208431	6837283	$b 99,00
2316	Texarkana	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	220081	7260681	$b 99,00
2317	Country Feedback	187	1	4	Bill Berry/Michael Stipe/Mike Mills/Peter Buck	249782	8178943	$b 99,00
2318	Carnival Of Sorts	190	1	4	R.E.M.	233482	7669658	$b 99,00
2319	Radio Free Aurope	190	1	4	R.E.M.	245315	8163490	$b 99,00
2320	Perfect Circle	190	1	4	R.E.M.	208509	6898067	$b 99,00
2321	Talk About The Passion	190	1	4	R.E.M.	203206	6725435	$b 99,00
2322	So Central Rain	190	1	4	R.E.M.	194768	6414550	$b 99,00
2323	Don't Go Back To Rockville	190	1	4	R.E.M.	272352	9010715	$b 99,00
2324	Pretty Persuasion	190	1	4	R.E.M.	229929	7577754	$b 99,00
2325	Green Grow The Rushes	190	1	4	R.E.M.	225671	7422425	$b 99,00
2326	Can't Get There From Here	190	1	4	R.E.M.	220630	7285936	$b 99,00
2327	Driver 8	190	1	4	R.E.M.	204747	6779076	$b 99,00
2328	Fall On Me	190	1	4	R.E.M.	172016	5676811	$b 99,00
2329	I Believe	190	1	4	R.E.M.	227709	7542929	$b 99,00
2330	Cuyahoga	190	1	4	R.E.M.	260623	8591057	$b 99,00
2331	The One I Love	190	1	4	R.E.M.	197355	6495125	$b 99,00
2332	The Finest Worksong	190	1	4	R.E.M.	229276	7574856	$b 99,00
2333	It's The End Of The World As We Know It (And I Feel Fine)	190	1	4	R.E.M.	244819	7998987	$b 99,00
2344	Maluco Beleza	192	1	1		203206	6628067	$b 99,00
2345	O Dia Em Que A Terra Parou	192	1	1		261720	8586678	$b 99,00
2346	No Fundo Do Quintal Da Escola	192	1	1		177606	5836953	$b 99,00
2347	O Segredo Do Universo	192	1	1		192679	6315187	$b 99,00
2348	As Profecias	192	1	1		232515	7657732	$b 99,00
2349	Mata Virgem	192	1	1		142602	4690029	$b 99,00
2350	Sapato 36	192	1	1		196702	6507301	$b 99,00
2351	Todo Mundo Explica	192	1	1		134896	4449772	$b 99,00
2353	Diamante De Mendigo	192	1	1		206053	6775101	$b 99,00
2357	Rock Das Aranhas (Ao Vivo) (Live)	192	1	1		231836	7591945	$b 99,00
2358	The Power Of Equality	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	243591	8148266	$b 99,00
2359	If You Have To Ask	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	216790	7199175	$b 99,00
2360	Breaking The Girl	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	295497	9805526	$b 99,00
2361	Funky Monks	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	323395	10708168	$b 99,00
2362	Suck My Kiss	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	217234	7129137	$b 99,00
2363	I Could Have Lied	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	244506	8088244	$b 99,00
2364	Mellowship Slinky In B Major	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	240091	7971384	$b 99,00
2365	The Righteous & The Wicked	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	248084	8134096	$b 99,00
2366	Give It Away	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	283010	9308997	$b 99,00
2367	Blood Sugar Sex Magik	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	271229	8940573	$b 99,00
2368	Under The Bridge	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	264359	8682716	$b 99,00
2369	Naked In The Rain	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	265717	8724674	$b 99,00
2370	Apache Rose Peacock	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	282226	9312588	$b 99,00
2371	The Greeting Song	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	193593	6346507	$b 99,00
2372	My Lovely Man	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	279118	9220114	$b 99,00
2373	Sir Psycho Sexy	193	1	4	Anthony Kiedis/Chad Smith/Flea/John Frusciante	496692	16354362	$b 99,00
2374	They're Red Hot	193	1	4	Robert Johnson	71941	2382220	$b 99,00
2375	By The Way	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	218017	7197430	$b 99,00
2376	Universally Speaking	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	259213	8501904	$b 99,00
2377	This Is The Place	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	257906	8469765	$b 99,00
2378	Dosed	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	312058	10235611	$b 99,00
2379	Don't Forget Me	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	277995	9107071	$b 99,00
2380	The Zephyr Song	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	232960	7690312	$b 99,00
2381	Can't Stop	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	269400	8872479	$b 99,00
2382	I Could Die For You	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	193906	6333311	$b 99,00
2383	Midnight	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	295810	9702450	$b 99,00
2384	Throw Away Your Television	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	224574	7483526	$b 99,00
2385	Cabron	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	218592	7458864	$b 99,00
2386	Tear	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	317413	10395500	$b 99,00
2387	On Mercury	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	208509	6834762	$b 99,00
2388	Minor Thing	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	217835	7148115	$b 99,00
2389	Warm Tape	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	256653	8358200	$b 99,00
2390	Venice Queen	194	1	1	Anthony Kiedis, Flea, John Frusciante, and Chad Smith	369110	12280381	$b 99,00
2391	Around The World	195	1	1	Anthony Kiedis/Chad Smith/Flea/John Frusciante	238837	7859167	$b 99,00
2392	Parallel Universe	195	1	1	Red Hot Chili Peppers	270654	8958519	$b 99,00
2393	Scar Tissue	195	1	1	Red Hot Chili Peppers	217469	7153744	$b 99,00
2394	Otherside	195	1	1	Red Hot Chili Peppers	255973	8357989	$b 99,00
2395	Get On Top	195	1	1	Red Hot Chili Peppers	198164	6587883	$b 99,00
2396	Californication	195	1	1	Red Hot Chili Peppers	321671	10568999	$b 99,00
2397	Easily	195	1	1	Red Hot Chili Peppers	231418	7504534	$b 99,00
2398	Porcelain	195	1	1	Anthony Kiedis/Chad Smith/Flea/John Frusciante	163787	5278793	$b 99,00
2399	Emit Remmus	195	1	1	Red Hot Chili Peppers	240300	7901717	$b 99,00
2400	I Like Dirt	195	1	1	Red Hot Chili Peppers	157727	5225917	$b 99,00
2401	This Velvet Glove	195	1	1	Red Hot Chili Peppers	225280	7480537	$b 99,00
2402	Savior	195	1	1	Anthony Kiedis/Chad Smith/Flea/John Frusciante	292493	9551885	$b 99,00
2403	Purple Stain	195	1	1	Red Hot Chili Peppers	253440	8359971	$b 99,00
2404	Right On Time	195	1	1	Red Hot Chili Peppers	112613	3722219	$b 99,00
2405	Road Trippin'	195	1	1	Red Hot Chili Peppers	205635	6685831	$b 99,00
2406	The Spirit Of Radio	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	299154	9862012	$b 99,00
2407	The Trees	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	285126	9345473	$b 99,00
2408	Something For Nothing	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	240770	7898395	$b 99,00
2409	Freewill	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	324362	10694110	$b 99,00
2410	Xanadu	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	667428	21753168	$b 99,00
2411	Bastille Day	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	280528	9264769	$b 99,00
2412	By-Tor And The Snow Dog	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	519888	17076397	$b 99,00
2413	Anthem	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	264515	8693343	$b 99,00
2414	Closer To The Heart	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	175412	5767005	$b 99,00
2669	Get Off Of My Cloud	216	1	1	Jagger/Richards	176013	5719514	$b 99,00
2415	2112 Overture	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	272718	8898066	$b 99,00
2416	The Temples Of Syrinx	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	133459	4360163	$b 99,00
2417	La Villa Strangiato	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	577488	19137855	$b 99,00
2418	Fly By Night	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	202318	6683061	$b 99,00
2419	Finding My Way	196	1	1	Geddy Lee And Alex Lifeson/Geddy Lee And Neil Peart/Rush	305528	9985701	$b 99,00
2420	Jingo	197	1	1	M.Babatunde Olantunji	592953	19736495	$b 99,00
2421	El Corazon Manda	197	1	1	E.Weiss	713534	23519583	$b 99,00
2422	La Puesta Del Sol	197	1	1	E.Weiss	628062	20614621	$b 99,00
2423	Persuasion	197	1	1	Carlos Santana	318432	10354751	$b 99,00
2424	As The Years Go by	197	1	1	Albert King	233064	7566829	$b 99,00
2425	Soul Sacrifice	197	1	1	Carlos Santana	296437	9801120	$b 99,00
2426	Fried Neckbones And Home Fries	197	1	1	W.Correa	638563	20939646	$b 99,00
2427	Santana Jam	197	1	1	Carlos Santana	882834	29207100	$b 99,00
2428	Evil Ways	198	1	1		475402	15289235	$b 99,00
2429	We've Got To Get Together/Jingo	198	1	1		1070027	34618222	$b 99,00
2430	Rock Me	198	1	1		94720	3037596	$b 99,00
2431	Just Ain't Good Enough	198	1	1		850259	27489067	$b 99,00
2432	Funky Piano	198	1	1		934791	30200730	$b 99,00
2433	The Way You Do To Mer	198	1	1		618344	20028702	$b 99,00
2434	Holding Back The Years	141	1	1	Mick Hucknall and Neil Moss	270053	8833220	$b 99,00
2435	Money's Too Tight To Mention	141	1	1	John and William Valentine	268408	8861921	$b 99,00
2436	The Right Thing	141	1	1	Mick Hucknall	262687	8624063	$b 99,00
2437	It's Only Love	141	1	1	Jimmy and Vella Cameron	232594	7659017	$b 99,00
2438	A New Flame	141	1	1	Mick Hucknall	237662	7822875	$b 99,00
2439	You've Got It	141	1	1	Mick Hucknall and Lamont Dozier	235232	7712845	$b 99,00
2440	If You Don't Know Me By Now	141	1	1	Kenny Gamble and Leon Huff	206524	6712634	$b 99,00
2441	Stars	141	1	1	Mick Hucknall	248137	8194906	$b 99,00
2442	Something Got Me Started	141	1	1	Mick Hucknall and Fritz McIntyre	239595	7997139	$b 99,00
2443	Thrill Me	141	1	1	Mick Hucknall and Fritz McIntyre	303934	10034711	$b 99,00
2444	Your Mirror	141	1	1	Mick Hucknall	240666	7893821	$b 99,00
2445	For Your Babies	141	1	1	Mick Hucknall	256992	8408803	$b 99,00
2446	So Beautiful	141	1	1	Mick Hucknall	298083	9837832	$b 99,00
2447	Angel	141	1	1	Carolyn Franklin and Sonny Saunders	240561	7880256	$b 99,00
2448	Fairground	141	1	1	Mick Hucknall	263888	8793094	$b 99,00
2451	Ela Desapareceu	199	1	1	Chico Amaral/Samuel Rosa	250122	8289200	$b 99,00
2455	Maquinarama	199	1	1	Chico Amaral/Samuel Rosa	245629	8213710	$b 99,00
2458	Fica	199	1	1	Chico Amaral/Samuel Rosa	272169	8980972	$b 99,00
2459	Ali	199	1	1	Nando Reis/Samuel Rosa	306390	10110351	$b 99,00
2472	Lucky 13	201	1	4	Billy Corgan	189387	6200617	$b 99,00
2473	Aeroplane Flies High	201	1	4	Billy Corgan	473391	15408329	$b 99,00
2474	Because You Are	201	1	4	Billy Corgan	226403	7405137	$b 99,00
2475	Slow Dawn	201	1	4	Billy Corgan	192339	6269057	$b 99,00
2476	Believe	201	1	4	James Iha	192940	6320652	$b 99,00
2477	My Mistake	201	1	4	Billy Corgan	240901	7843477	$b 99,00
2478	Marquis In Spades	201	1	4	Billy Corgan	192731	6304789	$b 99,00
2479	Here's To The Atom Bomb	201	1	4	Billy Corgan	266893	8763140	$b 99,00
2480	Sparrow	201	1	4	Billy Corgan	176822	5696989	$b 99,00
2481	Waiting	201	1	4	Billy Corgan	228336	7627641	$b 99,00
2482	Saturnine	201	1	4	Billy Corgan	229877	7523502	$b 99,00
2483	Rock On	201	1	4	David Cook	366471	12133825	$b 99,00
2484	Set The Ray To Jerry	201	1	4	Billy Corgan	249364	8215184	$b 99,00
2485	Winterlong	201	1	4	Billy Corgan	299389	9670616	$b 99,00
2486	Soot & Stars	201	1	4	Billy Corgan	399986	12866557	$b 99,00
2487	Blissed & Gone	201	1	4	Billy Corgan	286302	9305998	$b 99,00
2488	Siva	202	1	4	Billy Corgan	261172	8576622	$b 99,00
2489	Rhinocerous	202	1	4	Billy Corgan	353462	11526684	$b 99,00
2490	Drown	202	1	4	Billy Corgan	270497	8883496	$b 99,00
2491	Cherub Rock	202	1	4	Billy Corgan	299389	9786739	$b 99,00
2492	Today	202	1	4	Billy Corgan	202213	6596933	$b 99,00
2493	Disarm	202	1	4	Billy Corgan	198556	6508249	$b 99,00
2494	Landslide	202	1	4	Stevie Nicks	190275	6187754	$b 99,00
2495	Bullet With Butterfly Wings	202	1	4	Billy Corgan	257306	8431747	$b 99,00
2496	1979	202	1	4	Billy Corgan	263653	8728470	$b 99,00
2497	Zero	202	1	4	Billy Corgan	161123	5267176	$b 99,00
2498	Tonight, Tonight	202	1	4	Billy Corgan	255686	8351543	$b 99,00
2499	Eye	202	1	4	Billy Corgan	294530	9784201	$b 99,00
2500	Ava Adore	202	1	4	Billy Corgan	261433	8590412	$b 99,00
2501	Perfect	202	1	4	Billy Corgan	203023	6734636	$b 99,00
2502	The Everlasting Gaze	202	1	4	Billy Corgan	242155	7844404	$b 99,00
2503	Stand Inside Your Love	202	1	4	Billy Corgan	253753	8270113	$b 99,00
2504	Real Love	202	1	4	Billy Corgan	250697	8025896	$b 99,00
2505	[Untitled]	202	1	4	Billy Corgan	231784	7689713	$b 99,00
2506	Nothing To Say	203	1	1	Chris Cornell/Kim Thayil	238027	7744833	$b 99,00
2507	Flower	203	1	1	Chris Cornell/Kim Thayil	208822	6830732	$b 99,00
2508	Loud Love	203	1	1	Chris Cornell	297456	9660953	$b 99,00
2509	Hands All Over	203	1	1	Chris Cornell/Kim Thayil	362475	11893108	$b 99,00
2510	Get On The Snake	203	1	1	Chris Cornell/Kim Thayil	225123	7313744	$b 99,00
2511	Jesus Christ Pose	203	1	1	Ben Shepherd/Chris Cornell/Kim Thayil/Matt Cameron	352966	11739886	$b 99,00
2512	Outshined	203	1	1	Chris Cornell	312476	10274629	$b 99,00
2513	Rusty Cage	203	1	1	Chris Cornell	267728	8779485	$b 99,00
2514	Spoonman	203	1	1	Chris Cornell	248476	8289906	$b 99,00
2515	The Day I Tried To Live	203	1	1	Chris Cornell	321175	10507137	$b 99,00
2516	Black Hole Sun	203	1	1	Soundgarden	320365	10425229	$b 99,00
2517	Fell On Black Days	203	1	1	Chris Cornell	282331	9256082	$b 99,00
2518	Pretty Noose	203	1	1	Chris Cornell	253570	8317931	$b 99,00
2519	Burden In My Hand	203	1	1	Chris Cornell	292153	9659911	$b 99,00
2520	Blow Up The Outside World	203	1	1	Chris Cornell	347898	11379527	$b 99,00
2521	Ty Cobb	203	1	1	Ben Shepherd/Chris Cornell	188786	6233136	$b 99,00
2522	Bleed Together	203	1	1	Chris Cornell	232202	7597074	$b 99,00
2523	Morning Dance	204	1	2	Jay Beckenstein	238759	8101979	$b 99,00
2524	Jubilee	204	1	2	Jeremy Wall	275147	9151846	$b 99,00
2525	Rasul	204	1	2	Jeremy Wall	238315	7854737	$b 99,00
2526	Song For Lorraine	204	1	2	Jay Beckenstein	240091	8101723	$b 99,00
2527	Starburst	204	1	2	Jeremy Wall	291500	9768399	$b 99,00
2528	Heliopolis	204	1	2	Jay Beckenstein	338729	11365655	$b 99,00
2529	It Doesn't Matter	204	1	2	Chet Catallo	270027	9034177	$b 99,00
2530	Little Linda	204	1	2	Jeremy Wall	264019	8958743	$b 99,00
2531	End Of Romanticism	204	1	2	Rick Strauss	320078	10553155	$b 99,00
2532	The House Is Rockin'	205	1	6	Doyle Bramhall/Stevie Ray Vaughan	144352	4706253	$b 99,00
2533	Crossfire	205	1	6	B. Carter/C. Layton/R. Ellsworth/R. Wynans/T. Shannon	251219	8238033	$b 99,00
2534	Tightrope	205	1	6	Doyle Bramhall/Stevie Ray Vaughan	281155	9254906	$b 99,00
2535	Let Me Love You Baby	205	1	6	Willie Dixon	164127	5378455	$b 99,00
2536	Leave My Girl Alone	205	1	6	B. Guy	256365	8438021	$b 99,00
2537	Travis Walk	205	1	6	Stevie Ray Vaughan	140826	4650979	$b 99,00
2538	Wall Of Denial	205	1	6	Doyle Bramhall/Stevie Ray Vaughan	336927	11085915	$b 99,00
2539	Scratch-N-Sniff	205	1	6	Doyle Bramhall/Stevie Ray Vaughan	163422	5353627	$b 99,00
2540	Love Me Darlin'	205	1	6	C. Burnett	201586	6650869	$b 99,00
2541	Riviera Paradise	205	1	6	Stevie Ray Vaughan	528692	17232776	$b 99,00
2542	Dead And Bloated	206	1	1	R. DeLeo/Weiland	310386	10170433	$b 99,00
2543	Sex Type Thing	206	1	1	D. DeLeo/Kretz/Weiland	218723	7102064	$b 99,00
2544	Wicked Garden	206	1	1	D. DeLeo/R. DeLeo/Weiland	245368	7989505	$b 99,00
2545	No Memory	206	1	1	Dean Deleo	80613	2660859	$b 99,00
2546	Sin	206	1	1	R. DeLeo/Weiland	364800	12018823	$b 99,00
2547	Naked Sunday	206	1	1	D. DeLeo/Kretz/R. DeLeo/Weiland	229720	7444201	$b 99,00
2548	Creep	206	1	1	R. DeLeo/Weiland	333191	10894988	$b 99,00
2549	Piece Of Pie	206	1	1	R. DeLeo/Weiland	324623	10605231	$b 99,00
2550	Plush	206	1	1	R. DeLeo/Weiland	314017	10229848	$b 99,00
2551	Wet My Bed	206	1	1	R. DeLeo/Weiland	96914	3198627	$b 99,00
2552	Crackerman	206	1	1	Kretz/R. DeLeo/Weiland	194403	6317361	$b 99,00
2553	Where The River Goes	206	1	1	D. DeLeo/Kretz/Weiland	505991	16468904	$b 99,00
2554	Soldier Side - Intro	207	1	3	Dolmayan, John/Malakian, Daron/Odadjian, Shavo	63764	2056079	$b 99,00
2555	B.Y.O.B.	207	1	3	Tankian, Serj	255555	8407935	$b 99,00
2556	Revenga	207	1	3	Tankian, Serj	228127	7503805	$b 99,00
2557	Cigaro	207	1	3	Tankian, Serj	131787	4321705	$b 99,00
2558	Radio/Video	207	1	3	Dolmayan, John/Malakian, Daron/Odadjian, Shavo	249312	8224917	$b 99,00
2559	This Cocaine Makes Me Feel Like I'm On This Song	207	1	3	Tankian, Serj	128339	4185193	$b 99,00
2560	Violent Pornography	207	1	3	Dolmayan, John/Malakian, Daron/Odadjian, Shavo	211435	6985960	$b 99,00
2561	Question!	207	1	3	Tankian, Serj	200698	6616398	$b 99,00
2562	Sad Statue	207	1	3	Tankian, Serj	205897	6733449	$b 99,00
2563	Old School Hollywood	207	1	3	Dolmayan, John/Malakian, Daron/Odadjian, Shavo	176953	5830258	$b 99,00
2564	Lost in Hollywood	207	1	3	Tankian, Serj	320783	10535158	$b 99,00
2565	The Sun Road	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	880640	29008407	$b 99,00
2566	Dark Corners	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	513541	16839223	$b 99,00
2567	Duende	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	447582	14956771	$b 99,00
2568	Black Light Syndrome	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	526471	17300835	$b 99,00
2569	Falling in Circles	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	549093	18263248	$b 99,00
2570	Book of Hours	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	583366	19464726	$b 99,00
2571	Chaos-Control	208	1	1	Terry Bozzio, Steve Stevens, Tony Levin	529841	17455568	$b 99,00
2572	Midnight From The Inside Out	209	1	6	Chris Robinson/Rich Robinson	286981	9442157	$b 99,00
2573	Sting Me	209	1	6	Chris Robinson/Rich Robinson	268094	8813561	$b 99,00
2574	Thick & Thin	209	1	6	Chris Robinson/Rich Robinson	222720	7284377	$b 99,00
2575	Greasy Grass River	209	1	6	Chris Robinson/Rich Robinson	218749	7157045	$b 99,00
2576	Sometimes Salvation	209	1	6	Chris Robinson/Rich Robinson	389146	12749424	$b 99,00
2577	Cursed Diamonds	209	1	6	Chris Robinson/Rich Robinson	368300	12047978	$b 99,00
2578	Miracle To Me	209	1	6	Chris Robinson/Rich Robinson	372636	12222116	$b 99,00
2579	Wiser Time	209	1	6	Chris Robinson/Rich Robinson	459990	15161907	$b 99,00
2580	Girl From A Pawnshop	209	1	6	Chris Robinson/Rich Robinson	404688	13250848	$b 99,00
2581	Cosmic Fiend	209	1	6	Chris Robinson/Rich Robinson	308401	10115556	$b 99,00
2582	Black Moon Creeping	210	1	6	Chris Robinson/Rich Robinson	359314	11740886	$b 99,00
2583	High Head Blues	210	1	6	Chris Robinson/Rich Robinson	371879	12227998	$b 99,00
2584	Title Song	210	1	6	Chris Robinson/Rich Robinson	505521	16501316	$b 99,00
2585	She Talks To Angels	210	1	6	Chris Robinson/Rich Robinson	361978	11837342	$b 99,00
2586	Twice As Hard	210	1	6	Chris Robinson/Rich Robinson	275565	9008067	$b 99,00
2587	Lickin'	210	1	6	Chris Robinson/Rich Robinson	314409	10331216	$b 99,00
2588	Soul Singing	210	1	6	Chris Robinson/Rich Robinson	233639	7672489	$b 99,00
2589	Hard To Handle	210	1	6	A.Isbell/A.Jones/O.Redding	206994	6786304	$b 99,00
2590	Remedy	210	1	6	Chris Robinson/Rich Robinson	337084	11049098	$b 99,00
2591	White Riot	211	1	4	Joe Strummer/Mick Jones	118726	3922819	$b 99,00
2592	Remote Control	211	1	4	Joe Strummer/Mick Jones	180297	5949647	$b 99,00
2593	Complete Control	211	1	4	Joe Strummer/Mick Jones	192653	6272081	$b 99,00
2594	Clash City Rockers	211	1	4	Joe Strummer/Mick Jones	227500	7555054	$b 99,00
2595	(White Man) In Hammersmith Palais	211	1	4	Joe Strummer/Mick Jones	240640	7883532	$b 99,00
2596	Tommy Gun	211	1	4	Joe Strummer/Mick Jones	195526	6399872	$b 99,00
2597	English Civil War	211	1	4	Mick Jones/Traditional arr. Joe Strummer	156708	5111226	$b 99,00
2598	I Fought The Law	211	1	4	Sonny Curtis	159764	5245258	$b 99,00
2599	London Calling	211	1	4	Joe Strummer/Mick Jones	199706	6569007	$b 99,00
2600	Train In Vain	211	1	4	Joe Strummer/Mick Jones	189675	6329877	$b 99,00
2601	Bankrobber	211	1	4	Joe Strummer/Mick Jones	272431	9067323	$b 99,00
2602	The Call Up	211	1	4	The Clash	324336	10746937	$b 99,00
2603	Hitsville UK	211	1	4	The Clash	261433	8606887	$b 99,00
2604	The Magnificent Seven	211	1	4	The Clash	268486	8889821	$b 99,00
2605	This Is Radio Clash	211	1	4	The Clash	249756	8366573	$b 99,00
2606	Know Your Rights	211	1	4	The Clash	217678	7195726	$b 99,00
2607	Rock The Casbah	211	1	4	The Clash	222145	7361500	$b 99,00
2608	Should I Stay Or Should I Go	211	1	4	The Clash	187219	6188688	$b 99,00
2609	War (The Process)	212	1	1	Billy Duffy/Ian Astbury	252630	8254842	$b 99,00
2610	The Saint	212	1	1	Billy Duffy/Ian Astbury	216215	7061584	$b 99,00
2611	Rise	212	1	1	Billy Duffy/Ian Astbury	219088	7106195	$b 99,00
2612	Take The Power	212	1	1	Billy Duffy/Ian Astbury	235755	7650012	$b 99,00
2613	Breathe	212	1	1	Billy Duffy/Ian Astbury/Marti Frederiksen/Mick Jones	299781	9742361	$b 99,00
2614	Nico	212	1	1	Billy Duffy/Ian Astbury	289488	9412323	$b 99,00
2615	American Gothic	212	1	1	Billy Duffy/Ian Astbury	236878	7739840	$b 99,00
2616	Ashes And Ghosts	212	1	1	Billy Duffy/Bob Rock/Ian Astbury	300591	9787692	$b 99,00
2617	Shape The Sky	212	1	1	Billy Duffy/Ian Astbury	209789	6885647	$b 99,00
2618	Speed Of Light	212	1	1	Billy Duffy/Bob Rock/Ian Astbury	262817	8563352	$b 99,00
2619	True Believers	212	1	1	Billy Duffy/Ian Astbury	308009	9981359	$b 99,00
2620	My Bridges Burn	212	1	1	Billy Duffy/Ian Astbury	231862	7571370	$b 99,00
2621	She Sells Sanctuary	213	1	1		253727	8368634	$b 99,00
2622	Fire Woman	213	1	1		312790	10196995	$b 99,00
2623	Lil' Evil	213	1	1		165825	5419655	$b 99,00
2624	Spirit Walker	213	1	1		230060	7555897	$b 99,00
2625	The Witch	213	1	1		258768	8725403	$b 99,00
2626	Revolution	213	1	1		256026	8371254	$b 99,00
2627	Wild Hearted Son	213	1	1		266893	8670550	$b 99,00
2628	Love Removal Machine	213	1	1		257619	8412167	$b 99,00
2629	Rain	213	1	1		236669	7788461	$b 99,00
2630	Edie (Ciao Baby)	213	1	1		241632	7846177	$b 99,00
2631	Heart Of Soul	213	1	1		274207	8967257	$b 99,00
2632	Love	213	1	1		326739	10729824	$b 99,00
2633	Wild Flower	213	1	1		215536	7084321	$b 99,00
2634	Go West	213	1	1		238158	7777749	$b 99,00
2635	Resurrection Joe	213	1	1		255451	8532840	$b 99,00
2636	Sun King	213	1	1		368431	12010865	$b 99,00
2637	Sweet Soul Sister	213	1	1		212009	6889883	$b 99,00
2638	Earth Mofo	213	1	1		282200	9204581	$b 99,00
2639	Break on Through	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	149342	4943144	$b 99,00
2640	Soul Kitchen	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	215066	7040865	$b 99,00
2641	The Crystal Ship	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	154853	5052658	$b 99,00
2642	Twentienth Century Fox	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	153913	5069211	$b 99,00
2643	Alabama Song	214	1	1	Weill-Brecht	200097	6563411	$b 99,00
2644	Light My Fire	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	428329	13963351	$b 99,00
2645	Back Door Man	214	1	1	Willie Dixon, C. Burnett	214360	7035636	$b 99,00
2646	I Looked At You	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	142080	4663988	$b 99,00
2647	End Of The Night	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	172695	5589732	$b 99,00
2648	Take It As It Comes	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	137168	4512656	$b 99,00
2649	The End	214	1	1	Robby Krieger, Ray Manzarek, John Densmore, Jim Morrison	701831	22927336	$b 99,00
2650	Roxanne	215	1	1	G M Sumner	192992	6330159	$b 99,00
2651	Can't Stand Losing You	215	1	1	G M Sumner	181159	5971983	$b 99,00
2652	Message in a Bottle	215	1	1	G M Sumner	291474	9647829	$b 99,00
2653	Walking on the Moon	215	1	1	G M Sumner	302080	10019861	$b 99,00
2654	Don't Stand so Close to Me	215	1	1	G M Sumner	241031	7956658	$b 99,00
2655	De Do Do Do, De Da Da Da	215	1	1	G M Sumner	247196	8227075	$b 99,00
2656	Every Little Thing She Does is Magic	215	1	1	G M Sumner	261120	8646853	$b 99,00
2657	Invisible Sun	215	1	1	G M Sumner	225593	7304320	$b 99,00
2658	Spirit's in the Material World	215	1	1	G M Sumner	181133	5986622	$b 99,00
2659	Every Breath You Take	215	1	1	G M Sumner	254615	8364520	$b 99,00
2660	King Of Pain	215	1	1	G M Sumner	300512	9880303	$b 99,00
2661	Wrapped Around Your Finger	215	1	1	G M Sumner	315454	10361490	$b 99,00
2662	Don't Stand So Close to Me '86	215	1	1	G M Sumner	293590	9636683	$b 99,00
2663	Message in a Bottle (new classic rock mix)	215	1	1	G M Sumner	290951	9640349	$b 99,00
2664	Time Is On My Side	216	1	1	Jerry Ragavoy	179983	5855836	$b 99,00
2665	Heart Of Stone	216	1	1	Jagger/Richards	164493	5329538	$b 99,00
2666	Play With Fire	216	1	1	Nanker Phelge	132022	4265297	$b 99,00
2667	Satisfaction	216	1	1	Jagger/Richards	226612	7398766	$b 99,00
2668	As Tears Go By	216	1	1	Jagger/Richards/Oldham	164284	5357350	$b 99,00
2670	Mother's Little Helper	216	1	1	Jagger/Richards	167549	5422434	$b 99,00
2671	19th Nervous Breakdown	216	1	1	Jagger/Richards	237923	7742984	$b 99,00
2672	Paint It Black	216	1	1	Jagger/Richards	226063	7442888	$b 99,00
2673	Under My Thumb	216	1	1	Jagger/Richards	221387	7371799	$b 99,00
2674	Ruby Tuesday	216	1	1	Jagger/Richards	197459	6433467	$b 99,00
2675	Let's Spend The Night Together	216	1	1	Jagger/Richards	217495	7137048	$b 99,00
2676	Intro	217	1	1	Jagger/Richards	49737	1618591	$b 99,00
2677	You Got Me Rocking	217	1	1	Jagger/Richards	205766	6734385	$b 99,00
2678	Gimmie Shelters	217	1	1	Jagger/Richards	382119	12528764	$b 99,00
2679	Flip The Switch	217	1	1	Jagger/Richards	252421	8336591	$b 99,00
2680	Memory Motel	217	1	1	Jagger/Richards	365844	11982431	$b 99,00
2681	Corinna	217	1	1	Jesse Ed Davis III/Taj Mahal	257488	8449471	$b 99,00
2682	Saint Of Me	217	1	1	Jagger/Richards	325694	10725160	$b 99,00
2683	Wainting On A Friend	217	1	1	Jagger/Richards	302497	9978046	$b 99,00
2684	Sister Morphine	217	1	1	Faithfull/Jagger/Richards	376215	12345289	$b 99,00
2685	Live With Me	217	1	1	Jagger/Richards	234893	7709006	$b 99,00
2686	Respectable	217	1	1	Jagger/Richards	215693	7099669	$b 99,00
2687	Thief In The Night	217	1	1	De Beauport/Jagger/Richards	337266	10952756	$b 99,00
2688	The Last Time	217	1	1	Jagger/Richards	287294	9498758	$b 99,00
2689	Out Of Control	217	1	1	Jagger/Richards	479242	15749289	$b 99,00
2690	Love Is Strong	218	1	1	Jagger/Richards	230896	7639774	$b 99,00
2691	You Got Me Rocking	218	1	1	Jagger/Richards	215928	7162159	$b 99,00
2692	Sparks Will Fly	218	1	1	Jagger/Richards	196466	6492847	$b 99,00
2693	The Worst	218	1	1	Jagger/Richards	144613	4750094	$b 99,00
2694	New Faces	218	1	1	Jagger/Richards	172146	5689122	$b 99,00
2695	Moon Is Up	218	1	1	Jagger/Richards	222119	7366316	$b 99,00
2696	Out Of Tears	218	1	1	Jagger/Richards	327418	10677236	$b 99,00
2697	I Go Wild	218	1	1	Jagger/Richards	264019	8630833	$b 99,00
2698	Brand New Car	218	1	1	Jagger/Richards	256052	8459344	$b 99,00
2699	Sweethearts Together	218	1	1	Jagger/Richards	285492	9550459	$b 99,00
2700	Suck On The Jugular	218	1	1	Jagger/Richards	268225	8920566	$b 99,00
2701	Blinded By Rainbows	218	1	1	Jagger/Richards	273946	8971343	$b 99,00
2702	Baby Break It Down	218	1	1	Jagger/Richards	249417	8197309	$b 99,00
2703	Thru And Thru	218	1	1	Jagger/Richards	375092	12175406	$b 99,00
2704	Mean Disposition	218	1	1	Jagger/Richards	249155	8273602	$b 99,00
2705	Walking Wounded	219	1	4	The Tea Party	277968	9184345	$b 99,00
2706	Temptation	219	1	4	The Tea Party	205087	6711943	$b 99,00
2707	The Messenger	219	1	4	Daniel Lanois	212062	6975437	$b 99,00
2708	Psychopomp	219	1	4	The Tea Party	315559	10295199	$b 99,00
2709	Sister Awake	219	1	4	The Tea Party	343875	11299407	$b 99,00
2710	The Bazaar	219	1	4	The Tea Party	222458	7245691	$b 99,00
2711	Save Me (Remix)	219	1	4	The Tea Party	396303	13053839	$b 99,00
2712	Fire In The Head	219	1	4	The Tea Party	306337	10005675	$b 99,00
2713	Release	219	1	4	The Tea Party	244114	8014606	$b 99,00
2714	Heaven Coming Down	219	1	4	The Tea Party	241867	7846459	$b 99,00
2715	The River (Remix)	219	1	4	The Tea Party	343170	11193268	$b 99,00
2716	Babylon	219	1	4	The Tea Party	169795	5568808	$b 99,00
2717	Waiting On A Sign	219	1	4	The Tea Party	261903	8558590	$b 99,00
2718	Life Line	219	1	4	The Tea Party	277786	9082773	$b 99,00
2719	Paint It Black	219	1	4	Keith Richards/Mick Jagger	214752	7101572	$b 99,00
2720	Temptation	220	1	4	The Tea Party	205244	6719465	$b 99,00
2721	Army Ants	220	1	4	The Tea Party	215405	7075838	$b 99,00
2722	Psychopomp	220	1	4	The Tea Party	317231	10351778	$b 99,00
2723	Gyroscope	220	1	4	The Tea Party	177711	5810323	$b 99,00
2724	Alarum	220	1	4	The Tea Party	298187	9712545	$b 99,00
2725	Release	220	1	4	The Tea Party	266292	8725824	$b 99,00
2726	Transmission	220	1	4	The Tea Party	317257	10351152	$b 99,00
2727	Babylon	220	1	4	The Tea Party	292466	9601786	$b 99,00
2728	Pulse	220	1	4	The Tea Party	250253	8183872	$b 99,00
2729	Emerald	220	1	4	The Tea Party	289750	9543789	$b 99,00
2730	Aftermath	220	1	4	The Tea Party	343745	11085607	$b 99,00
2731	I Can't Explain	221	1	1	Pete Townshend	125152	4082896	$b 99,00
2732	Anyway, Anyhow, Anywhere	221	1	1	Pete Townshend, Roger Daltrey	161253	5234173	$b 99,00
2733	My Generation	221	1	1	John Entwistle/Pete Townshend	197825	6446634	$b 99,00
2734	Substitute	221	1	1	Pete Townshend	228022	7409995	$b 99,00
2735	I'm A Boy	221	1	1	Pete Townshend	157126	5120605	$b 99,00
2736	Boris The Spider	221	1	1	John Entwistle	149472	4835202	$b 99,00
2737	Happy Jack	221	1	1	Pete Townshend	132310	4353063	$b 99,00
2738	Pictures Of Lily	221	1	1	Pete Townshend	164414	5329751	$b 99,00
2739	I Can See For Miles	221	1	1	Pete Townshend	262791	8604989	$b 99,00
2740	Magic Bus	221	1	1	Pete Townshend	197224	6452700	$b 99,00
2741	Pinball Wizard	221	1	1	John Entwistle/Pete Townshend	181890	6055580	$b 99,00
2742	The Seeker	221	1	1	Pete Townshend	204643	6736866	$b 99,00
2743	Baba O'Riley	221	1	1	John Entwistle/Pete Townshend	309472	10141660	$b 99,00
2744	Won't Get Fooled Again (Full Length Version)	221	1	1	John Entwistle/Pete Townshend	513750	16855521	$b 99,00
2745	Let's See Action	221	1	1	Pete Townshend	243513	8078418	$b 99,00
2746	5.15	221	1	1	Pete Townshend	289619	9458549	$b 99,00
2747	Join Together	221	1	1	Pete Townshend	262556	8602485	$b 99,00
2748	Squeeze Box	221	1	1	Pete Townshend	161280	5256508	$b 99,00
2749	Who Are You (Single Edit Version)	221	1	1	John Entwistle/Pete Townshend	299232	9900469	$b 99,00
2750	You Better You Bet	221	1	1	Pete Townshend	338520	11160877	$b 99,00
2751	Primavera	222	1	7	Genival Cassiano/Silvio Rochael	126615	4152604	$b 99,00
2752	Chocolate	222	1	7	Tim Maia	194690	6411587	$b 99,00
2753	Azul Da Cor Do Mar	222	1	7	Tim Maia	197955	6475007	$b 99,00
2757	New Love	222	1	7	Tim Maia	237897	7786824	$b 99,00
2763	Compadre	222	1	7	Tim Maia	171389	5631446	$b 99,00
2764	Over Again	222	1	7	Tim Maia	200489	6612634	$b 99,00
2766	O Que Me Importa	223	1	7		153155	4977852	$b 99,00
2771	A Festa Do Santo Reis	223	1	7		159791	5204995	$b 99,00
2772	I Don't Know What To Do With Myself	223	1	7		221387	7251478	$b 99,00
2774	Nosso Adeus	223	1	7		206471	6793270	$b 99,00
2776	Preciso Ser Amado	223	1	7		174001	5618895	$b 99,00
2780	Formigueiro	223	1	7		252943	8455132	$b 99,00
2819	Battlestar Galactica: The Story So Far	226	3	18		2622250	490750393	$b 199,00
2820	Occupation / Precipice	227	3	19		5286953	1054423946	$b 199,00
2821	Exodus, Pt. 1	227	3	19		2621708	475079441	$b 199,00
2822	Exodus, Pt. 2	227	3	19		2618000	466820021	$b 199,00
2823	Collaborators	227	3	19		2626626	483484911	$b 199,00
2824	Torn	227	3	19		2631291	495262585	$b 199,00
2825	A Measure of Salvation	227	3	18		2563938	489715554	$b 199,00
2826	Hero	227	3	18		2713755	506896959	$b 199,00
2827	Unfinished Business	227	3	18		2622038	528499160	$b 199,00
2828	The Passage	227	3	18		2623875	490375760	$b 199,00
2829	The Eye of Jupiter	227	3	18		2618750	517909587	$b 199,00
2830	Rapture	227	3	18		2624541	508406153	$b 199,00
2831	Taking a Break from All Your Worries	227	3	18		2624207	492700163	$b 199,00
2832	The Woman King	227	3	18		2626376	552893447	$b 199,00
2833	A Day In the Life	227	3	18		2620245	462818231	$b 199,00
2834	Dirty Hands	227	3	18		2627961	537648614	$b 199,00
2835	Maelstrom	227	3	18		2622372	514154275	$b 199,00
2836	The Son Also Rises	227	3	18		2621830	499258498	$b 199,00
2837	Crossroads, Pt. 1	227	3	20		2622622	486233524	$b 199,00
2838	Crossroads, Pt. 2	227	3	20		2869953	497335706	$b 199,00
2839	Genesis	228	3	19		2611986	515671080	$b 199,00
2840	Don't Look Back	228	3	21		2571154	493628775	$b 199,00
2841	One Giant Leap	228	3	21		2607649	521616246	$b 199,00
2842	Collision	228	3	21		2605480	526182322	$b 199,00
2843	Hiros	228	3	21		2533575	488835454	$b 199,00
2844	Better Halves	228	3	21		2573031	549353481	$b 199,00
2845	Nothing to Hide	228	3	19		2605647	510058181	$b 199,00
2846	Seven Minutes to Midnight	228	3	21		2613988	515590682	$b 199,00
2847	Homecoming	228	3	21		2601351	516015339	$b 199,00
2848	Six Months Ago	228	3	19		2602852	505133869	$b 199,00
2849	Fallout	228	3	21		2594761	501145440	$b 199,00
2850	The Fix	228	3	21		2600266	507026323	$b 199,00
2851	Distractions	228	3	21		2590382	537111289	$b 199,00
2852	Run!	228	3	21		2602602	542936677	$b 199,00
2853	Unexpected	228	3	21		2598139	511777758	$b 199,00
2854	Company Man	228	3	21		2601226	493168135	$b 199,00
2855	Company Man	228	3	21		2601101	503786316	$b 199,00
2856	Parasite	228	3	21		2602727	487461520	$b 199,00
2857	A Tale of Two Cities	229	3	19		2636970	513691652	$b 199,00
2858	Lost (Pilot, Part 1) [Premiere]	230	3	19		2548875	217124866	$b 199,00
2859	Man of Science, Man of Faith (Premiere)	231	3	19		2612250	543342028	$b 199,00
2860	Adrift	231	3	19		2564958	502663995	$b 199,00
2861	Lost (Pilot, Part 2)	230	3	19		2436583	204995876	$b 199,00
2862	The Glass Ballerina	229	3	21		2637458	535729216	$b 199,00
2863	Further Instructions	229	3	19		2563980	502041019	$b 199,00
2864	Orientation	231	3	19		2609083	500600434	$b 199,00
2865	Tabula Rasa	230	3	19		2627105	210526410	$b 199,00
2866	Every Man for Himself	229	3	21		2637387	513803546	$b 199,00
2867	Everybody Hates Hugo	231	3	19		2609192	498163145	$b 199,00
2868	Walkabout	230	3	19		2587370	207748198	$b 199,00
2869	...And Found	231	3	19		2563833	500330548	$b 199,00
2870	The Cost of Living	229	3	19		2637500	505647192	$b 199,00
2871	White Rabbit	230	3	19		2571965	201654606	$b 199,00
2872	Abandoned	231	3	19		2587041	537348711	$b 199,00
2873	House of the Rising Sun	230	3	19		2590032	210379525	$b 199,00
2874	I Do	229	3	19		2627791	504676825	$b 199,00
2875	Not In Portland	229	3	21		2637303	499061234	$b 199,00
2876	Not In Portland	229	3	21		2637345	510546847	$b 199,00
2877	The Moth	230	3	19		2631327	228896396	$b 199,00
2878	The Other 48 Days	231	3	19		2610625	535256753	$b 199,00
2879	Collision	231	3	19		2564916	475656544	$b 199,00
2880	Confidence Man	230	3	19		2615244	223756475	$b 199,00
2881	Flashes Before Your Eyes	229	3	21		2636636	537760755	$b 199,00
2882	Lost Survival Guide	229	3	21		2632590	486675063	$b 199,00
2883	Solitary	230	3	19		2612894	207045178	$b 199,00
2884	What Kate Did	231	3	19		2610250	484583988	$b 199,00
2885	Raised By Another	230	3	19		2590459	223623810	$b 199,00
2886	Stranger In a Strange Land	229	3	21		2636428	505056021	$b 199,00
2887	The 23rd Psalm	231	3	19		2610416	487401604	$b 199,00
2888	All the Best Cowboys Have Daddy Issues	230	3	19		2555492	211743651	$b 199,00
2889	The Hunting Party	231	3	21		2611333	520350364	$b 199,00
2890	Tricia Tanaka Is Dead	229	3	21		2635010	548197162	$b 199,00
2891	Enter 77	229	3	21		2629796	517521422	$b 199,00
2892	Fire + Water	231	3	21		2600333	488458695	$b 199,00
2893	Whatever the Case May Be	230	3	19		2616410	183867185	$b 199,00
2894	Hearts and Minds	230	3	19		2619462	207607466	$b 199,00
2895	Par Avion	229	3	21		2629879	517079642	$b 199,00
2896	The Long Con	231	3	19		2679583	518376636	$b 199,00
2897	One of Them	231	3	21		2698791	542332389	$b 199,00
2898	Special	230	3	19		2618530	219961967	$b 199,00
2899	The Man from Tallahassee	229	3	21		2637637	550893556	$b 199,00
2901	Homecoming	230	3	19		2515882	210675221	$b 199,00
2902	Maternity Leave	231	3	21		2780416	555244214	$b 199,00
2903	Left Behind	229	3	21		2635343	538491964	$b 199,00
2904	Outlaws	230	3	19		2619887	206500939	$b 199,00
2905	The Whole Truth	231	3	21		2610125	495487014	$b 199,00
2906	...In Translation	230	3	19		2604575	215441983	$b 199,00
2907	Lockdown	231	3	21		2610250	543886056	$b 199,00
2908	One of Us	229	3	21		2638096	502387276	$b 199,00
2909	Catch-22	229	3	21		2561394	489773399	$b 199,00
2910	Dave	231	3	19		2825166	574325829	$b 199,00
2911	Numbers	230	3	19		2609772	214709143	$b 199,00
2912	D.O.C.	229	3	21		2616032	518556641	$b 199,00
2913	Deus Ex Machina	230	3	19		2582009	214996732	$b 199,00
2914	S.O.S.	231	3	19		2639541	517979269	$b 199,00
2915	Do No Harm	230	3	19		2618487	212039309	$b 199,00
2916	Two for the Road	231	3	21		2610958	502404558	$b 199,00
2917	The Greater Good	230	3	19		2617784	214130273	$b 199,00
2918	"?"	231	3	19		2782333	528227089	$b 199,00
2919	Born to Run	230	3	19		2618619	213772057	$b 199,00
2920	Three Minutes	231	3	19		2763666	531556853	$b 199,00
2921	Exodus (Part 1)	230	3	19		2620747	213107744	$b 199,00
2922	Live Together, Die Alone, Pt. 1	231	3	21		2478041	457364940	$b 199,00
2923	Exodus (Part 2) [Season Finale]	230	3	19		2605557	208667059	$b 199,00
2924	Live Together, Die Alone, Pt. 2	231	3	19		2656531	503619265	$b 199,00
2925	Exodus (Part 3) [Season Finale]	230	3	19		2619869	197937785	$b 199,00
2926	Zoo Station	232	1	1	U2	276349	9056902	$b 99,00
2927	Even Better Than The Real Thing	232	1	1	U2	221361	7279392	$b 99,00
2928	One	232	1	1	U2	276192	9158892	$b 99,00
2929	Until The End Of The World	232	1	1	U2	278700	9132485	$b 99,00
2930	Who's Gonna Ride Your Wild Horses	232	1	1	U2	316551	10304369	$b 99,00
2931	So Cruel	232	1	1	U2	349492	11527614	$b 99,00
2932	The Fly	232	1	1	U2	268982	8825399	$b 99,00
2933	Mysterious Ways	232	1	1	U2	243826	8062057	$b 99,00
2934	Tryin' To Throw Your Arms Around The World	232	1	1	U2	232463	7612124	$b 99,00
2935	Ultraviolet (Light My Way)	232	1	1	U2	330788	10754631	$b 99,00
2936	Acrobat	232	1	1	U2	270288	8824723	$b 99,00
2937	Love Is Blindness	232	1	1	U2	263497	8531766	$b 99,00
2938	Beautiful Day	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	248163	8056723	$b 99,00
2939	Stuck In A Moment You Can't Get Out Of	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	272378	8997366	$b 99,00
2940	Elevation	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	227552	7479414	$b 99,00
2941	Walk On	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	296280	9800861	$b 99,00
2942	Kite	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	266893	8765761	$b 99,00
2943	In A Little While	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	219271	7189647	$b 99,00
2944	Wild Honey	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	226768	7466069	$b 99,00
2945	Peace On Earth	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	288496	9476171	$b 99,00
2946	When I Look At The World	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	257776	8500491	$b 99,00
2947	New York	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	330370	10862323	$b 99,00
2948	Grace	233	1	1	Adam Clayton, Bono, Larry Mullen, The Edge	330657	10877148	$b 99,00
2949	The Three Sunrises	234	1	1	U2	234788	7717990	$b 99,00
2950	Spanish Eyes	234	1	1	U2	196702	6392710	$b 99,00
2951	Sweetest Thing	234	1	1	U2	185103	6154896	$b 99,00
2952	Love Comes Tumbling	234	1	1	U2	282671	9328802	$b 99,00
2953	Bass Trap	234	1	1	U2	213289	6834107	$b 99,00
2954	Dancing Barefoot	234	1	1	Ivan Kral/Patti Smith	287895	9488294	$b 99,00
2955	Everlasting Love	234	1	1	Buzz Cason/Mac Gayden	202631	6708932	$b 99,00
2956	Unchained Melody	234	1	1	Alex North/Hy Zaret	294164	9597568	$b 99,00
2957	Walk To The Water	234	1	1	U2	289253	9523336	$b 99,00
2958	Luminous Times (Hold On To Love)	234	1	1	Brian Eno/U2	277760	9015513	$b 99,00
2959	Hallelujah Here She Comes	234	1	1	U2	242364	8027028	$b 99,00
2960	Silver And Gold	234	1	1	Bono	279875	9199746	$b 99,00
2961	Endless Deep	234	1	1	U2	179879	5899070	$b 99,00
2962	A Room At The Heartbreak Hotel	234	1	1	U2	274546	9015416	$b 99,00
2963	Trash, Trampoline And The Party Girl	234	1	1	U2	153965	5083523	$b 99,00
2964	Vertigo	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	194612	6329502	$b 99,00
2965	Miracle Drug	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	239124	7760916	$b 99,00
2966	Sometimes You Can't Make It On Your Own	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	308976	10112863	$b 99,00
2967	Love And Peace Or Else	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	290690	9476723	$b 99,00
2968	City Of Blinding Lights	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	347951	11432026	$b 99,00
2969	All Because Of You	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	219141	7198014	$b 99,00
2970	A Man And A Woman	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	270132	8938285	$b 99,00
2971	Crumbs From Your Table	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	303568	9892349	$b 99,00
2972	One Step Closer	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	231680	7512912	$b 99,00
2973	Original Of The Species	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	281443	9230041	$b 99,00
2974	Yahweh	235	1	1	Adam Clayton, Bono, Larry Mullen & The Edge	262034	8636998	$b 99,00
2975	Discotheque	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	319582	10442206	$b 99,00
2976	Do You Feel Loved	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	307539	10122694	$b 99,00
2977	Mofo	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	349178	11583042	$b 99,00
2978	If God Will Send His Angels	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	322533	10563329	$b 99,00
2979	Staring At The Sun	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	276924	9082838	$b 99,00
2980	Last Night On Earth	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	285753	9401017	$b 99,00
2981	Gone	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	266866	8746301	$b 99,00
2982	Miami	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	293041	9741603	$b 99,00
2983	The Playboy Mansion	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	280555	9274144	$b 99,00
2984	If You Wear That Velvet Dress	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	315167	10227333	$b 99,00
2985	Please	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	302602	9909484	$b 99,00
2986	Wake Up Dead Man	236	1	1	Bono, The Edge, Adam Clayton, and Larry Mullen	292832	9515903	$b 99,00
2987	Helter Skelter	237	1	1	Lennon, John/McCartney, Paul	187350	6097636	$b 99,00
2988	Van Diemen's Land	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	186044	5990280	$b 99,00
2989	Desire	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	179226	5874535	$b 99,00
2990	Hawkmoon 269	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	382458	12494987	$b 99,00
2991	All Along The Watchtower	237	1	1	Dylan, Bob	264568	8623572	$b 99,00
2992	I Still Haven't Found What I'm Looking for	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	353567	11542247	$b 99,00
2993	Freedom For My People	237	1	1	Mabins, Macie/Magee, Sterling/Robinson, Bobby	38164	1249764	$b 99,00
2994	Silver And Gold	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	349831	11450194	$b 99,00
2995	Pride (In The Name Of Love)	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	267807	8806361	$b 99,00
2996	Angel Of Harlem	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	229276	7498022	$b 99,00
2997	Love Rescue Me	237	1	1	Bono/Clayton, Adam/Dylan, Bob/Mullen Jr., Larry/The Edge	384522	12508716	$b 99,00
2998	When Love Comes To Town	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	255869	8340954	$b 99,00
2999	Heartland	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	303360	9867748	$b 99,00
3000	God Part II	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	195604	6497570	$b 99,00
3001	The Star Spangled Banner	237	1	1	Hendrix, Jimi	43232	1385810	$b 99,00
3002	Bullet The Blue Sky	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	337005	10993607	$b 99,00
3003	All I Want Is You	237	1	1	Bono/Clayton, Adam/Mullen Jr., Larry/The Edge	390243	12729820	$b 99,00
3004	Pride (In The Name Of Love)	238	1	1	U2	230243	7549085	$b 99,00
3005	New Year's Day	238	1	1	U2	258925	8491818	$b 99,00
3006	With Or Without You	238	1	1	U2	299023	9765188	$b 99,00
3007	I Still Haven't Found What I'm Looking For	238	1	1	U2	280764	9306737	$b 99,00
3008	Sunday Bloody Sunday	238	1	1	U2	282174	9269668	$b 99,00
3009	Bad	238	1	1	U2	351817	11628058	$b 99,00
3010	Where The Streets Have No Name	238	1	1	U2	276218	9042305	$b 99,00
3011	I Will Follow	238	1	1	U2	218253	7184825	$b 99,00
3012	The Unforgettable Fire	238	1	1	U2	295183	9684664	$b 99,00
3013	Sweetest Thing	238	1	1	U2 & Daragh O'Toole	183066	6071385	$b 99,00
3014	Desire	238	1	1	U2	179853	5893206	$b 99,00
3015	When Love Comes To Town	238	1	1	U2	258194	8479525	$b 99,00
3016	Angel Of Harlem	238	1	1	U2	230217	7527339	$b 99,00
3017	All I Want Is You	238	1	1	U2 & Van Dyke Parks	591986	19202252	$b 99,00
3018	Sunday Bloody Sunday	239	1	1	U2	278204	9140849	$b 99,00
3019	Seconds	239	1	1	U2	191582	6352121	$b 99,00
3020	New Year's Day	239	1	1	U2	336274	11054732	$b 99,00
3021	Like A Song...	239	1	1	U2	287294	9365379	$b 99,00
3022	Drowning Man	239	1	1	U2	254458	8457066	$b 99,00
3023	The Refugee	239	1	1	U2	221283	7374043	$b 99,00
3024	Two Hearts Beat As One	239	1	1	U2	243487	7998323	$b 99,00
3025	Red Light	239	1	1	U2	225854	7453704	$b 99,00
3026	Surrender	239	1	1	U2	333505	11221406	$b 99,00
3027	"40"	239	1	1	U2	157962	5251767	$b 99,00
3028	Zooropa	240	1	1	U2; Bono	392359	12807979	$b 99,00
3029	Babyface	240	1	1	U2; Bono	241998	7942573	$b 99,00
3030	Numb	240	1	1	U2; Edge, The	260284	8577861	$b 99,00
3031	Lemon	240	1	1	U2; Bono	418324	13988878	$b 99,00
3032	Stay (Faraway, So Close!)	240	1	1	U2; Bono	298475	9785480	$b 99,00
3033	Daddy's Gonna Pay For Your Crashed Car	240	1	1	U2; Bono	320287	10609581	$b 99,00
3034	Some Days Are Better Than Others	240	1	1	U2; Bono	257436	8417690	$b 99,00
3035	The First Time	240	1	1	U2; Bono	225697	7247651	$b 99,00
3036	Dirty Day	240	1	1	U2; Bono & Edge, The	324440	10652877	$b 99,00
3037	The Wanderer	240	1	1	U2; Bono	283951	9258717	$b 99,00
3038	Breakfast In Bed	241	1	8		196179	6513325	$b 99,00
3039	Where Did I Go Wrong	241	1	8		226742	7485054	$b 99,00
3040	I Would Do For You	241	1	8		334524	11193602	$b 99,00
3041	Homely Girl	241	1	8		203833	6790788	$b 99,00
3042	Here I Am (Come And Take Me)	241	1	8		242102	8106249	$b 99,00
3043	Kingston Town	241	1	8		226951	7638236	$b 99,00
3044	Wear You To The Ball	241	1	8		213342	7159527	$b 99,00
3045	(I Can't Help) Falling In Love With You	241	1	8		207568	6905623	$b 99,00
3046	Higher Ground	241	1	8		260179	8665244	$b 99,00
3047	Bring Me Your Cup	241	1	8		341498	11346114	$b 99,00
3048	C'est La Vie	241	1	8		270053	9031661	$b 99,00
3049	Reggae Music	241	1	8		245106	8203931	$b 99,00
3050	Superstition	241	1	8		319582	10728099	$b 99,00
3051	Until My Dying Day	241	1	8		235807	7886195	$b 99,00
3052	Where Have All The Good Times Gone?	242	1	1	Ray Davies	186723	6063937	$b 99,00
3053	Hang 'Em High	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	210259	6872314	$b 99,00
3054	Cathedral	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	82860	2650998	$b 99,00
3055	Secrets	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	206968	6803255	$b 99,00
3056	Intruder	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	100153	3282142	$b 99,00
3057	(Oh) Pretty Woman	242	1	1	Bill Dees/Roy Orbison	174680	5665828	$b 99,00
3058	Dancing In The Street	242	1	1	Ivy Jo Hunter/Marvin Gaye/William Stevenson	225985	7461499	$b 99,00
3059	Little Guitars (Intro)	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	42240	1439530	$b 99,00
3060	Little Guitars	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	228806	7453043	$b 99,00
3061	Big Bad Bill (Is Sweet William Now)	242	1	1	Jack Yellen/Milton Ager	165146	5489609	$b 99,00
3062	The Full Bug	242	1	1	Alex Van Halen/David Lee Roth/Edward Van Halen/Michael Anthony	201116	6551013	$b 99,00
3063	Happy Trails	242	1	1	Dale Evans	65488	2111141	$b 99,00
3064	Eruption	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	102164	3272891	$b 99,00
3065	Ain't Talkin' 'bout Love	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	228336	7569506	$b 99,00
3066	Runnin' With The Devil	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	215902	7061901	$b 99,00
3067	Dance the Night Away	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	185965	6087433	$b 99,00
3068	And the Cradle Will Rock...	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	213968	7011402	$b 99,00
3069	Unchained	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth, Michael Anthony	208953	6777078	$b 99,00
3070	Jump	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth	241711	7911090	$b 99,00
3071	Panama	243	1	1	Edward Van Halen, Alex Van Halen, David Lee Roth	211853	6921784	$b 99,00
3072	Why Can't This Be Love	243	1	1	Van Halen	227761	7457655	$b 99,00
3073	Dreams	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, Sammy Hagar	291813	9504119	$b 99,00
3074	When It's Love	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, Sammy Hagar	338991	11049966	$b 99,00
3075	Poundcake	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, Sammy Hagar	321854	10366978	$b 99,00
3076	Right Now	243	1	1	Van Halen	321828	10503352	$b 99,00
3077	Can't Stop Loving You	243	1	1	Van Halen	248502	8107896	$b 99,00
3078	Humans Being	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, Sammy Hagar	308950	10014683	$b 99,00
3079	Can't Get This Stuff No More	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, David Lee Roth	315376	10355753	$b 99,00
3185	Performance Review	250	3	19		1292458	256143822	$b 199,00
3080	Me Wise Magic	243	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony,/Edward Van Halen, Alex Van Halen, Michael Anthony, David Lee Roth	366053	12013467	$b 99,00
3081	Runnin' With The Devil	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	216032	7056863	$b 99,00
3082	Eruption	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	102556	3286026	$b 99,00
3083	You Really Got Me	244	1	1	Ray Davies	158589	5194092	$b 99,00
3084	Ain't Talkin' 'Bout Love	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	230060	7617284	$b 99,00
3085	I'm The One	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	226507	7373922	$b 99,00
3086	Jamie's Cryin'	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	210546	6946086	$b 99,00
3195	Take Your Daughter to Work Day	250	3	19		1268333	253451012	$b 199,00
3087	Atomic Punk	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	182073	5908861	$b 99,00
3088	Feel Your Love Tonight	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	222850	7293608	$b 99,00
3089	Little Dreamer	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	203258	6648122	$b 99,00
3090	Ice Cream Man	244	1	1	John Brim	200306	6573145	$b 99,00
3091	On Fire	244	1	1	Edward Van Halen, Alex Van Halen, Michael Anthony and David Lee Roth	180636	5879235	$b 99,00
3092	Neworld	245	1	1	Van Halen	105639	3495897	$b 99,00
3093	Without You	245	1	1	Van Halen	390295	12619558	$b 99,00
3094	One I Want	245	1	1	Van Halen	330788	10743970	$b 99,00
3095	From Afar	245	1	1	Van Halen	324414	10524554	$b 99,00
3096	Dirty Water Dog	245	1	1	Van Halen	327392	10709202	$b 99,00
3097	Once	245	1	1	Van Halen	462837	15378082	$b 99,00
3098	Fire in the Hole	245	1	1	Van Halen	331728	10846768	$b 99,00
3099	Josephina	245	1	1	Van Halen	342491	11161521	$b 99,00
3100	Year to the Day	245	1	1	Van Halen	514612	16621333	$b 99,00
3101	Primary	245	1	1	Van Halen	86987	2812555	$b 99,00
3102	Ballot or the Bullet	245	1	1	Van Halen	342282	11212955	$b 99,00
3103	How Many Say I	245	1	1	Van Halen	363937	11716855	$b 99,00
3104	Sucker Train Blues	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	267859	8738780	$b 99,00
3105	Do It For The Kids	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	235911	7693331	$b 99,00
3106	Big Machine	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	265613	8673442	$b 99,00
3107	Illegal I Song	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	257750	8483347	$b 99,00
3108	Spectacle	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	221701	7252876	$b 99,00
3109	Fall To Pieces	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	270889	8823096	$b 99,00
3110	Headspace	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	223033	7237986	$b 99,00
3111	Superhuman	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	255921	8365328	$b 99,00
3112	Set Me Free	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	247954	8053388	$b 99,00
3113	You Got No Right	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	335412	10991094	$b 99,00
3114	Slither	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	248398	8118785	$b 99,00
3115	Dirty Little Thing	246	1	1	Dave Kushner, Duff, Keith Nelson, Matt Sorum, Scott Weiland & Slash	237844	7732982	$b 99,00
3116	Loving The Alien	246	1	1	Dave Kushner, Duff, Matt Sorum, Scott Weiland & Slash	348786	11412762	$b 99,00
3132	Still Of The Night	141	1	3	Sykes	398210	13043817	$b 99,00
3133	Here I Go Again	141	1	3	Marsden	233874	7652473	$b 99,00
3134	Is This Love	141	1	3	Sykes	283924	9262360	$b 99,00
3135	Love Ain't No Stranger	141	1	3	Galley	259395	8490428	$b 99,00
3136	Looking For Love	141	1	3	Sykes	391941	12769847	$b 99,00
3137	Now You're Gone	141	1	3	Vandenberg	251141	8162193	$b 99,00
3138	Slide It In	141	1	3	Coverdale	202475	6615152	$b 99,00
3139	Slow An' Easy	141	1	3	Moody	367255	11961332	$b 99,00
3140	Judgement Day	141	1	3	Vandenberg	317074	10326997	$b 99,00
3141	You're Gonna Break My Hart Again	141	1	3	Sykes	250853	8176847	$b 99,00
3142	The Deeper The Love	141	1	3	Vandenberg	262791	8606504	$b 99,00
3143	Crying In The Rain	141	1	3	Coverdale	337005	10931921	$b 99,00
3144	Fool For Your Loving	141	1	3	Marsden/Moody	250801	8129820	$b 99,00
3145	Sweet Lady Luck	141	1	3	Vandenberg	273737	8919163	$b 99,00
3149	Vivo Isolado Do Mundo	248	1	7	Alcides Dias Lopes	180035	6073995	$b 99,00
3153	Rugas	248	1	7	Augusto Garcez/Nelson Cavaquinho	140930	4703182	$b 99,00
3155	Sem Essa de Malandro Agulha	248	1	7	Aldir Blanc/Jayme Vignoli	158484	5332668	$b 99,00
3158	Saudade Louca	248	1	7	Acyr Marques/Arlindo Cruz/Franco	243591	8136475	$b 99,00
3160	Sapopemba e Maxambomba	248	1	7	Nei Lopes/Wilson Moreira	245394	8268712	$b 99,00
3162	Lua de Ogum	248	1	7	Ratinho/Zeca Pagodinho	168463	5719129	$b 99,00
3164	Verdade	248	1	7	Carlinhos Santana/Nelson Rufino	332826	11120708	$b 99,00
3165	The Brig	229	3	21		2617325	488919543	$b 199,00
3166	.07%	228	3	21		2585794	541715199	$b 199,00
3167	Five Years Gone	228	3	21		2587712	530551890	$b 199,00
3168	The Hard Part	228	3	21		2601017	475996611	$b 199,00
3169	The Man Behind the Curtain	229	3	21		2615990	493951081	$b 199,00
3170	Greatest Hits	229	3	21		2617117	522102916	$b 199,00
3171	Landslide	228	3	21		2600725	518677861	$b 199,00
3172	The Office: An American Workplace (Pilot)	249	3	19		1380833	290482361	$b 199,00
3173	Diversity Day	249	3	19		1306416	257879716	$b 199,00
3174	Health Care	249	3	19		1321791	260493577	$b 199,00
3175	The Alliance	249	3	19		1317125	266203162	$b 199,00
3176	Basketball	249	3	19		1323541	267464180	$b 199,00
3177	Hot Girl	249	3	19		1325458	267836576	$b 199,00
3178	The Dundies	250	3	19		1253541	246845576	$b 199,00
3179	Sexual Harassment	250	3	19		1294541	273069146	$b 199,00
3180	Office Olympics	250	3	19		1290458	256247623	$b 199,00
3181	The Fire	250	3	19		1288166	266856017	$b 199,00
3182	Halloween	250	3	19		1315333	249205209	$b 199,00
3183	The Fight	250	3	19		1320028	277149457	$b 199,00
3184	The Client	250	3	19		1299341	253836788	$b 199,00
3186	Email Surveillance	250	3	19		1328870	265101113	$b 199,00
3187	Christmas Party	250	3	19		1282115	260891300	$b 199,00
3188	Booze Cruise	250	3	19		1267958	252518021	$b 199,00
3189	The Injury	250	3	19		1275275	253912762	$b 199,00
3190	The Secret	250	3	19		1264875	253143200	$b 199,00
3191	The Carpet	250	3	19		1264375	256477011	$b 199,00
3192	Boys and Girls	250	3	19		1278333	255245729	$b 199,00
3193	Valentine's Day	250	3	19		1270375	253552710	$b 199,00
3194	Dwight's Speech	250	3	19		1278041	255001728	$b 199,00
3196	Michael's Birthday	250	3	19		1237791	247238398	$b 199,00
3197	Drug Testing	250	3	19		1278625	244626927	$b 199,00
3198	Conflict Resolution	250	3	19		1274583	253808658	$b 199,00
3199	Casino Night - Season Finale	250	3	19		1712791	327642458	$b 199,00
3200	Gay Witch Hunt	251	3	19		1326534	276942637	$b 199,00
3201	The Convention	251	3	19		1297213	255117055	$b 199,00
3202	The Coup	251	3	19		1276526	267205501	$b 199,00
3203	Grief Counseling	251	3	19		1282615	256912833	$b 199,00
3204	The Initiation	251	3	19		1280113	251728257	$b 199,00
3205	Diwali	251	3	19		1279904	252726644	$b 199,00
3206	Branch Closing	251	3	19		1822781	358761786	$b 199,00
3207	The Merger	251	3	19		1801926	345960631	$b 199,00
3208	The Convict	251	3	22		1273064	248863427	$b 199,00
3209	A Benihana Christmas, Pts. 1 & 2	251	3	22		2519436	515301752	$b 199,00
3210	Back from Vacation	251	3	22		1271688	245378749	$b 199,00
3211	Traveling Salesmen	251	3	22		1289039	250822697	$b 199,00
3212	Producer's Cut: The Return	251	3	22		1700241	337219980	$b 199,00
3213	Ben Franklin	251	3	22		1271938	264168080	$b 199,00
3214	Phyllis's Wedding	251	3	22		1271521	258561054	$b 199,00
3215	Business School	251	3	22		1302093	254402605	$b 199,00
3216	Cocktails	251	3	22		1272522	259011909	$b 199,00
3217	The Negotiation	251	3	22		1767851	371663719	$b 199,00
3218	Safety Training	251	3	22		1271229	253054534	$b 199,00
3219	Product Recall	251	3	22		1268268	251208610	$b 199,00
3220	Women's Appreciation	251	3	22		1732649	338778844	$b 199,00
3221	Beach Games	251	3	22		1676134	333671149	$b 199,00
3222	The Job	251	3	22		2541875	501060138	$b 199,00
3223	How to Stop an Exploding Man	228	3	21		2687103	487881159	$b 199,00
3224	Through a Looking Glass	229	3	21		5088838	1059546140	$b 199,00
3225	Your Time Is Gonna Come	252	2	1	Page, Jones	310774	5126563	$b 99,00
3226	Battlestar Galactica, Pt. 1	253	3	20		2952702	541359437	$b 199,00
3227	Battlestar Galactica, Pt. 2	253	3	20		2956081	521387924	$b 199,00
3228	Battlestar Galactica, Pt. 3	253	3	20		2927802	554509033	$b 199,00
3229	Lost Planet of the Gods, Pt. 1	253	3	20		2922547	537812711	$b 199,00
3230	Lost Planet of the Gods, Pt. 2	253	3	20		2914664	534343985	$b 199,00
3231	The Lost Warrior	253	3	20		2920045	558872190	$b 199,00
3232	The Long Patrol	253	3	20		2925008	513122217	$b 199,00
3233	The Gun On Ice Planet Zero, Pt. 1	253	3	20		2907615	540980196	$b 199,00
3234	The Gun On Ice Planet Zero, Pt. 2	253	3	20		2924341	546542281	$b 199,00
3235	The Magnificent Warriors	253	3	20		2924716	570152232	$b 199,00
3236	The Young Lords	253	3	20		2863571	587051735	$b 199,00
3237	The Living Legend, Pt. 1	253	3	20		2924507	503641007	$b 199,00
3238	The Living Legend, Pt. 2	253	3	20		2923298	515632754	$b 199,00
3239	Fire In Space	253	3	20		2926593	536784757	$b 199,00
3240	War of the Gods, Pt. 1	253	3	20		2922630	505761343	$b 199,00
3241	War of the Gods, Pt. 2	253	3	20		2923381	487899692	$b 199,00
3242	The Man With Nine Lives	253	3	20		2956998	577829804	$b 199,00
3243	Murder On the Rising Star	253	3	20		2935894	551759986	$b 199,00
3244	Greetings from Earth, Pt. 1	253	3	20		2960293	536824558	$b 199,00
3245	Greetings from Earth, Pt. 2	253	3	20		2903778	527842860	$b 199,00
3246	Baltar's Escape	253	3	20		2922088	525564224	$b 199,00
3247	Experiment In Terra	253	3	20		2923548	547982556	$b 199,00
3248	Take the Celestra	253	3	20		2927677	512381289	$b 199,00
3249	The Hand of God	253	3	20		2924007	536583079	$b 199,00
3250	Pilot	254	3	19		2484567	492670102	$b 199,00
3251	Through the Looking Glass, Pt. 2	229	3	21		2617117	550943353	$b 199,00
3252	Through the Looking Glass, Pt. 1	229	3	21		2610860	493211809	$b 199,00
3253	Instant Karma	255	2	9		193188	3150090	$b 99,00
3254	#9 Dream	255	2	9		278312	4506425	$b 99,00
3255	Mother	255	2	9		287740	4656660	$b 99,00
3256	Give Peace a Chance	255	2	9		274644	4448025	$b 99,00
3257	Cold Turkey	255	2	9		281424	4556003	$b 99,00
3258	Whatever Gets You Thru the Night	255	2	9		215084	3499018	$b 99,00
3259	I'm Losing You	255	2	9		240719	3907467	$b 99,00
3260	Gimme Some Truth	255	2	9		232778	3780807	$b 99,00
3261	Oh, My Love	255	2	9		159473	2612788	$b 99,00
3262	Imagine	255	2	9		192329	3136271	$b 99,00
3263	Nobody Told Me	255	2	9		210348	3423395	$b 99,00
3264	Jealous Guy	255	2	9		239094	3881620	$b 99,00
3265	Working Class Hero	255	2	9		265449	4301430	$b 99,00
3266	Power to the People	255	2	9		213018	3466029	$b 99,00
3267	Imagine	255	2	9		219078	3562542	$b 99,00
3268	Beautiful Boy	255	2	9		227995	3704642	$b 99,00
3269	Isolation	255	2	9		156059	2558399	$b 99,00
3270	Watching the Wheels	255	2	9		198645	3237063	$b 99,00
3271	Grow Old With Me	255	2	9		149093	2447453	$b 99,00
3272	Gimme Some Truth	255	2	9		187546	3060083	$b 99,00
3273	[Just Like] Starting Over	255	2	9		215549	3506308	$b 99,00
3274	God	255	2	9		260410	4221135	$b 99,00
3275	Real Love	255	2	9		236911	3846658	$b 99,00
3276	Sympton of the Universe	256	2	1		340890	5489313	$b 99,00
3277	Snowblind	256	2	1		295960	4773171	$b 99,00
3278	Black Sabbath	256	2	1		364180	5860455	$b 99,00
3279	Fairies Wear Boots	256	2	1		392764	6315916	$b 99,00
3280	War Pigs	256	2	1		515435	8270194	$b 99,00
3281	The Wizard	256	2	1		282678	4561796	$b 99,00
3282	N.I.B.	256	2	1		335248	5399456	$b 99,00
3283	Sweet Leaf	256	2	1		354706	5709700	$b 99,00
3284	Never Say Die	256	2	1		258343	4173799	$b 99,00
3285	Sabbath, Bloody Sabbath	256	2	1		333622	5373633	$b 99,00
3286	Iron Man/Children of the Grave	256	2	1		552308	8858616	$b 99,00
3287	Paranoid	256	2	1		189171	3071042	$b 99,00
3288	Rock You Like a Hurricane	257	2	1		255766	4300973	$b 99,00
3289	No One Like You	257	2	1		240325	4050259	$b 99,00
3290	The Zoo	257	2	1		332740	5550779	$b 99,00
3291	Loving You Sunday Morning	257	2	1		339125	5654493	$b 99,00
3292	Still Loving You	257	2	1		390674	6491444	$b 99,00
3293	Big City Nights	257	2	1		251865	4237651	$b 99,00
3294	Believe in Love	257	2	1		325774	5437651	$b 99,00
3295	Rhythm of Love	257	2	1		231246	3902834	$b 99,00
3296	I Can't Explain	257	2	1		205332	3482099	$b 99,00
3297	Tease Me Please Me	257	2	1		287229	4811894	$b 99,00
3298	Wind of Change	257	2	1		315325	5268002	$b 99,00
3299	Send Me an Angel	257	2	1		273041	4581492	$b 99,00
3300	Jump Around	258	1	17	E. Schrody/L. Muggerud	217835	8715653	$b 99,00
3301	Salutations	258	1	17	E. Schrody/L. Dimant	69120	2767047	$b 99,00
3302	Put Your Head Out	258	1	17	E. Schrody/L. Freese/L. Muggerud	182230	7291473	$b 99,00
3303	Top O' The Morning To Ya	258	1	17	E. Schrody/L. Dimant	216633	8667599	$b 99,00
3304	Commercial 1	258	1	17	L. Muggerud	7941	319888	$b 99,00
3305	House And The Rising Sun	258	1	17	E. Schrody/J. Vasquez/L. Dimant	219402	8778369	$b 99,00
3306	Shamrocks And Shenanigans	258	1	17	E. Schrody/L. Dimant	218331	8735518	$b 99,00
3307	House Of Pain Anthem	258	1	17	E. Schrody/L. Dimant	155611	6226713	$b 99,00
3308	Danny Boy, Danny Boy	258	1	17	E. Schrody/L. Muggerud	114520	4583091	$b 99,00
3309	Guess Who's Back	258	1	17	E. Schrody/L. Muggerud	238393	9537994	$b 99,00
3310	Commercial 2	258	1	17	L. Muggerud	21211	850698	$b 99,00
3311	Put On Your Shit Kickers	258	1	17	E. Schrody/L. Muggerud	190432	7619569	$b 99,00
3312	Come And Get Some Of This	258	1	17	E. Schrody/L. Muggerud/R. Medrano	170475	6821279	$b 99,00
3313	Life Goes On	258	1	17	E. Schrody/R. Medrano	163030	6523458	$b 99,00
3314	One For The Road	258	1	17	E. Schrody/L. Dimant/L. Muggerud	170213	6810820	$b 99,00
3315	Feel It	258	1	17	E. Schrody/R. Medrano	239908	9598588	$b 99,00
3316	All My Love	258	1	17	E. Schrody/L. Dimant	200620	8027065	$b 99,00
3317	Jump Around (Pete Rock Remix)	258	1	17	E. Schrody/L. Muggerud	236120	9447101	$b 99,00
3318	Shamrocks And Shenanigans (Boom Shalock Lock Boom/Butch Vig Mix)	258	1	17	E. Schrody/L. Dimant	237035	9483705	$b 99,00
3319	Instinto Colectivo	259	1	15		300564	12024875	$b 99,00
3320	Chapa o Coco	259	1	15		143830	5755478	$b 99,00
3321	Prostituta	259	1	15		359000	14362307	$b 99,00
3322	Eu So Queria Sumir	259	1	15		269740	10791921	$b 99,00
3323	Tres Reis	259	1	15		304143	12168015	$b 99,00
3324	Um Lugar ao Sol	259	1	15		212323	8495217	$b 99,00
3325	Batalha Naval	259	1	15		285727	11431382	$b 99,00
3326	Todo o Carnaval tem seu Fim	259	1	15		237426	9499371	$b 99,00
3327	O Misterio do Samba	259	1	15		226142	9047970	$b 99,00
3328	Armadura	259	1	15		232881	9317533	$b 99,00
3329	Na Ladeira	259	1	15		221570	8865099	$b 99,00
3330	Carimbo	259	1	15		328751	13152314	$b 99,00
3331	Catimbo	259	1	15		254484	10181692	$b 99,00
3332	Funk de Bamba	259	1	15		237322	9495184	$b 99,00
3333	Chega no Suingue	259	1	15		221805	8874509	$b 99,00
3334	Mun-Ra	259	1	15		274651	10988338	$b 99,00
3335	Freestyle Love	259	1	15		318484	12741680	$b 99,00
3336	War Pigs	260	4	23		234013	8052374	$b 99,00
3337	Past, Present, and Future	261	3	21		2492867	490796184	$b 199,00
3338	The Beginning of the End	261	3	21		2611903	526865050	$b 199,00
3339	LOST Season 4 Trailer	261	3	21		112712	20831818	$b 199,00
3340	LOST In 8:15	261	3	21		497163	98460675	$b 199,00
3341	Confirmed Dead	261	3	21		2611986	512168460	$b 199,00
3342	The Economist	261	3	21		2609025	516934914	$b 199,00
3343	Eggtown	261	3	19		2608817	501061240	$b 199,00
3344	The Constant	261	3	21		2611569	520209363	$b 199,00
3345	The Other Woman	261	3	21		2605021	513246663	$b 199,00
3346	Ji Yeon	261	3	19		2588797	506458858	$b 199,00
3347	Meet Kevin Johnson	261	3	19		2612028	504132981	$b 199,00
3348	The Shape of Things to Come	261	3	21		2591299	502284266	$b 199,00
3349	Amanda	262	5	2	Luca Gusella	246503	4011615	$b 99,00
3350	Despertar	262	5	2	Andrea Dulbecco	307385	4821485	$b 99,00
3352	Distance	264	5	15	Karsh Kale/Vishal Vaid	327122	5327463	$b 99,00
3353	I Guess You're Right	265	5	1	Darius "Take One" Minwalla/Jon Auer/Ken Stringfellow/Matt Harris	212044	3453849	$b 99,00
3355	Love Comes	265	5	1	Darius "Take One" Minwalla/Jon Auer/Ken Stringfellow/Matt Harris	199923	3240609	$b 99,00
3356	Muita Bobeira	266	5	7	Luciana Souza	172710	2775071	$b 99,00
3357	OAM's Blues	267	5	2	Aaron Goldberg	266936	4292028	$b 99,00
3358	One Step Beyond	264	5	15	Karsh Kale	366085	6034098	$b 99,00
3359	Symphony No. 3 in E-flat major, Op. 55, "Eroica" - Scherzo: Allegro Vivace	268	5	24	Ludwig van Beethoven	356426	5817216	$b 99,00
3360	Something Nice Back Home	261	3	21		2612779	484711353	$b 199,00
3361	Cabin Fever	261	3	21		2612028	477733942	$b 199,00
3362	There's No Place Like Home, Pt. 1	261	3	21		2609526	522919189	$b 199,00
3363	There's No Place Like Home, Pt. 2	261	3	21		2497956	523748920	$b 199,00
3364	There's No Place Like Home, Pt. 3	261	3	21		2582957	486161766	$b 199,00
3365	Say Hello 2 Heaven	269	2	23		384497	6477217	$b 99,00
3366	Reach Down	269	2	23		672773	11157785	$b 99,00
3367	Hunger Strike	269	2	23		246292	4233212	$b 99,00
3368	Pushin Forward Back	269	2	23		225278	3892066	$b 99,00
3369	Call Me a Dog	269	2	23		304458	5177612	$b 99,00
3370	Times of Trouble	269	2	23		342539	5795951	$b 99,00
3371	Wooden Jesus	269	2	23		250565	4302603	$b 99,00
3372	Your Savior	269	2	23		244226	4199626	$b 99,00
3373	Four Walled World	269	2	23		414474	6964048	$b 99,00
3374	All Night Thing	269	2	23		231803	3997982	$b 99,00
3375	No Such Thing	270	2	23	Chris Cornell	224837	3691272	$b 99,00
3376	Poison Eye	270	2	23	Chris Cornell	237120	3890037	$b 99,00
3377	Arms Around Your Love	270	2	23	Chris Cornell	214016	3516224	$b 99,00
3378	Safe and Sound	270	2	23	Chris Cornell	256764	4207769	$b 99,00
3379	She'll Never Be Your Man	270	2	23	Chris Cornell	204078	3355715	$b 99,00
3380	Ghosts	270	2	23	Chris Cornell	231547	3799745	$b 99,00
3381	Killing Birds	270	2	23	Chris Cornell	218498	3588776	$b 99,00
3382	Billie Jean	270	2	23	Michael Jackson	281401	4606408	$b 99,00
3383	Scar On the Sky	270	2	23	Chris Cornell	220193	3616618	$b 99,00
3384	Your Soul Today	270	2	23	Chris Cornell	205959	3385722	$b 99,00
3385	Finally Forever	270	2	23	Chris Cornell	217035	3565098	$b 99,00
3386	Silence the Voices	270	2	23	Chris Cornell	267376	4379597	$b 99,00
3387	Disappearing Act	270	2	23	Chris Cornell	273320	4476203	$b 99,00
3388	You Know My Name	270	2	23	Chris Cornell	240255	3940651	$b 99,00
3389	Revelations	271	2	23		252376	4111051	$b 99,00
3390	One and the Same	271	2	23		217732	3559040	$b 99,00
3391	Sound of a Gun	271	2	23		260154	4234990	$b 99,00
3392	Until We Fall	271	2	23		230758	3766605	$b 99,00
3393	Original Fire	271	2	23		218916	3577821	$b 99,00
3394	Broken City	271	2	23		228366	3728955	$b 99,00
3395	Somedays	271	2	23		213831	3497176	$b 99,00
3396	Shape of Things to Come	271	2	23		274597	4465399	$b 99,00
3397	Jewel of the Summertime	271	2	23		233242	3806103	$b 99,00
3398	Wide Awake	271	2	23		266308	4333050	$b 99,00
3399	Nothing Left to Say But Goodbye	271	2	23		213041	3484335	$b 99,00
3400	Moth	271	2	23		298049	4838884	$b 99,00
3401	Show Me How to Live (Live at the Quart Festival)	271	2	23		301974	4901540	$b 99,00
3402	Band Members Discuss Tracks from "Revelations"	271	3	23		294294	61118891	$b 99,00
3403	Intoitus: Adorate Deum	272	2	24	Anonymous	245317	4123531	$b 99,00
3404	Miserere mei, Deus	273	2	24	Gregorio Allegri	501503	8285941	$b 99,00
3405	Canon and Gigue in D Major: I. Canon	274	2	24	Johann Pachelbel	271788	4438393	$b 99,00
3406	Concerto No. 1 in E Major, RV 269 "Spring": I. Allegro	275	2	24	Antonio Vivaldi	199086	3347810	$b 99,00
3407	Concerto for 2 Violins in D Minor, BWV 1043: I. Vivace	276	2	24	Johann Sebastian Bach	193722	3192890	$b 99,00
3410	The Messiah: Behold, I Tell You a Mystery... The Trumpet Shall Sound	279	2	24	George Frideric Handel	582029	9553140	$b 99,00
3411	Solomon HWV 67: The Arrival of the Queen of Sheba	280	2	24	George Frideric Handel	197135	3247914	$b 99,00
3412	"Eine Kleine Nachtmusik" Serenade In G, K. 525: I. Allegro	281	2	24	Wolfgang Amadeus Mozart	348971	5760129	$b 99,00
3413	Concerto for Clarinet in A Major, K. 622: II. Adagio	282	2	24	Wolfgang Amadeus Mozart	394482	6474980	$b 99,00
3414	Symphony No. 104 in D Major "London": IV. Finale: Spiritoso	283	4	24	Franz Joseph Haydn	306687	10085867	$b 99,00
3416	Ave Maria	285	2	24	Franz Schubert	338243	5605648	$b 99,00
3417	Nabucco: Chorus, "Va, Pensiero, Sull'ali Dorate"	286	2	24	Giuseppe Verdi	274504	4498583	$b 99,00
3420	The Nutcracker, Op. 71a, Act II: Scene 14: Pas de deux: Dance of the Prince & the Sugar-Plum Fairy	289	2	24	Peter Ilyich Tchaikovsky	304226	5184289	$b 99,00
3421	Nimrod (Adagio) from Variations On an Original Theme, Op. 36 "Enigma"	290	2	24	Edward Elgar	250031	4124707	$b 99,00
3423	Jupiter, the Bringer of Jollity	292	2	24	Gustav Holst	522099	8547876	$b 99,00
3424	Turandot, Act III, Nessun dorma!	293	2	24	Giacomo Puccini	176911	2920890	$b 99,00
3425	Adagio for Strings from the String Quartet, Op. 11	294	2	24	Samuel Barber	596519	9585597	$b 99,00
3426	Carmina Burana: O Fortuna	295	2	24	Carl Orff	156710	2630293	$b 99,00
3427	Fanfare for the Common Man	296	2	24	Aaron Copland	198064	3211245	$b 99,00
3428	Branch Closing	251	3	22		1814855	360331351	$b 199,00
3429	The Return	251	3	22		1705080	343877320	$b 199,00
3430	Toccata and Fugue in D Minor, BWV 565: I. Toccata	297	2	24	Johann Sebastian Bach	153901	2649938	$b 99,00
3431	Symphony No.1 in D Major, Op.25 "Classical", Allegro Con Brio	298	2	24	Sergei Prokofiev	254001	4195542	$b 99,00
3432	Scheherazade, Op. 35: I. The Sea and Sindbad's Ship	299	2	24	Nikolai Rimsky-Korsakov	545203	8916313	$b 99,00
3433	Concerto No.2 in F Major, BWV1047, I. Allegro	300	2	24	Johann Sebastian Bach	307244	5064553	$b 99,00
3435	Cavalleria Rusticana \\ Act \\ Intermezzo Sinfonico	302	2	24	Pietro Mascagni	243436	4001276	$b 99,00
3436	Karelia Suite, Op.11: 2. Ballade (Tempo Di Menuetto)	303	2	24	Jean Sibelius	406000	5908455	$b 99,00
3437	Piano Sonata No. 14 in C Sharp Minor, Op. 27, No. 2, "Moonlight": I. Adagio sostenuto	304	2	24	Ludwig van Beethoven	391000	6318740	$b 99,00
3438	Fantasia On Greensleeves	280	2	24	Ralph Vaughan Williams	268066	4513190	$b 99,00
3439	Das Lied Von Der Erde, Von Der Jugend	305	2	24	Gustav Mahler	223583	3700206	$b 99,00
3441	Two Fanfares for Orchestra: II. Short Ride in a Fast Machine	307	2	24	John Adams	254930	4310896	$b 99,00
3443	Missa Papae Marcelli: Kyrie	309	2	24	Giovanni Pierluigi da Palestrina	240666	4244149	$b 99,00
3444	Romeo et Juliette: No. 11 - Danse des Chevaliers	310	2	24		275015	4519239	$b 99,00
3445	On the Beautiful Blue Danube	311	2	24	Johann Strauss II	526696	8610225	$b 99,00
3446	Symphonie Fantastique, Op. 14: V. Songe d'une nuit du sabbat	312	2	24	Hector Berlioz	561967	9173344	$b 99,00
3447	Carmen: Overture	313	2	24	Georges Bizet	132932	2189002	$b 99,00
3448	Lamentations of Jeremiah, First Set \\ Incipit Lamentatio	314	2	24	Thomas Tallis	69194	1208080	$b 99,00
3452	SCRIABIN: Prelude in B Major, Op. 11, No. 11	318	4	24		101293	3819535	$b 99,00
3453	Pavan, Lachrimae Antiquae	319	2	24	John Dowland	253281	4211495	$b 99,00
3454	Symphony No. 41 in C Major, K. 551, "Jupiter": IV. Molto allegro	320	2	24	Wolfgang Amadeus Mozart	362933	6173269	$b 99,00
3455	Rehab	321	2	14		213240	3416878	$b 99,00
3456	You Know I'm No Good	321	2	14		256946	4133694	$b 99,00
3457	Me & Mr. Jones	321	2	14		151706	2449438	$b 99,00
3458	Just Friends	321	2	14		191933	3098906	$b 99,00
3459	Back to Black	321	2	14	Mark Ronson	240320	3852953	$b 99,00
3460	Love Is a Losing Game	321	2	14		154386	2509409	$b 99,00
3461	Tears Dry On Their Own	321	2	14	Nickolas Ashford & Valerie Simpson	185293	2996598	$b 99,00
3462	Wake Up Alone	321	2	14	Paul O'duffy	221413	3576773	$b 99,00
3463	Some Unholy War	321	2	14		141520	2304465	$b 99,00
3464	He Can Only Hold Her	321	2	14	Richard Poindexter & Robert Poindexter	166680	2666531	$b 99,00
3465	You Know I'm No Good (feat. Ghostface Killah)	321	2	14		202320	3260658	$b 99,00
3466	Rehab (Hot Chip Remix)	321	2	14		418293	6670600	$b 99,00
3467	Intro / Stronger Than Me	322	2	9		234200	3832165	$b 99,00
3468	You Sent Me Flying / Cherry	322	2	9		409906	6657517	$b 99,00
3469	F**k Me Pumps	322	2	9	Salaam Remi	200253	3324343	$b 99,00
3470	I Heard Love Is Blind	322	2	9		129666	2190831	$b 99,00
3471	(There Is) No Greater Love (Teo Licks)	322	2	9	Isham Jones & Marty Symes	167933	2773507	$b 99,00
3472	In My Bed	322	2	9	Salaam Remi	315960	5211774	$b 99,00
3473	Take the Box	322	2	9	Luke Smith	199160	3281526	$b 99,00
3474	October Song	322	2	9	Matt Rowe & Stefan Skarbek	204846	3358125	$b 99,00
3475	What Is It About Men	322	2	9	Delroy "Chris" Cooper, Donovan Jackson, Earl Chinna Smith, Felix Howard, Gordon Williams, Luke Smith, Paul Watson & Wilburn Squiddley Cole	209573	3426106	$b 99,00
3476	Help Yourself	322	2	9	Freddy James, Jimmy hogarth & Larry Stock	300884	5029266	$b 99,00
3477	Amy Amy Amy (Outro)	322	2	9	Astor Campbell, Delroy "Chris" Cooper, Donovan Jackson, Dorothy Fields, Earl Chinna Smith, Felix Howard, Gordon Williams, James Moody, Jimmy McHugh, Matt Rowe, Salaam Remi & Stefan Skarbek	663426	10564704	$b 99,00
3478	Slowness	323	2	23		215386	3644793	$b 99,00
3479	Prometheus Overture, Op. 43	324	4	24	Ludwig van Beethoven	339567	10887931	$b 99,00
3481	A Midsummer Night's Dream, Op.61 Incidental Music: No.7 Notturno	326	2	24		387826	6497867	$b 99,00
3482	Suite No. 3 in D, BWV 1068: III. Gavotte I & II	327	2	24	Johann Sebastian Bach	225933	3847164	$b 99,00
3483	Concert pour 4 Parties de V**les, H. 545: I. Prelude	328	2	24	Marc-Antoine Charpentier	110266	1973559	$b 99,00
3484	Adios nonino	329	2	24	Astor Piazzolla	289388	4781384	$b 99,00
3486	Act IV, Symphony	331	2	24	Henry Purcell	364296	5987695	$b 99,00
3488	Music for the Funeral of Queen Mary: VI. "Thou Knowest, Lord, the Secrets of Our Hearts"	333	2	24	Henry Purcell	142081	2365930	$b 99,00
3490	Partita in E Major, BWV 1006A: I. Prelude	335	2	24	Johann Sebastian Bach	285673	4744929	$b 99,00
3491	Le Sacre Du Printemps: I.iv. Spring Rounds	336	2	24	Igor Stravinsky	234746	4072205	$b 99,00
3492	Sing Joyfully	314	2	24	William Byrd	133768	2256484	$b 99,00
3493	Metopes, Op. 29: Calypso	337	2	24	Karol Szymanowski	333669	5548755	$b 99,00
3497	Erlkonig, D.328	341	2	24		261849	4307907	$b 99,00
3498	Concerto for Violin, Strings and Continuo in G Major, Op. 3, No. 9: I. Allegro	342	4	24	Pietro Antonio Locatelli	493573	16454937	$b 99,00
3499	Pini Di Roma (Pinien Von Rom) \\ I Pini Della Via Appia	343	2	24		286741	4718950	$b 99,00
3500	String Quartet No. 12 in C Minor, D. 703 "Quartettsatz": II. Andante - Allegro assai	344	2	24	Franz Schubert	139200	2283131	$b 99,00
3501	L'orfeo, Act 3, Sinfonia (Orchestra)	345	2	24	Claudio Monteverdi	66639	1189062	$b 99,00
3502	Quintet for Horn, Violin, 2 Violas, and Cello in E Flat Major, K. 407/386c: III. Allegro	346	2	24	Wolfgang Amadeus Mozart	221331	3665114	$b 99,00
3503	Koyaanisqatsi	347	2	10	Philip Glass	206005	3305164	$b 99,00
\.


--
-- Name: album_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_pkey PRIMARY KEY (albumid);


--
-- Name: artist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (artistid);


--
-- Name: customer_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customerid);


--
-- Name: employee_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employeeid);


--
-- Name: genero_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (generoid);


--
-- Name: invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (invoiceid);


--
-- Name: invoiceline_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY invoiceline
    ADD CONSTRAINT invoiceline_pkey PRIMARY KEY (invoicelineid);


--
-- Name: mediatype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY mediatype
    ADD CONSTRAINT mediatype_pkey PRIMARY KEY (mediatypeid);


--
-- Name: playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (playlistid);


--
-- Name: playlisttrack_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY playlisttrack
    ADD CONSTRAINT playlisttrack_pkey PRIMARY KEY (playlistid, trackid);


--
-- Name: track_pkey; Type: CONSTRAINT; Schema: public; Owner: admin_user; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_pkey PRIMARY KEY (trackid);


--
-- Name: fk_album_artist; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY album
    ADD CONSTRAINT fk_album_artist FOREIGN KEY (artistid) REFERENCES artist(artistid);


--
-- Name: fk_customer_employee; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT fk_customer_employee FOREIGN KEY (supportrepid) REFERENCES employee(employeeid);


--
-- Name: fk_employee_employee; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT fk_employee_employee FOREIGN KEY (reportsto) REFERENCES employee(employeeid);


--
-- Name: fk_invoice_customer; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY invoice
    ADD CONSTRAINT fk_invoice_customer FOREIGN KEY (customerid) REFERENCES customer(customerid);


--
-- Name: fk_invoiceline_invoice; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY invoiceline
    ADD CONSTRAINT fk_invoiceline_invoice FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid);


--
-- Name: fk_invoiceline_track; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY invoiceline
    ADD CONSTRAINT fk_invoiceline_track FOREIGN KEY (trackid) REFERENCES track(trackid);


--
-- Name: fk_playlisttrack_playlist; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY playlisttrack
    ADD CONSTRAINT fk_playlisttrack_playlist FOREIGN KEY (playlistid) REFERENCES playlist(playlistid);


--
-- Name: fk_playlisttrack_track; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY playlisttrack
    ADD CONSTRAINT fk_playlisttrack_track FOREIGN KEY (trackid) REFERENCES track(trackid);


--
-- Name: fk_track_album; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY track
    ADD CONSTRAINT fk_track_album FOREIGN KEY (albumid) REFERENCES album(albumid);


--
-- Name: fk_track_genero; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY track
    ADD CONSTRAINT fk_track_genero FOREIGN KEY (generoid) REFERENCES genero(generoid);


--
-- Name: fk_track_mediatype; Type: FK CONSTRAINT; Schema: public; Owner: admin_user
--

ALTER TABLE ONLY track
    ADD CONSTRAINT fk_track_mediatype FOREIGN KEY (mediatypeid) REFERENCES mediatype(mediatypeid);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: album; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE album FROM PUBLIC;
REVOKE ALL ON TABLE album FROM admin_user;
GRANT ALL ON TABLE album TO admin_user;
GRANT SELECT ON TABLE album TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE album TO operator_user;


--
-- Name: artist; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE artist FROM PUBLIC;
REVOKE ALL ON TABLE artist FROM admin_user;
GRANT ALL ON TABLE artist TO admin_user;
GRANT SELECT ON TABLE artist TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE artist TO operator_user;


--
-- Name: customer; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE customer FROM PUBLIC;
REVOKE ALL ON TABLE customer FROM admin_user;
GRANT ALL ON TABLE customer TO admin_user;
GRANT SELECT ON TABLE customer TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE customer TO operator_user;


--
-- Name: invoice; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE invoice FROM PUBLIC;
REVOKE ALL ON TABLE invoice FROM admin_user;
GRANT ALL ON TABLE invoice TO admin_user;
GRANT SELECT ON TABLE invoice TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE invoice TO operator_user;


--
-- Name: invoiceline; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE invoiceline FROM PUBLIC;
REVOKE ALL ON TABLE invoiceline FROM admin_user;
GRANT ALL ON TABLE invoiceline TO admin_user;
GRANT SELECT ON TABLE invoiceline TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE invoiceline TO operator_user;


--
-- Name: clientes_mas_compras; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE clientes_mas_compras FROM PUBLIC;
REVOKE ALL ON TABLE clientes_mas_compras FROM admin_user;
GRANT ALL ON TABLE clientes_mas_compras TO admin_user;
GRANT SELECT ON TABLE clientes_mas_compras TO uasb_user;
GRANT SELECT ON TABLE clientes_mas_compras TO test_user;


--
-- Name: employee; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE employee FROM PUBLIC;
REVOKE ALL ON TABLE employee FROM admin_user;
GRANT ALL ON TABLE employee TO admin_user;
GRANT SELECT ON TABLE employee TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE employee TO operator_user;


--
-- Name: genero; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE genero FROM PUBLIC;
REVOKE ALL ON TABLE genero FROM admin_user;
GRANT ALL ON TABLE genero TO admin_user;
GRANT SELECT ON TABLE genero TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE genero TO operator_user;


--
-- Name: mediatype; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE mediatype FROM PUBLIC;
REVOKE ALL ON TABLE mediatype FROM admin_user;
GRANT ALL ON TABLE mediatype TO admin_user;
GRANT SELECT ON TABLE mediatype TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE mediatype TO operator_user;


--
-- Name: playlist; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE playlist FROM PUBLIC;
REVOKE ALL ON TABLE playlist FROM admin_user;
GRANT ALL ON TABLE playlist TO admin_user;
GRANT SELECT ON TABLE playlist TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE playlist TO operator_user;


--
-- Name: playlisttrack; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE playlisttrack FROM PUBLIC;
REVOKE ALL ON TABLE playlisttrack FROM admin_user;
GRANT ALL ON TABLE playlisttrack TO admin_user;
GRANT SELECT ON TABLE playlisttrack TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE playlisttrack TO operator_user;


--
-- Name: track; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE track FROM PUBLIC;
REVOKE ALL ON TABLE track FROM admin_user;
GRANT ALL ON TABLE track TO admin_user;
GRANT SELECT ON TABLE track TO uasb_user;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE track TO operator_user;


--
-- Name: top20_canciones_duracion_tipo; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE top20_canciones_duracion_tipo FROM PUBLIC;
REVOKE ALL ON TABLE top20_canciones_duracion_tipo FROM admin_user;
GRANT ALL ON TABLE top20_canciones_duracion_tipo TO admin_user;
GRANT SELECT ON TABLE top20_canciones_duracion_tipo TO uasb_user;
GRANT SELECT ON TABLE top20_canciones_duracion_tipo TO test_user;


--
-- Name: top5_vendidas_genero; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE top5_vendidas_genero FROM PUBLIC;
REVOKE ALL ON TABLE top5_vendidas_genero FROM admin_user;
GRANT ALL ON TABLE top5_vendidas_genero TO admin_user;
GRANT SELECT ON TABLE top5_vendidas_genero TO uasb_user;
GRANT SELECT ON TABLE top5_vendidas_genero TO test_user;


--
-- Name: total_ventas_mes_vendedor; Type: ACL; Schema: public; Owner: admin_user
--

REVOKE ALL ON TABLE total_ventas_mes_vendedor FROM PUBLIC;
REVOKE ALL ON TABLE total_ventas_mes_vendedor FROM admin_user;
GRANT ALL ON TABLE total_ventas_mes_vendedor TO admin_user;
GRANT SELECT ON TABLE total_ventas_mes_vendedor TO uasb_user;
GRANT SELECT ON TABLE total_ventas_mes_vendedor TO test_user;


--
-- PostgreSQL database dump complete
--

