// Agent ptolemyV in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyIV, ptolemyV).
es_madre_de(arsinoeIII, ptolemyV).

casadoCon(ptolemyV, cleopatraI).
es_padre_de(ptolemyV, ptolemyVI).
es_padre_de(ptolemyV, cleopatraII).
es_padre_de(ptolemyV, ptolemyVIII).

/* Initial goals */


/* Plans for events and intentions */

