// Agent ptolemyVI in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyV, ptolemyVI).
es_madre_de(cleopatraI, ptolemyVI).

casadoCon(ptolemyVI, cleopatraII).
es_padre_de(ptolemyVI, cleopatraIII).

/* Initial goals */


/* Plans for events and intentions */

