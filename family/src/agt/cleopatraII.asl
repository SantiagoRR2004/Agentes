// Agent cleopatraII in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_madre_de(cleopatraI, cleopatraII).
es_padre_de(ptolemyV, cleopatraII).

divorciados(cleopatraII, ptolemyVIII).
es_madre_de(cleopatraII, ptolemyVII).

casadoCon(cleopatraII, ptolemyVI).
es_madre_de(cleopatraII, cleopatraIII).

/* Initial goals */


/* Plans for events and intentions */

