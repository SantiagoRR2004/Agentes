// Agent ptolemyII in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyI, ptolemyII).
es_madre_de(bereniceI, ptolemyII).

casadoCon(ptolemyII, arsinoeI).
es_padre_de(ptolemyII, ptolemyIII).

/* Initial goals */


/* Plans for events and intentions */

