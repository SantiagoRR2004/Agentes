// Agent cleopatraIII in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyVI, cleopatraIII).
es_madre_de(cleopatraII, cleopatraIII).

casadoCon(cleopatraIII, ptolemyVIII).
es_madre_de(cleopatraIII, cleopatraIV).
es_madre_de(cleopatraIII, ptolemyIX).
es_madre_de(cleopatraIII, cleopatraSeleneI).
es_madre_de(cleopatraIII, ptolemyX).

/* Initial goals */


/* Plans for events and intentions */

