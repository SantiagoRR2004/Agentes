// Agent ptolemyX in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyVIII, ptolemyX).
es_madre_de(cleopatraIII, ptolemyX).

divorciados(ptolemyX, cleopatraSeleneI).
es_padre_de(ptolemyX, ptolemyXI).

casadoCon(ptolemyX, bereniceIII).
es_padre_de(ptolemyX, cleopatraV).

/* Initial goals */


/* Plans for events and intentions */

