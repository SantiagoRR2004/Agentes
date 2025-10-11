// Agent ptolemyIII in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyII, ptolemyIII).
es_madre_de(arsinoeI, ptolemyIII).

casadoCon(ptolemyIII, bereniceII).
es_padre_de(ptolemyIII, ptolemyIV).
es_padre_de(ptolemyIII, arsinoeII).

/* Initial goals */


/* Plans for events and intentions */

